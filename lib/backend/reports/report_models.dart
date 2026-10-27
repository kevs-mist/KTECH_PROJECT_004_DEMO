import '../../features/admissions/models/patient_stay.dart';

enum ReportSortField {
  admissionDate,
  dischargeDate,
  financialYear,
  serialNumber,
  babyName,
  branch,
  admissionType,
  birthType,
  gender,
  birthWeight,
  dischargeWeight,
  headCircumference,
  length,
  dischargeType,
}

enum ReportColumn {
  serialNumber,
  babyName,
  motherName,
  branch,
  admissionType,
  admissionHistory,
  birthType,
  gender,
  admissionDate,
  dischargeDate,
  dischargeType,
  shiftedTo,
  shiftReason,
  birthWeight,
  dischargeWeight,
  headCircumference,
  length,
  gestationalAge,
  diagnosis,
  contactNumber,
}

extension ReportColumnDetails on ReportColumn {
  String get label => switch (this) {
    ReportColumn.serialNumber => 'FY / Sr. No.',
    ReportColumn.babyName => 'Baby',
    ReportColumn.motherName => 'Mother',
    ReportColumn.branch => 'Branch',
    ReportColumn.admissionType => 'Admission type',
    ReportColumn.admissionHistory => 'Admission history',
    ReportColumn.birthType => 'Birth type',
    ReportColumn.gender => 'Gender',
    ReportColumn.admissionDate => 'Admitted',
    ReportColumn.dischargeDate => 'Discharged',
    ReportColumn.dischargeType => 'Discharge type',
    ReportColumn.shiftedTo => 'Shifted to',
    ReportColumn.shiftReason => 'Shift reason',
    ReportColumn.birthWeight => 'Birth wt. (kg)',
    ReportColumn.dischargeWeight => 'Discharge wt. (kg)',
    ReportColumn.headCircumference => 'Head (cm)',
    ReportColumn.length => 'Length (cm)',
    ReportColumn.gestationalAge => 'Gest. age',
    ReportColumn.diagnosis => 'Clinical notes',
    ReportColumn.contactNumber => 'Contact',
  };

  bool get containsIdentifier => switch (this) {
    ReportColumn.serialNumber ||
    ReportColumn.babyName ||
    ReportColumn.motherName ||
    ReportColumn.contactNumber => true,
    _ => false,
  };

  String value(PatientStay patient, {required bool hideIdentifiers}) {
    if (hideIdentifiers && containsIdentifier) return 'Hidden';
    return switch (this) {
      ReportColumn.serialNumber =>
        patient.serialNo == null
            ? ''
            : '${patient.financialYear ?? ''} / ${patient.serialNo}',
      ReportColumn.babyName => patient.displayName,
      ReportColumn.motherName => patient.mothersName,
      ReportColumn.branch => _branchLabel(patient.branch),
      ReportColumn.admissionType => _enumLabel(patient.admissionType?.name),
      ReportColumn.admissionHistory => _enumLabel(
        patient.admissionHistory?.name,
      ),
      ReportColumn.birthType => _enumLabel(patient.birthType?.name),
      ReportColumn.gender => _enumLabel(patient.sex?.name),
      ReportColumn.admissionDate => _dateLabel(patient.doa),
      ReportColumn.dischargeDate => _dateLabel(patient.dod),
      ReportColumn.dischargeType => _enumLabel(patient.dischargeType?.name),
      ReportColumn.shiftedTo => patient.shiftedTo ?? '',
      ReportColumn.shiftReason => patient.shiftReason ?? '',
      ReportColumn.birthWeight => _numberLabel(patient.birthWeight),
      ReportColumn.dischargeWeight => _numberLabel(patient.dischargeWeight),
      ReportColumn.headCircumference => _numberLabel(patient.headCircumference),
      ReportColumn.length => _numberLabel(patient.length),
      ReportColumn.gestationalAge =>
        patient.gestAgeWeeks == null
            ? ''
            : '${patient.gestAgeWeeks}w ${patient.gestAgeDays ?? 0}d',
      ReportColumn.diagnosis => _clinicalNotes(patient),
      ReportColumn.contactNumber => patient.contactNumber,
    };
  }
}

class ReportFilters {
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
  final double? minimumWeightKg;
  final double? maximumWeightKg;
  final double? minimumLengthCm;
  final double? maximumLengthCm;
  final String diagnosisQuery;
  final String searchQuery;

