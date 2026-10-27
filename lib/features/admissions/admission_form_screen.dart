import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/aggregation.dart';
import '../../features/auth/auth_controller.dart';
import '../../data/providers/demo_providers.dart';
import '../../features/admissions/models/patient_stay.dart';
import '../../widgets/clinical_workspace.dart';
import '../../widgets/demo_banner.dart';

class AdmissionFormScreen extends ConsumerStatefulWidget {
  const AdmissionFormScreen({super.key});

  @override
  ConsumerState<AdmissionFormScreen> createState() =>
      _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends ConsumerState<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  Prefix _prefix = Prefix.bo;
  final _mothersNameController = TextEditingController();
  final _babyNameController = TextEditingController();
  bool _babyNameEdited = false;
  List<PatientStay> _knownPatients = [];
  Branch? _branch;
  AdmissionType? _admissionType;
  AdmissionHistory? _admissionHistory;
  BirthType? _birthType;
  DateTime _doa = DateTime.now();
  DateTime? _dod;
  final _contactNumberController = TextEditingController();
  Relation _contactRelation = Relation.father;
  final _contactNumber2Controller = TextEditingController();
  Relation? _contactRelation2;
  final _addressController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController(text: 'AHMEDABAD');
  final _pinController = TextEditingController();
  final _delController = TextEditingController();
  final _remarksController = TextEditingController();
  final _lastRemarkedController = TextEditingController();
  PatientStatus? _status;

  bool _isLoading = false;
  String? _errorMessage;
  int? _serialNo;

  @override
  void initState() {
    super.initState();
    _loadNextSerialNo(_doa);
    _loadPatientsForNameSuggestions();
  }

  @override
  void dispose() {
    _mothersNameController.dispose();
    _babyNameController.dispose();
    _contactNumberController.dispose();
    _contactNumber2Controller.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _pinController.dispose();
    _delController.dispose();
    _remarksController.dispose();
    _lastRemarkedController.dispose();
    super.dispose();
  }

  Future<void> _loadNextSerialNo(DateTime admissionDate) async {
    final fy = getFinancialYear(admissionDate);
    final nextSerial = await ref
        .read(admissionsRepositoryProvider)
        .getNextSerialNumber(fy);
    if (mounted) setState(() => _serialNo = nextSerial);
  }

  Future<void> _loadPatientsForNameSuggestions() async {
    try {
      final patients = await ref
          .read(admissionsRepositoryProvider)
          .getAllPatients();
      if (!mounted) return;
      setState(() => _knownPatients = patients);
      _suggestBabyName();
    } catch (_) {
      // Name suggestions are optional; admission entry remains available.
    }
  }

  void _suggestBabyName() {
    if (_babyNameEdited) return;
    final mother = _mothersNameController.text.trim();
    if (mother.isEmpty) {
      _babyNameController.clear();
      return;
    }
    final prefix = switch (_prefix) {
      Prefix.so => 'S/O',
      Prefix.do_ => 'D/O',
      Prefix.bo => 'B/O',
    };
    var suggestion = '$prefix $mother';
    if (_birthType == BirthType.twin || _birthType == BirthType.triplet) {
      final siblings = _knownPatients.where(
        (patient) =>
            patient.mothersName.trim().toLowerCase() == mother.toLowerCase(),
      );
      final usedSuffixes = siblings
          .map(
            (patient) =>
                RegExp(r' - ([A-Z])$').firstMatch(patient.babyName ?? ''),
          )
          .whereType<RegExpMatch>()
          .map((match) => match.group(1)!)
          .toSet();
      final suffix = ['A', 'B', 'C'].firstWhere(
        (candidate) => !usedSuffixes.contains(candidate),
        orElse: () => 'C',
      );
      suggestion = '$suggestion - $suffix';
    }
    _babyNameController.text = suggestion;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final patient = PatientStay(
        prefix: _prefix,
        mothersName: _mothersNameController.text.trim(),
        babyName: _babyNameController.text.trim(),
        branch: _branch,
        admissionType: _admissionType,
        admissionHistory: _admissionHistory,
        birthType: _birthType,
        doa: _doa,
        dod: _dod,
        contactNumber: _contactNumberController.text.trim(),
        contactRelation: _contactRelation,
        contactNumber2: _contactNumber2Controller.text.trim().isEmpty
            ? null
            : _contactNumber2Controller.text.trim(),
        contactRelation2: _contactRelation2,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        street: _streetController.text.trim().isEmpty
            ? null
            : _streetController.text.trim(),
        area: _areaController.text.trim().isEmpty
            ? null
            : _areaController.text.trim(),
        city: _cityController.text.trim(),
        pin: _pinController.text.trim(),
        del: _delController.text.trim(),
        status: _status,
        remarks: _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text.trim(),
        lastRemarked:
            ref.read(authControllerProvider).canWrite &&
                _lastRemarkedController.text.trim().isNotEmpty
            ? _lastRemarkedController.text.trim()
            : null,
      );

      await ref.read(admissionsRepositoryProvider).createAdmission(patient);
      ref.invalidate(admissionsListProvider);
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        final isDemo = ref.read(authControllerProvider).isDemo;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDemo
                  ? 'Added to the demo session only. Data is cleared when you exit.'
                  : 'Admission created successfully',
            ),
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create admission: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(authControllerProvider.select((s) => s.isDemo));

