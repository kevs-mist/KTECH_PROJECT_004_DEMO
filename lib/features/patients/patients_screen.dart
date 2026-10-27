import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/aggregation.dart';
import '../../backend/admissions/admissions_providers.dart';
import '../../features/admissions/models/patient_stay.dart';
import '../../features/dashboard/widgets/patient_card.dart';
import '../../widgets/clinical_workspace.dart';

enum PatientFilter { all, admitted, discharged }

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  final _searchController = TextEditingController();
  final _minGestAgeController = TextEditingController();
  final _maxGestAgeController = TextEditingController();
  PatientFilter _filter = PatientFilter.all;
  Sex? _sexFilter;
  PatientStatus? _outcomeFilter;
  Branch? _branchFilter;
  AdmissionType? _admissionTypeFilter;
  AdmissionHistory? _admissionHistoryFilter;
  BirthType? _birthTypeFilter;
  String? _cityFilter;
  String? _stateFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  List<PatientStay> _allPatients = [];
  List<PatientStay> _filteredPatients = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minGestAgeController.dispose();
    _maxGestAgeController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final patients = await ref
          .read(admissionsRepositoryProvider)
          .getAllPatients();
      _allPatients = patients;
      _applyFilter(patients);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _filteredPatients = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter(List<PatientStay> patients) {
    final query = _searchController.text.toLowerCase();
    final filtered = patients.where((p) {
      // Search filter
      if (query.isNotEmpty) {
        final matchesName = p.mothersName.toLowerCase().contains(query);
        final matchesBabyName = p.displayName.toLowerCase().contains(query);
        final matchesContact1 = p.contactNumber.contains(query);
        final matchesContact2 = p.contactNumber2?.contains(query) ?? false;
        final matchesIpNo = p.ipNo?.toLowerCase().contains(query) ?? false;

        if (!matchesName &&
            !matchesBabyName &&
            !matchesContact1 &&
            !matchesContact2 &&
            !matchesIpNo) {
          return false;
        }
      }

      // Status filter
      if (_sexFilter != null && p.sex != _sexFilter) return false;
      if (_outcomeFilter != null && p.status != _outcomeFilter) return false;
      if (_branchFilter != null && p.branch != _branchFilter) return false;
      if (_admissionTypeFilter != null &&
          p.admissionType != _admissionTypeFilter) {
        return false;
      }
      if (_admissionHistoryFilter != null &&
          p.admissionHistory != _admissionHistoryFilter) {
        return false;
      }
      if (_birthTypeFilter != null && p.birthType != _birthTypeFilter) {
        return false;
      }
      if (_cityFilter != null && p.city != _cityFilter) return false;
      if (_stateFilter != null && p.state != _stateFilter) return false;
      if (_startDateFilter != null &&
          p.doa.isBefore(
            DateTime(
              _startDateFilter!.year,
              _startDateFilter!.month,
              _startDateFilter!.day,
            ),
          )) {
        return false;
      }
      if (_endDateFilter != null &&
          p.doa.isAfter(
            DateTime(
                  _endDateFilter!.year,
                  _endDateFilter!.month,
                  _endDateFilter!.day,
                )
                .add(const Duration(days: 1))
                .subtract(const Duration(microseconds: 1)),
          )) {
        return false;
      }

      final minimumWeeks = int.tryParse(_minGestAgeController.text.trim());
      final maximumWeeks = int.tryParse(_maxGestAgeController.text.trim());
      if (minimumWeeks != null &&
          (p.gestAgeWeeks == null || p.gestAgeWeeks! < minimumWeeks)) {
        return false;
      }
      if (maximumWeeks != null &&
          (p.gestAgeWeeks == null || p.gestAgeWeeks! > maximumWeeks)) {
        return false;
      }

      switch (_filter) {
        case PatientFilter.all:
          return true;
        case PatientFilter.admitted:
          return p.dod == null;
        case PatientFilter.discharged:
          return p.dod != null;
      }
    }).toList();

    setState(() {
      _filteredPatients = filtered;
    });
  }

  void _onSearchChanged(String value) {
    _loadPatients();
  }

  void _onFilterChanged(PatientFilter filter) {
    setState(() {
      _filter = filter;
    });
    _loadPatients();
  }

  void _applyCurrentFilters() => _applyFilter(_allPatients);

  void _clearFilters() {
    _searchController.clear();
    _minGestAgeController.clear();
    _maxGestAgeController.clear();
    setState(() {
      _filter = PatientFilter.all;
      _sexFilter = null;
      _outcomeFilter = null;
      _cityFilter = null;
      _stateFilter = null;
      _branchFilter = null;
      _admissionTypeFilter = null;
      _admissionHistoryFilter = null;
      _birthTypeFilter = null;
      _startDateFilter = null;
      _endDateFilter = null;
    });
    _applyFilter(_allPatients);
  }

  @override
  Widget build(BuildContext context) {
    return ClinicalWorkspace(
      title: 'Patients',
      child: Column(
        children: [
          _buildSearchAndFilter(),
          _buildBirthTypeCounts(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorState()
                : _filteredPatients.isEmpty
                ? _buildEmptyState()
                : _buildPatientList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by mother\'s name, contact number, or IP No',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _loadPatients(),
          ),
          const SizedBox(height: AppTheme.space12),
          Wrap(
            spacing: AppTheme.space12,
            runSpacing: AppTheme.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<PatientFilter>(
                segments: const [
                  ButtonSegment(value: PatientFilter.all, label: Text('All')),
                  ButtonSegment(
                    value: PatientFilter.admitted,
                    label: Text('Admitted'),
                  ),
                  ButtonSegment(
                    value: PatientFilter.discharged,
                    label: Text('Discharged'),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (Set<PatientFilter> selected) {
                  _onFilterChanged(selected.first);
                },
              ),
              SizedBox(
                width: 145,
                child: DropdownButtonFormField<Sex>(
                  initialValue: _sexFilter,
                  isExpanded: true,
                  isDense: true,
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: Sex.male, child: Text('Male')),
                    DropdownMenuItem(value: Sex.female, child: Text('Female')),
                  ],
                  onChanged: (value) => setState(() {
                    _sexFilter = value;
                    _applyCurrentFilters();
                  }),
                ),
              ),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<PatientStatus>(
                  initialValue: _outcomeFilter,
                  isExpanded: true,
                  isDense: true,
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  decoration: const InputDecoration(labelText: 'Outcome'),
                  items: const [
                    DropdownMenuItem(
                      value: PatientStatus.alive,
                      child: Text('Alive'),
                    ),
                    DropdownMenuItem(
                      value: PatientStatus.expire,
                      child: Text('Expired'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _outcomeFilter = value;
                    _applyCurrentFilters();
                  }),
                ),
              ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<Branch>(
                  initialValue: _branchFilter,
                  isExpanded: true,
                  isDense: true,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  decoration: const InputDecoration(
                    labelText: 'Branch',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: Branch.arpanMother,
                      child: Text(
                        'Arpan Mother',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: Branch.arpanViolet,
                      child: Text(
                        'Arpan Violet',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  selectedItemBuilder: (context) => const [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Mother', overflow: TextOverflow.ellipsis),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Violet', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _branchFilter = value;
                    _applyCurrentFilters();
                  }),
                ),
              ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<AdmissionType>(
                  initialValue: _admissionTypeFilter,
                  isExpanded: true,
                  isDense: true,
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  decoration: const InputDecoration(
                    labelText: 'Admission Type',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AdmissionType.inborn,
                      child: Text('Inborn'),
                    ),
                    DropdownMenuItem(
                      value: AdmissionType.outborn,
                      child: Text('Outborn'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _admissionTypeFilter = value;
                    _applyCurrentFilters();
                  }),
                ),
              ),
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<AdmissionHistory>(
                  initialValue: _admissionHistoryFilter,
                  isExpanded: true,
                  isDense: true,
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  decoration: const InputDecoration(
                    labelText: 'First / Re Admission',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AdmissionHistory.firstAdmission,
                      child: Text('First Admission'),
                    ),
                    DropdownMenuItem(
                      value: AdmissionHistory.reAdmission,
                      child: Text('Re Admission'),
                    ),
                  ],
                  selectedItemBuilder: (context) => const [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('First', overflow: TextOverflow.ellipsis),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Re-admit', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _admissionHistoryFilter = value;
                    _applyCurrentFilters();
                  }),
                ),
              ),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<BirthType>(
                  initialValue: _birthTypeFilter,
                  isExpanded: true,
                  isDense: true,
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  decoration: const InputDecoration(labelText: 'Birth Type'),
                  items: const [
                    DropdownMenuItem(
                      value: BirthType.single,
                      child: Text('Single'),
                    ),
                    DropdownMenuItem(
                      value: BirthType.twin,
                      child: Text('Twin'),
                    ),
                    DropdownMenuItem(
                      value: BirthType.triplet,
                      child: Text('Triplet'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _birthTypeFilter = value;
                    _applyCurrentFilters();
                  }),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickFilterDate(isStart: true),
                icon: const Icon(Icons.date_range),
                label: Text(
                  _startDateFilter == null
                      ? 'From date'
                      : formatDate(_startDateFilter!),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickFilterDate(isStart: false),
                icon: const Icon(Icons.event),
                label: Text(
                  _endDateFilter == null
                      ? 'To date'
                      : formatDate(_endDateFilter!),
                ),
              ),
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<String>(
                  initialValue: _cityFilter,
                  isExpanded: true,
                  isDense: true,
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  decoration: const InputDecoration(labelText: 'City'),
                  items: _allPatients
                      .map((patient) => patient.city)
                      .where((city) => city.isNotEmpty)
                      .toSet()
                      .toList()
                      .map(
                        (city) => DropdownMenuItem(
                          value: city,
                          child: Text(city, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _cityFilter = value;
                    _applyCurrentFilters();
                  }),
                ),
              ),
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<String>(
                  initialValue: _stateFilter,
                  isExpanded: true,
                  isDense: true,
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  decoration: const InputDecoration(labelText: 'State'),
                  items: _allPatients
                      .map((patient) => patient.state)
                      .whereType<String>()
                      .where((state) => state.isNotEmpty)
                      .toSet()
                      .toList()
                      .map(
                        (state) => DropdownMenuItem(
                          value: state,
                          child: Text(state, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _stateFilter = value;
                    _applyCurrentFilters();
                  }),
                ),
              ),
              SizedBox(
                width: 130,
                child: TextField(
                  controller: _minGestAgeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Min weeks'),
                  onChanged: (_) => _applyCurrentFilters(),
                ),
              ),
              SizedBox(
                width: 130,
                child: TextField(
                  controller: _maxGestAgeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max weeks'),
                  onChanged: (_) => _applyCurrentFilters(),
                ),
              ),
              IconButton(
                tooltip: 'Clear filters',
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFilterDate({required bool isStart}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          (isStart ? _startDateFilter : _endDateFilter) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startDateFilter = selected;
      } else {
        _endDateFilter = selected;
      }
      _applyCurrentFilters();
    });
  }

  Widget _buildBirthTypeCounts() {
    final twinAdmissions = _filteredPatients
        .where((patient) => patient.birthType == BirthType.twin)
        .length;
    final tripletAdmissions = _filteredPatients
        .where((patient) => patient.birthType == BirthType.triplet)
        .length;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space24,
        vertical: AppTheme.space8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Twins: $twinAdmissions baby admissions  |  Triplets: $tripletAdmissions baby admissions',
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: AppTheme.space16),
          Text(
            'Failed to load patients',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.error,
                ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppTheme.space8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppTheme.space16),
          ElevatedButton.icon(
            onPressed: _loadPatients,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: AppTheme.space16),
          Text(
            'No patients found',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            'Try adjusting your search or filter',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.space24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return PatientCard(
          patient: patient,
          onTap: () => context.go('/patients/${patient.id}'),
        );
      },
    );
  }
}