  const ReportFilters({
    this.admissionFrom,
    this.admissionTo,
    this.dischargeFrom,
    this.dischargeTo,
    this.branch,
    this.admissionType,
    this.admissionHistory,
    this.birthType,
    this.dischargeType,
    this.sex,
    this.minimumWeightKg,
    this.maximumWeightKg,
    this.minimumLengthCm,
    this.maximumLengthCm,
    this.diagnosisQuery = '',
    this.searchQuery = '',
  });

  String get description {
    final active = <String>[];
    if (admissionFrom != null || admissionTo != null) {
      active.add('admission date');
    }
    if (dischargeFrom != null || dischargeTo != null) {
      active.add('discharge date');
    }
    if (branch != null) active.add('branch=${_branchLabel(branch)}');
    if (admissionType != null) active.add('admission type');
    if (admissionHistory != null) active.add('admission history');
    if (birthType != null) active.add('birth type');
    if (dischargeType != null) active.add('discharge type');
    if (sex != null) active.add('gender');
    if (minimumWeightKg != null || maximumWeightKg != null) {
      active.add('birth weight range');
    }
    if (minimumLengthCm != null || maximumLengthCm != null) {
      active.add('length range');
    }
    if (diagnosisQuery.trim().isNotEmpty) active.add('clinical text');
    if (searchQuery.trim().isNotEmpty) active.add('name or Sr. No.');
    return active.isEmpty ? 'No filters' : active.join(', ');
  }
}

class ReportPageRequest {
  final ReportFilters filters;
  final ReportSortField sortField;
  final bool ascending;
  final int pageIndex;
  final int pageSize;

  const ReportPageRequest({
    this.filters = const ReportFilters(),
    this.sortField = ReportSortField.admissionDate,
    this.ascending = false,
    this.pageIndex = 0,
    this.pageSize = 50,
  });
}

class ReportSummary {
  final int total;
  final int admitted;
  final int discharged;
  final int twins;
  final int triplets;
  final int shifted;
  final int male;
  final int female;

  const ReportSummary({
    required this.total,
    required this.admitted,
    required this.discharged,
    required this.twins,
    required this.triplets,
    required this.shifted,
    required this.male,
    required this.female,
  });

  factory ReportSummary.fromPatients(List<PatientStay> patients) {
    return ReportSummary(
      total: patients.length,
      admitted: patients.where((patient) => patient.dod == null).length,
      discharged: patients.where((patient) => patient.dod != null).length,
      twins: patients
          .where((patient) => patient.birthType == BirthType.twin)
          .length,
      triplets: patients
          .where((patient) => patient.birthType == BirthType.triplet)
          .length,
      shifted: patients
          .where((patient) => patient.dischargeType == DischargeType.shift)
          .length,
      male: patients.where((patient) => patient.sex == Sex.male).length,
      female: patients.where((patient) => patient.sex == Sex.female).length,
    );
  }
}

class ReportPage {
  final List<PatientStay> rows;
  final int totalCount;
  final int pageIndex;
  final int pageSize;
  final ReportSummary summary;

  const ReportPage({
    required this.rows,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
    required this.summary,
  });

  int get pageCount => totalCount == 0 ? 0 : (totalCount / pageSize).ceil();
}

class ReportAuditEvent {
  final DateTime occurredAtUtc;
  final String action;
  final String userId;
  final String filterDescription;
  final int rowCount;

  const ReportAuditEvent({
    required this.occurredAtUtc,
    required this.action,
    required this.userId,
    required this.filterDescription,
    required this.rowCount,
  });
}

String _branchLabel(Branch? branch) => switch (branch) {
  Branch.arpanMother => 'Arpan Mother',
  Branch.arpanViolet => 'Arpan Violet',
  null => '',
};

String _enumLabel(String? value) {
  if (value == null || value.isEmpty) return '';
  return value
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      )
      .split(' ')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _dateLabel(DateTime? value) {
  if (value == null) return '';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String _numberLabel(double? value) => value?.toStringAsFixed(1) ?? '';

String _clinicalNotes(PatientStay patient) => [
  patient.sepsis,
  patient.organism,
  patient.cardiovascularSystem,
  patient.respiratorySystem?.join(', '),
  patient.respiratorySystemOther,
  patient.maternalMorbidities?.join(', '),
  patient.maternalMorbiditiesOther,
  patient.remarks,
  patient.other,
].whereType<String>().where((value) => value.trim().isNotEmpty).join(' · ');
