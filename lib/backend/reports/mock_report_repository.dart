import '../admissions/admissions_repository.dart';
import '../../features/admissions/models/patient_stay.dart';
import 'report_models.dart';

abstract interface class ReportRepository {
  Future<ReportPage> search(ReportPageRequest request);

  Future<void> recordPresentation({
    required ReportFilters filters,
    required int rowCount,
    required String userId,
  });

  List<ReportAuditEvent> get auditEvents;
}

class MockReportRepository implements ReportRepository {
  final AdmissionsRepository _admissionsRepository;
  final List<ReportAuditEvent> _auditEvents = [];

  MockReportRepository(this._admissionsRepository);

  @override
  List<ReportAuditEvent> get auditEvents => List.unmodifiable(_auditEvents);

  @override
  Future<ReportPage> search(ReportPageRequest request) async {
    final patients = await _admissionsRepository.getAllPatients();
    final filtered =
        patients.where((patient) => _matches(patient, request.filters)).toList()
          ..sort((left, right) {
            final comparison = _compare(left, right, request.sortField);
            if (comparison == 0) {
              return (left.id ?? '').compareTo(right.id ?? '');
            }
            return request.ascending ? comparison : -comparison;
          });

    final safePageSize = request.pageSize.clamp(1, 500);
    final safePageIndex = request.pageIndex < 0 ? 0 : request.pageIndex;
    final start = safePageIndex * safePageSize;
    final end = (start + safePageSize).clamp(0, filtered.length);
    final rows = start >= filtered.length
        ? <PatientStay>[]
        : filtered.sublist(start, end);

    return ReportPage(
      rows: rows,
      totalCount: filtered.length,
      pageIndex: safePageIndex,
      pageSize: safePageSize,
      summary: ReportSummary.fromPatients(filtered),
    );
  }

  @override
  Future<void> recordPresentation({
    required ReportFilters filters,
    required int rowCount,
    required String userId,
  }) async {
    _auditEvents.add(
      ReportAuditEvent(
        occurredAtUtc: DateTime.now().toUtc(),
        action: 'PRESENT',
        userId: userId,
        filterDescription: filters.description,
        rowCount: rowCount,
      ),
    );
  }

  bool _matches(PatientStay patient, ReportFilters filters) {
    if (filters.admissionFrom != null &&
        patient.doa.isBefore(_dayStart(filters.admissionFrom!))) {
      return false;
    }
    if (filters.admissionTo != null &&
        patient.doa.isAfter(_dayEnd(filters.admissionTo!))) {
      return false;
    }
    if (filters.dischargeFrom != null &&
        (patient.dod == null ||
            patient.dod!.isBefore(_dayStart(filters.dischargeFrom!)))) {
      return false;
    }
    if (filters.dischargeTo != null &&
        (patient.dod == null ||
            patient.dod!.isAfter(_dayEnd(filters.dischargeTo!)))) {
      return false;
    }
    if (filters.branch != null && patient.branch != filters.branch) {
      return false;
    }
    if (filters.admissionType != null &&
        patient.admissionType != filters.admissionType) {
      return false;
    }
    if (filters.admissionHistory != null &&
        patient.admissionHistory != filters.admissionHistory) {
      return false;
    }
    if (filters.birthType != null && patient.birthType != filters.birthType) {
      return false;
    }
    if (filters.dischargeType != null &&
        patient.dischargeType != filters.dischargeType) {
      return false;
    }
    if (filters.sex != null && patient.sex != filters.sex) return false;

    if (filters.minimumWeightKg != null &&
        (patient.birthWeight == null ||
            patient.birthWeight! < filters.minimumWeightKg!)) {
      return false;
    }
    if (filters.maximumWeightKg != null &&
        (patient.birthWeight == null ||
            patient.birthWeight! > filters.maximumWeightKg!)) {
      return false;
    }
    if (filters.minimumLengthCm != null &&
        (patient.length == null ||
            patient.length! < filters.minimumLengthCm!)) {
      return false;
    }
    if (filters.maximumLengthCm != null &&
        (patient.length == null ||
            patient.length! > filters.maximumLengthCm!)) {
      return false;
    }

    final diagnosisQuery = filters.diagnosisQuery.trim().toLowerCase();
    if (diagnosisQuery.isNotEmpty &&
        !_diagnosisText(patient).contains(diagnosisQuery)) {
      return false;
    }

    final searchQuery = filters.searchQuery.trim().toLowerCase();
    if (searchQuery.isNotEmpty) {
      final serial = '${patient.financialYear ?? ''} ${patient.serialNo ?? ''}';
      final searchable = [
        patient.displayName,
        patient.mothersName,
        patient.ipNo ?? '',
        serial,
      ].join(' ').toLowerCase();
      if (!searchable.contains(searchQuery)) return false;
    }
    return true;
  }

  int _compare(PatientStay left, PatientStay right, ReportSortField field) {
    return switch (field) {
      ReportSortField.admissionDate => left.doa.compareTo(right.doa),
      ReportSortField.dischargeDate => _compareNullable(left.dod, right.dod),
      ReportSortField.financialYear => (left.financialYear ?? 0).compareTo(
        right.financialYear ?? 0,
      ),
      ReportSortField.serialNumber => (left.serialNo ?? 0).compareTo(
        right.serialNo ?? 0,
      ),
      ReportSortField.babyName => left.displayName.toLowerCase().compareTo(
        right.displayName.toLowerCase(),
      ),
      ReportSortField.branch => (left.branch?.name ?? '').compareTo(
        right.branch?.name ?? '',
      ),
      ReportSortField.admissionType =>
        (left.admissionType?.name ?? '').compareTo(
          right.admissionType?.name ?? '',
        ),
      ReportSortField.birthType => (left.birthType?.name ?? '').compareTo(
        right.birthType?.name ?? '',
      ),
      ReportSortField.gender => (left.sex?.name ?? '').compareTo(
        right.sex?.name ?? '',
      ),
      ReportSortField.birthWeight => (left.birthWeight ?? -1).compareTo(
        right.birthWeight ?? -1,
      ),
      ReportSortField.dischargeWeight => (left.dischargeWeight ?? -1).compareTo(
        right.dischargeWeight ?? -1,
      ),
      ReportSortField.headCircumference =>
        (left.headCircumference ?? -1).compareTo(right.headCircumference ?? -1),
      ReportSortField.length => (left.length ?? -1).compareTo(
        right.length ?? -1,
      ),
      ReportSortField.dischargeType =>
        (left.dischargeType?.name ?? '').compareTo(
          right.dischargeType?.name ?? '',
        ),
    };
  }

  String _diagnosisText(PatientStay patient) => [
    patient.sepsis,
    patient.organism,
    patient.cardiovascularSystem,
    patient.respiratorySystem?.join(' '),
    patient.respiratorySystemOther,
    patient.maternalMorbidities?.join(' '),
    patient.maternalMorbiditiesOther,
    patient.antentalScan?.join(' '),
    patient.antentalScanOther,
    patient.feeding?.join(' '),
    patient.feedingOther,
    patient.remarks,
    patient.other,
  ].whereType<String>().join(' ').toLowerCase();

  DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _dayEnd(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);

  int _compareNullable(DateTime? left, DateTime? right) {
    if (left == null && right == null) return 0;
    if (left == null) return -1;
    if (right == null) return 1;
    return left.compareTo(right);
  }
}