    return ClinicalWorkspace(
      title: 'New Admission',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDemo) ...[
                    const DemoBanner(),
                    const SizedBox(height: AppTheme.space16),
                  ],
                  if (_errorMessage != null) ...[
                    _buildErrorBanner(_errorMessage!),
                    const SizedBox(height: AppTheme.space16),
                  ],
                  _buildForm(),
                  const SizedBox(height: AppTheme.space24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Admission'),
                      ),
                      const SizedBox(width: AppTheme.space16),
                      TextButton(
                        onPressed: () => context.go('/dashboard'),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: AppTheme.error, size: 20),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormSectionHeading('Admission Record'),
          // Field 1: S.NO (auto, read-only)
          _buildReadOnlyField(
            label: 'S.NO',
            value: _serialNo?.toString() ?? 'Loading...',
          ),
          const SizedBox(height: AppTheme.space16),
          // Field 2: PT'S NAME
          _buildPatientNameField(),
          const SizedBox(height: AppTheme.space16),
          _buildAdmissionChoices(),
          const SizedBox(height: AppTheme.space16),
          // Field 3: DOA
          _buildDateField(
            label: 'DOA (Date of Admission)',
            date: _doa,
            onChanged: (date) {
              if (date != null) {
                setState(() {
                  _doa = date;
                });
                _loadNextSerialNo(date);
              }
            },
          ),
          const SizedBox(height: AppTheme.space16),
          // Field 4: DOD (empty at admission)
          _buildDateField(
            label: 'DOD (Date of Discharge)',
            date: _dod,
            onChanged: (date) {
              setState(() {
                _dod = date;
              });
            },
            optional: true,
          ),
          const SizedBox(height: AppTheme.space16),
          // Field 5: STAY (auto, read-only)
          _buildReadOnlyField(
            label: 'STAY (Days)',
            value: _dod != null
                ? calculateDaysStayed(_doa, _dod!).toString()
                : 'N/A',
          ),
          const SizedBox(height: AppTheme.space16),
          _buildFormSectionHeading('Family and Contact'),
          // Field 6: CONTACT NUMBER
          _buildContactField(
            label: 'CONTACT NUMBER',
            controller: _contactNumberController,
            relation: _contactRelation,
            onRelationChanged: (relation) {
              if (relation != null) {
                setState(() {
                  _contactRelation = relation;
                });
              }
            },
          ),
          const SizedBox(height: AppTheme.space16),
          // Field 7: CONTACT NUMBER2
          _buildContactField(
            label: 'CONTACT NUMBER 2',
            controller: _contactNumber2Controller,
            relation: _contactRelation2,
            onRelationChanged: (relation) {
              setState(() {
                _contactRelation2 = relation;
              });
            },
            optional: true,
          ),
          const SizedBox(height: AppTheme.space16),
          _buildFormSectionHeading('Address and Delivery'),
          // Field 8: ADDRESS
          _buildTextField(
            label: 'ADDRESS',
            controller: _addressController,
            optional: true,
          ),
          const SizedBox(height: AppTheme.space16),
          // Field 9: STREET
          _buildTextField(
            label: 'STREET',
            controller: _streetController,
            optional: true,
          ),
          const SizedBox(height: AppTheme.space16),
          // Field 10: AREA
          _buildTextField(
            label: 'AREA',
            controller: _areaController,
            optional: true,
          ),
          const SizedBox(height: AppTheme.space16),
          // Field 11: CITY
          _buildTextField(label: 'CITY', controller: _cityController),
          const SizedBox(height: AppTheme.space16),
          // Field 12: PIN
          _buildTextField(
            label: 'PIN',
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: AppTheme.space16),
          // Field 13: DEL
          _buildDeliveryField(),
          const SizedBox(height: AppTheme.space16),
          // Field 14: STATUS
          _buildStatusField(),
          const SizedBox(height: AppTheme.space16),
          _buildTextField(
            label: 'Remarks',
            controller: _remarksController,
            optional: true,
            maxLines: 3,
          ),
          if (ref.read(authControllerProvider).canWrite) ...[
            const SizedBox(height: AppTheme.space16),
            _buildTextField(
              label: 'Last remarked (Government initiative participation)',
              controller: _lastRemarkedController,
              optional: true,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.space16),
          decoration: BoxDecoration(
            color: AppTheme.hairline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppTheme.space8),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.space16),
        ],
      ),
    );
  }

  Widget _buildPatientNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PT\'S NAME', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<Prefix>(
                initialValue: _prefix,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radius12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space12,
                    vertical: AppTheme.space12,
                  ),
                ),
                items: Prefix.values.map((prefix) {
                  String label;
                  switch (prefix) {
                    case Prefix.so:
                      label = 'S/O';
                      break;
                    case Prefix.do_:
                      label = 'D/O';
                      break;
                    case Prefix.bo:
                      label = 'B/O';
                      break;
                  }
                  return DropdownMenuItem(value: prefix, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _prefix = value!;
                    _suggestBabyName();
                  });
                },
              ),
            ),
            const SizedBox(width: AppTheme.space12),
            Expanded(
              child: TextFormField(
                controller: _mothersNameController,
                decoration: const InputDecoration(
                  hintText: 'Mother\'s name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mother\'s name is required';
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(() {
                    _babyNameEdited = false;
                    _suggestBabyName();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space16),
        TextFormField(
          controller: _babyNameController,
          decoration: const InputDecoration(
            labelText: 'Baby Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Baby name is required'
              : null,
          onChanged: (_) => _babyNameEdited = true,
        ),
      ],
    );
  }

  Widget _buildAdmissionChoices() {
    return Column(
      children: [
        DropdownButtonFormField<Branch>(
          initialValue: _branch,
          decoration: const InputDecoration(labelText: 'Branch'),
          items: const [
            DropdownMenuItem(
              value: Branch.arpanMother,
              child: Text('Arpan Mother'),
            ),
            DropdownMenuItem(
              value: Branch.arpanViolet,
              child: Text('Arpan Violet'),
            ),
          ],
          validator: (value) => value == null ? 'Branch is required' : null,
          onChanged: (value) => setState(() => _branch = value),
        ),
        const SizedBox(height: AppTheme.space16),
        DropdownButtonFormField<AdmissionType>(
          initialValue: _admissionType,
          decoration: const InputDecoration(labelText: 'Type of Admission'),
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
          validator: (value) =>
              value == null ? 'Type of Admission is required' : null,
          onChanged: (value) => setState(() => _admissionType = value),
        ),
        const SizedBox(height: AppTheme.space16),
        DropdownButtonFormField<AdmissionHistory>(
          initialValue: _admissionHistory,
          decoration: const InputDecoration(labelText: 'First or Readmission'),
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
          validator: (value) =>
              value == null ? 'Admission history is required' : null,
          onChanged: (value) => setState(() => _admissionHistory = value),
        ),
        const SizedBox(height: AppTheme.space16),
        DropdownButtonFormField<BirthType>(
          initialValue: _birthType,
          decoration: const InputDecoration(labelText: 'Birth Type'),
          items: const [
            DropdownMenuItem(value: BirthType.single, child: Text('Single')),
            DropdownMenuItem(value: BirthType.twin, child: Text('Twin')),
            DropdownMenuItem(value: BirthType.triplet, child: Text('Triplet')),
          ],
          validator: (value) => value == null ? 'Birth Type is required' : null,
          onChanged: (value) => setState(() {
            _birthType = value;
            _babyNameEdited = false;
            _suggestBabyName();
          }),
        ),
        const SizedBox(height: AppTheme.space8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'For this mother: Twins ${_motherBirthCount(BirthType.twin)}  |  '
            'Triplets ${_motherBirthCount(BirthType.triplet)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  int _motherBirthCount(BirthType birthType) {
    final mother = _mothersNameController.text.trim().toLowerCase();
    if (mother.isEmpty) return 0;
    return _knownPatients
        .where(
          (patient) =>
              patient.mothersName.trim().toLowerCase() == mother &&
              patient.birthType == birthType,
        )
        .length;
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onChanged,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.hairline),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.space12),
                Text(
                  date != null ? formatDate(date) : 'Select date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: date != null
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (date != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => onChanged(null),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactField({
    required String label,
    required TextEditingController controller,
    required Relation? relation,
    required ValueChanged<Relation?> onRelationChanged,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '10-digit number',
                  border: const OutlineInputBorder(),
                ),
                maxLength: 10,
                validator: (value) {
                  if (!optional && (value == null || value.trim().isEmpty)) {
                    return 'Contact number is required';
                  }
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length != 10) {
                    return 'Must be 10 digits';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppTheme.space12),
            Expanded(
              child: DropdownButtonFormField<Relation>(
                initialValue: relation,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppTheme.space12,
                    vertical: AppTheme.space12,
                  ),
                ),
                items: Relation.values.map((rel) {
                  String label;
                  switch (rel) {
                    case Relation.father:
                      label = 'FATHER';
                      break;
                    case Relation.mother:
                      label = 'MOTHER';
                      break;
                    case Relation.gFather:
                      label = 'G.FATHER';
                      break;
                    case Relation.uncle:
                      label = 'UNCLE';
                      break;
                    case Relation.mama:
                      label = 'MAMA';
                      break;
                    case Relation.nana:
                      label = 'NANA';
                      break;
                    case Relation.nani:
                      label = 'NANI';
                      break;
                    case Relation.foi:
                      label = 'FOI';
                      break;
                  }
                  return DropdownMenuItem(value: rel, child: Text(label));
                }).toList(),
                onChanged: onRelationChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool optional = false,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(border: const OutlineInputBorder()),
          validator: (value) {
            if (!optional && (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryField() {
    final suggestions = [
      'Munshi',
      'Bavishi',
      'Sheth',
      'Amin',
      'Mayflower',
      'Rupal Parikh',
      'Sushrusha hospital',
      'Dr.Akshay Shah',
      'Dr. Kiran Desai',
      'Dr. Suresh Kothari',
      'Sunflower',
      'Dr. Seema Talati',
      'Dr. Bharat Parikh',
      'Dr. Prashant Acharya',
      'Dr. Ashish Nanavati',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DEL (Place of Delivery)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.space8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return suggestions.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _delController.text = controller.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Enter or select place of delivery',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                onFieldSubmitted();
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Place of delivery is required';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STATUS', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppTheme.space8),
        DropdownButtonFormField<PatientStatus>(
          initialValue: _status,
          decoration: const InputDecoration(
            hintText: 'Optional',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: PatientStatus.alive, child: Text('ALIVE')),
            DropdownMenuItem(
              value: PatientStatus.expire,
              child: Text('EXPIRE'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _status = value;
            });
          },
        ),
      ],
    );
  }
}
