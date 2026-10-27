import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../backend/admissions/admissions_providers.dart';
import '../../backend/reports/report_models.dart';
import '../../features/admissions/models/patient_stay.dart';
import '../../features/auth/auth_controller.dart';
import '../../widgets/clinical_workspace.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _searchController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _minimumWeightController = TextEditingController();
  final _maximumWeightController = TextEditingController();
  final _minimumLengthController = TextEditingController();
  final _maximumLengthController = TextEditingController();

  DateTime? _admissionFrom;
  DateTime? _admissionTo;
  DateTime? _dischargeFrom;
  DateTime? _dischargeTo;
  Branch? _branch;
  AdmissionType? _admissionType;
  AdmissionHistory? _admissionHistory;
  BirthType? _birthType;
  DischargeType? _dischargeType;
  Sex? _sex;
  ReportSortField _sortField = ReportSortField.admissionDate;
  bool _ascending = false;
  bool _hideIdentifiers = false;
  bool _presentationMode = false;
  int _pageIndex = 0;
  int _pageSize = 25;
  List<ReportColumn> _columns = [
    ReportColumn.serialNumber,
    ReportColumn.babyName,
    ReportColumn.branch,
    ReportColumn.admissionType,
    ReportColumn.birthType,
    ReportColumn.admissionDate,
    ReportColumn.dischargeDate,
    ReportColumn.dischargeType,
    ReportColumn.birthWeight,
    ReportColumn.length,
    ReportColumn.headCircumference,
  ];
  final Map<String, _SavedReportView> _savedViews = {};
  Future<ReportPage>? _pageFuture;

  ReportFilters get _filters => ReportFilters(
    admissionFrom: _admissionFrom,
    admissionTo: _admissionTo,
    dischargeFrom: _dischargeFrom,
    dischargeTo: _dischargeTo,
    branch: _branch,
    admissionType: _admissionType,
    admissionHistory: _admissionHistory,
    birthType: _birthType,
    dischargeType: _dischargeType,
    sex: _sex,
    minimumWeightKg: double.tryParse(_minimumWeightController.text.trim()),
    maximumWeightKg: double.tryParse(_maximumWeightController.text.trim()),
    minimumLengthCm: double.tryParse(_minimumLengthController.text.trim()),
    maximumLengthCm: double.tryParse(_maximumLengthController.text.trim()),
    diagnosisQuery: _diagnosisController.text,
    searchQuery: _searchController.text,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _savedViews['This month - Arpan Mother'] = _SavedReportView(
      admissionFrom: DateTime(now.year, now.month),
      admissionTo: DateTime(now.year, now.month + 1, 0),
      dischargeFrom: null,
      dischargeTo: null,
      branch: Branch.arpanMother,
      admissionType: null,
      admissionHistory: null,
      birthType: null,
      dischargeType: null,
      sex: null,
      minimumWeight: '',
      maximumWeight: '',
      minimumLength: '',
      maximumLength: '',
      diagnosis: '',
      search: '',
      columns: List.of(_columns),
    );
    _pageFuture = _loadPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _diagnosisController.dispose();
    _minimumWeightController.dispose();
    _maximumWeightController.dispose();
    _minimumLengthController.dispose();
    _maximumLengthController.dispose();
    super.dispose();
  }

  Future<ReportPage> _loadPage() {
    return ref
        .read(reportRepositoryProvider)
        .search(
          ReportPageRequest(
            filters: _filters,
            sortField: _sortField,
            ascending: _ascending,
            pageIndex: _pageIndex,
            pageSize: _pageSize,
          ),
        );
  }

  void _refresh({bool resetPage = true, int? pageIndex}) {
    setState(() {
      if (pageIndex != null) {
        _pageIndex = pageIndex;
      } else if (resetPage) {
        _pageIndex = 0;
      }
      _pageFuture = _loadPage();
    });
  }

  void _clearFilters() {
    _searchController.clear();
    _diagnosisController.clear();
    _minimumWeightController.clear();
    _maximumWeightController.clear();
    _minimumLengthController.clear();
    _maximumLengthController.clear();
    setState(() {
      _admissionFrom = null;
      _admissionTo = null;
      _dischargeFrom = null;
      _dischargeTo = null;
      _branch = null;
      _admissionType = null;
      _admissionHistory = null;
      _birthType = null;
      _dischargeType = null;
      _sex = null;
      _pageIndex = 0;
      _pageFuture = _loadPage();
    });
  }

  Future<void> _pickDate({
    required String label,
    required DateTime? current,
    required ValueChanged<DateTime?> onChanged,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    setState(() {
      onChanged(date);
      _pageIndex = 0;
      _pageFuture = _loadPage();
    });
  }

  Future<void> _saveView() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save report view'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'View name'),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    setState(() {
      _savedViews[name] = _SavedReportView(
        admissionFrom: _admissionFrom,
        admissionTo: _admissionTo,
        dischargeFrom: _dischargeFrom,
        dischargeTo: _dischargeTo,
        branch: _branch,
        admissionType: _admissionType,
        admissionHistory: _admissionHistory,
        birthType: _birthType,
        dischargeType: _dischargeType,
        sex: _sex,
        minimumWeight: _minimumWeightController.text,
        maximumWeight: _maximumWeightController.text,
        minimumLength: _minimumLengthController.text,
        maximumLength: _maximumLengthController.text,
        diagnosis: _diagnosisController.text,
        search: _searchController.text,
        columns: List.of(_columns),
      );
    });
  }

  void _loadView(_SavedReportView view) {
    setState(() {
      _admissionFrom = view.admissionFrom;
      _admissionTo = view.admissionTo;
      _dischargeFrom = view.dischargeFrom;
      _dischargeTo = view.dischargeTo;
      _branch = view.branch;
      _admissionType = view.admissionType;
      _admissionHistory = view.admissionHistory;
      _birthType = view.birthType;
      _dischargeType = view.dischargeType;
      _sex = view.sex;
      _minimumWeightController.text = view.minimumWeight;
      _maximumWeightController.text = view.maximumWeight;
      _minimumLengthController.text = view.minimumLength;
      _maximumLengthController.text = view.maximumLength;
      _diagnosisController.text = view.diagnosis;
      _searchController.text = view.search;
      _columns = List.of(view.columns);
      _pageIndex = 0;
      _pageFuture = _loadPage();
    });
  }

  Future<void> _showColumnPicker() async {
    final selection = Set<ReportColumn>.of(_columns);
    final result = await showDialog<Set<ReportColumn>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Visible columns'),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ReportColumn.values.map((column) {
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(column.label),
                    value: selection.contains(column),
                    onChanged: (checked) => setDialogState(() {
                      if (checked ?? false) {
                        selection.add(column);
                      } else {
                        selection.remove(column);
                      }
                    }),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(selection),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (result == null || result.isEmpty || !mounted) return;
    setState(
      () => _columns = ReportColumn.values.where(result.contains).toList(),
    );
  }

  Future<void> _startPresentation(int rowCount) async {
    final auth = ref.read(authControllerProvider);
    await ref
        .read(reportRepositoryProvider)
        .recordPresentation(
          filters: _filters,
          rowCount: rowCount,
          userId: auth.userName ?? 'local-user',
        );
    if (mounted) setState(() => _presentationMode = true);
  }

  void _notReady(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format export is not connected in this mock build.'),
      ),
    );
  }

  Future<void> _handlePdfExport({required bool isPrint}) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Generating PDF report...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final page = await ref.read(reportRepositoryProvider).search(
            ReportPageRequest(
              filters: _filters,
              sortField: _sortField,
              ascending: _ascending,
              pageIndex: 0,
              pageSize: 1000,
            ),
          );

      final auth = ref.read(authControllerProvider);
      final exportApi = ref.read(reportPdfExportApiProvider);

      if (isPrint) {
        await exportApi.printOrPreviewPdf(
          patients: page.rows,
          filters: _filters,
          columns: _columns,
          hideIdentifiers: _hideIdentifiers,
          generatedBy: auth.userName ?? 'Clinical Staff',
        );
      } else {
        final savedPath = await exportApi.exportAndSavePdf(
          patients: page.rows,
          filters: _filters,
          columns: _columns,
          hideIdentifiers: _hideIdentifiers,
          generatedBy: auth.userName ?? 'Clinical Staff',
        );

        if (mounted && savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report saved successfully to: $savedPath'),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showPdfExportDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppTheme.inkTeal),
            SizedBox(width: 10),
            Text('Export Report to PDF'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate a clinical summary report containing all filtered patient records with the currently selected columns.',
            ),
            const SizedBox(height: 12),
            if (_hideIdentifiers)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.softMint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility_off, size: 16, color: AppTheme.inkTeal),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Identifiers are currently masked and will be hidden in the export.',
                        style: TextStyle(fontSize: 12, color: AppTheme.inkTeal),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handlePdfExport(isPrint: true);
            },
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print / Preview'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handlePdfExport(isPrint: false);
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('Save PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_presentationMode) return _buildPresentation();
    return ClinicalWorkspace(
      title: 'Present / Report',
      child: Column(
        children: [
          _buildToolbar(),
          _buildFilters(),
          Expanded(
            child: FutureBuilder<ReportPage>(
              future: _pageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Unable to load report: ${snapshot.error}'),
                  );
                }
                final page = snapshot.data;
                if (page == null) return const SizedBox.shrink();
                return _buildResults(page);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space16,
        AppTheme.space12,
        AppTheme.space16,
        AppTheme.space8,
      ),
      child: Wrap(
        spacing: AppTheme.space8,
        runSpacing: AppTheme.space8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 250,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Name, IP No. or FY / Sr. No.',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => _refresh(),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _showColumnPicker,
            icon: const Icon(Icons.view_column_outlined),
            label: const Text('Columns'),
          ),
          OutlinedButton.icon(
            onPressed: _saveView,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save view'),
          ),
          if (_savedViews.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: 'Load saved view',
              onSelected: (name) => _loadView(_savedViews[name]!),
              itemBuilder: (context) => _savedViews.keys
                  .map((name) => PopupMenuItem(value: name, child: Text(name)))
                  .toList(),
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.bookmarks_outlined),
                label: const Text('Saved views'),
              ),
            ),
          IconButton(
            tooltip: _hideIdentifiers ? 'Show identifiers' : 'Hide identifiers',
            onPressed: () =>
                setState(() => _hideIdentifiers = !_hideIdentifiers),
            icon: Icon(
              _hideIdentifiers ? Icons.visibility_off : Icons.visibility,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _notReady('Excel'),
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('Excel'),
          ),
          OutlinedButton.icon(
            onPressed: _showPdfExportDialog,
            icon: const Icon(Icons.print_outlined),
            label: const Text('PDF / Print'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      title: Text('Filters', style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(
        _filters.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppTheme.space16,
        0,
        AppTheme.space16,
        AppTheme.space12,
      ),
      children: [
        Wrap(
          spacing: AppTheme.space8,
          runSpacing: AppTheme.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _dateFilterButton(
              'Admission from',
              _admissionFrom,
              (date) => _admissionFrom = date,
            ),
            _dateFilterButton(
              'Admission to',
              _admissionTo,
              (date) => _admissionTo = date,
            ),
            _dateFilterButton(
              'Discharge from',
              _dischargeFrom,
              (date) => _dischargeFrom = date,
            ),
            _dateFilterButton(
              'Discharge to',
              _dischargeTo,
              (date) => _dischargeTo = date,
            ),
            _enumFilter<Branch>(
              'Branch',
              _branch,
              Branch.values,
              (value) {
                setState(() => _branch = value);
                _refresh();
              },
              (value) =>
                  value == Branch.arpanMother ? 'Arpan Mother' : 'Arpan Violet',
            ),
            _enumFilter<AdmissionType>(
              'Admission',
              _admissionType,
              AdmissionType.values,
              (value) {
                setState(() => _admissionType = value);
                _refresh();
              },
              (value) => value == AdmissionType.inborn ? 'Inborn' : 'Outborn',
            ),
            _enumFilter<AdmissionHistory>(
              'Admission history',
              _admissionHistory,
              AdmissionHistory.values,
              (value) {
                setState(() => _admissionHistory = value);
                _refresh();
              },
              (value) => value == AdmissionHistory.firstAdmission
                  ? 'First'
                  : 'Readmission',
            ),
            _enumFilter<BirthType>('Birth type', _birthType, BirthType.values, (
              value,
            ) {
              setState(() => _birthType = value);
              _refresh();
            }, _labelEnum),
            _enumFilter<DischargeType>(
              'Discharge',
              _dischargeType,
              DischargeType.values,
              (value) {
                setState(() => _dischargeType = value);
                _refresh();
              },
              _labelEnum,
            ),
            _enumFilter<Sex>('Gender', _sex, Sex.values, (value) {
              setState(() => _sex = value);
              _refresh();
            }, _labelEnum),
            _rangeInput('Birth wt. min', _minimumWeightController),
            _rangeInput('Birth wt. max', _maximumWeightController),
            _rangeInput('Length min', _minimumLengthController),
            _rangeInput('Length max', _maximumLengthController),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Clinical text',
                ),
                onChanged: (_) => _refresh(),
              ),
            ),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateFilterButton(
    String label,
    DateTime? value,
    ValueChanged<DateTime?> onChanged,
  ) {
    return OutlinedButton.icon(
      onPressed: () =>
          _pickDate(label: label, current: value, onChanged: onChanged),
      icon: const Icon(Icons.calendar_month_outlined, size: 18),
      label: Text(value == null ? label : '$label: ${_dateText(value)}'),
    );
  }

  Widget _enumFilter<T extends Enum>(
    String label,
    T? value,
    List<T> values,
    ValueChanged<T?> onChanged,
    String Function(T) format,
  ) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        isDense: true,
        decoration: InputDecoration(isDense: true, labelText: label),
        items: values
            .map(
              (item) =>
                  DropdownMenuItem(value: item, child: Text(format(item))),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _rangeInput(String label, TextEditingController controller) {
    return SizedBox(
      width: 125,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(isDense: true, labelText: label),
        onChanged: (_) => _refresh(),
      ),
    );
  }

  Widget _buildResults(ReportPage page) {
    final first = page.totalCount == 0 ? 0 : page.pageIndex * page.pageSize + 1;
    final last = page.pageIndex * page.pageSize + page.rows.length;
    return Column(
      children: [
        _buildSummary(page.summary, page.totalCount),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space16,
            vertical: AppTheme.space8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Showing $first-$last of ${page.totalCount}  •  ${_filters.description}',
                ),
              ),
              DropdownButton<int>(
                value: _pageSize,
                items: const [25, 50, 100]
                    .map(
                      (size) => DropdownMenuItem(
                        value: size,
                        child: Text('$size / page'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _pageSize = value ?? 25);
                  _refresh();
                },
              ),
              IconButton(
                tooltip: 'Previous page',
                onPressed: _pageIndex > 0
                    ? () => _refresh(pageIndex: _pageIndex - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${page.pageCount == 0 ? 0 : page.pageIndex + 1} / ${page.pageCount}',
              ),
              IconButton(
                tooltip: 'Next page',
                onPressed: page.pageIndex + 1 < page.pageCount
                    ? () => _refresh(pageIndex: _pageIndex + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
              const SizedBox(width: AppTheme.space8),
              FilledButton.icon(
                onPressed: () => _startPresentation(page.totalCount),
                icon: const Icon(Icons.present_to_all),
                label: const Text('Present'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                sortAscending: _ascending,
                sortColumnIndex: _sortColumnIndex,
                columns: _columns.map((column) {
                  return DataColumn(
                    label: Text(column.label),
                    numeric: _numericColumn(column),
                    onSort: (_, ascending) => _sortBy(column, ascending),
                  );
                }).toList(),
                rows: page.rows.map((patient) {
                  return DataRow(
                    cells: _columns
                        .map(
                          (column) => DataCell(
                            Text(
                              column.value(
                                patient,
                                hideIdentifiers: _hideIdentifiers,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int? get _sortColumnIndex {
    final index = _columns.indexOf(_columnForSort(_sortField));
    return index < 0 ? null : index;
  }

  void _sortBy(ReportColumn column, bool ascending) {
    final sortField = _sortForColumn(column);
    if (sortField == null) return;
    setState(() {
      _sortField = sortField;
      _ascending = ascending;
    });
    _refresh(resetPage: false);
  }

  Widget _buildSummary(ReportSummary summary, int total) {
    final metrics = <(String, String)>[
      ('Total', '$total'),
      ('Admitted', '${summary.admitted}'),
      ('Discharged', '${summary.discharged}'),
      ('Twins', '${summary.twins}'),
      ('Triplets', '${summary.triplets}'),
      ('Shifted', '${summary.shifted}'),
      ('Male', '${summary.male}'),
      ('Female', '${summary.female}'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: metrics
            .map(
              (metric) => Container(
                constraints: const BoxConstraints(minWidth: 105),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space12,
                  vertical: AppTheme.space8,
                ),
                margin: const EdgeInsets.only(left: AppTheme.space8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.hairline),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.$1,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      metric.$2,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPresentation() {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        title: const Text('Present / Report'),
        actions: [
          IconButton(
            tooltip: _hideIdentifiers ? 'Show identifiers' : 'Hide identifiers',
            onPressed: () =>
                setState(() => _hideIdentifiers = !_hideIdentifiers),
            icon: Icon(
              _hideIdentifiers ? Icons.visibility_off : Icons.visibility,
            ),
          ),
          IconButton(
            tooltip: 'Exit presentation',
            onPressed: () => setState(() => _presentationMode = false),
            icon: const Icon(Icons.fullscreen_exit),
          ),
          const SizedBox(width: AppTheme.space8),
        ],
      ),
      body: FutureBuilder<ReportPage>(
        future: _pageFuture,
        builder: (context, snapshot) {
          final page = snapshot.data;
          if (page == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _buildSummary(page.summary, page.totalCount),
              Padding(
                padding: const EdgeInsets.all(AppTheme.space12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _filters.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 64,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 88,
                      columns: _columns
                          .map(
                            (column) => DataColumn(
                              label: Text(
                                column.label,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          )
                          .toList(),
                      rows: page.rows
                          .map(
                            (patient) => DataRow(
                              cells: _columns
                                  .map(
                                    (column) => DataCell(
                                      Text(
                                        column.value(
                                          patient,
                                          hideIdentifiers: _hideIdentifiers,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.space8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Previous page',
                      onPressed: _pageIndex > 0
                          ? () => _refresh(pageIndex: _pageIndex - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Rows ${page.pageIndex * page.pageSize + 1}-${page.pageIndex * page.pageSize + page.rows.length} of ${page.totalCount}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      tooltip: 'Next page',
                      onPressed: page.pageIndex + 1 < page.pageCount
                          ? () => _refresh(pageIndex: _pageIndex + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _numericColumn(ReportColumn column) => const {
    ReportColumn.birthWeight,
    ReportColumn.dischargeWeight,
    ReportColumn.headCircumference,
    ReportColumn.length,
  }.contains(column);

  ReportSortField? _sortForColumn(ReportColumn column) => switch (column) {
    ReportColumn.serialNumber => ReportSortField.serialNumber,
    ReportColumn.babyName ||
    ReportColumn.motherName => ReportSortField.babyName,
    ReportColumn.branch => ReportSortField.branch,
    ReportColumn.admissionType => ReportSortField.admissionType,
    ReportColumn.birthType => ReportSortField.birthType,
    ReportColumn.gender => ReportSortField.gender,
    ReportColumn.admissionDate => ReportSortField.admissionDate,
    ReportColumn.dischargeDate => ReportSortField.dischargeDate,
    ReportColumn.dischargeType => ReportSortField.dischargeType,
    ReportColumn.birthWeight => ReportSortField.birthWeight,
    ReportColumn.dischargeWeight => ReportSortField.dischargeWeight,
    ReportColumn.headCircumference => ReportSortField.headCircumference,
    ReportColumn.length => ReportSortField.length,
    _ => null,
  };

  ReportColumn _columnForSort(ReportSortField field) => switch (field) {
    ReportSortField.admissionDate => ReportColumn.admissionDate,
    ReportSortField.dischargeDate => ReportColumn.dischargeDate,
    ReportSortField.financialYear ||
    ReportSortField.serialNumber => ReportColumn.serialNumber,
    ReportSortField.babyName => ReportColumn.babyName,
    ReportSortField.branch => ReportColumn.branch,
    ReportSortField.admissionType => ReportColumn.admissionType,
    ReportSortField.birthType => ReportColumn.birthType,
    ReportSortField.gender => ReportColumn.gender,
    ReportSortField.birthWeight => ReportColumn.birthWeight,
    ReportSortField.dischargeWeight => ReportColumn.dischargeWeight,
    ReportSortField.headCircumference => ReportColumn.headCircumference,
    ReportSortField.length => ReportColumn.length,
    ReportSortField.dischargeType => ReportColumn.dischargeType,
  };

  String _labelEnum(Enum value) =>
      value.name[0].toUpperCase() + value.name.substring(1);

  String _dateText(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _SavedReportView {
  final DateTime? admissionFrom;
  final DateTime? admissionTo;
  final DateTime? dischargeFrom;
  final DateTime? dischargeTo;
  final Branch? branch;
  final AdmissionType? admissionType;
  final AdmissionHistory? admissionHistory;
  final BirthType? birthType;
  final DischargeType? dischargeType;
  final Sex? sex;
  final String minimumWeight;
  final String maximumWeight;
  final String minimumLength;
  final String maximumLength;
  final String diagnosis;
  final String search;
  final List<ReportColumn> columns;

  const _SavedReportView({
    required this.admissionFrom,
    required this.admissionTo,
    required this.dischargeFrom,
    required this.dischargeTo,
    required this.branch,
    required this.admissionType,
    required this.admissionHistory,
    required this.birthType,
    required this.dischargeType,
    required this.sex,
    required this.minimumWeight,
    required this.maximumWeight,
    required this.minimumLength,
    required this.maximumLength,
    required this.diagnosis,
    required this.search,
    required this.columns,
  });
}
