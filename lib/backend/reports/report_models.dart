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
  prefix,
  stay,
  contactRelation,
  contactNumber2,
  contactRelation2,
  address,
  street,
  area,
  city,
  pin,
  placeOfDelivery,
  patientStatus,
  remarks,
  lastRemarked,
  ipNumber,
  state,
  district,
  dateOfBirth,
  admissionWeight,
  weightPercentile,
  maternalMorbidities,
  maternalMorbiditiesOther,
  ans,
  antenatalScan,
  antenatalScanOther,
  modeOfDelivery,
  resuscitationAtBirth,
  respiratorySystem,
  respiratorySystemOther,
  antibiotics,
  maternalReceivedAntibiotics,
  maternalAntibiotics,
  maternalAntibioticsOther,
  cardiovascularSystem,
  sepsis,
  sepsisOther,
  organism,
  feeding,
  feedingOther,
  rtfStarted,
  fullFeedsReached,
  surfactant,
  ventilation,
  bpd,
  probiotics,
  bloodTransfusion,
  rop,
  usgHead,
  fileName,
  adductaAngle,
  cdcHeadControl,
  cdcSitting,
  cdcStanding,
  dasiiMotorAgeAt50thCentile,
  dasiiMotorAgeAt97thCentile,
  dasiiMentalAgeAt50thCentile,
  dasiiMentalAgeAt97thCentile,
  other,
  picc,
  user,
  statusOk,
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
    ReportColumn.prefix => 'Name prefix',
    ReportColumn.stay => 'Stay (days)',
    ReportColumn.contactRelation => 'Contact relation',
    ReportColumn.contactNumber2 => 'Contact 2',
    ReportColumn.contactRelation2 => 'Contact 2 relation',
    ReportColumn.address => 'Address',
    ReportColumn.street => 'Street',
    ReportColumn.area => 'Area',
    ReportColumn.city => 'City',
    ReportColumn.pin => 'PIN code',
    ReportColumn.placeOfDelivery => 'Place of delivery',
    ReportColumn.patientStatus => 'Admission status',
    ReportColumn.remarks => 'Remarks',
    ReportColumn.lastRemarked => 'Last remarked',
    ReportColumn.ipNumber => 'IP No.',
    ReportColumn.state => 'State',
    ReportColumn.district => 'District',
    ReportColumn.dateOfBirth => 'Date of birth',
    ReportColumn.admissionWeight => 'Admission wt. (kg)',
    ReportColumn.weightPercentile => 'Weight percentile',
    ReportColumn.maternalMorbidities => 'Maternal morbidities',
    ReportColumn.maternalMorbiditiesOther => 'Other maternal morbidities',
    ReportColumn.ans => 'Antenatal steroids',
    ReportColumn.antenatalScan => 'Antenatal scan',
    ReportColumn.antenatalScanOther => 'Other antenatal scan',
    ReportColumn.modeOfDelivery => 'Mode of delivery',
    ReportColumn.resuscitationAtBirth => 'Resuscitation at birth',
    ReportColumn.respiratorySystem => 'Respiratory system',
    ReportColumn.respiratorySystemOther => 'Other respiratory details',
    ReportColumn.antibiotics => 'Antibiotics',
    ReportColumn.maternalReceivedAntibiotics => 'Maternal antibiotics (7 days)',
    ReportColumn.maternalAntibiotics => 'Maternal antibiotic names',
    ReportColumn.maternalAntibioticsOther => 'Other maternal antibiotic',
    ReportColumn.cardiovascularSystem => 'Cardiovascular system',
    ReportColumn.sepsis => 'Sepsis',
    ReportColumn.sepsisOther => 'Other sepsis details',
    ReportColumn.organism => 'Organism',
    ReportColumn.feeding => 'Feeding',
    ReportColumn.feedingOther => 'Other feeding details',
    ReportColumn.rtfStarted => 'RTF started',
    ReportColumn.fullFeedsReached => 'Full feeds reached',
    ReportColumn.surfactant => 'Surfactant',
    ReportColumn.ventilation => 'Ventilation',
    ReportColumn.bpd => 'BPD',
    ReportColumn.probiotics => 'Probiotics',
    ReportColumn.bloodTransfusion => 'Blood transfusion',
    ReportColumn.rop => 'ROP',
    ReportColumn.usgHead => 'USG head',
    ReportColumn.fileName => 'Uploaded file name',
    ReportColumn.adductaAngle => 'Adducta angle',
    ReportColumn.cdcHeadControl => 'CDC head control',
    ReportColumn.cdcSitting => 'CDC sitting',
    ReportColumn.cdcStanding => 'CDC standing',
    ReportColumn.dasiiMotorAgeAt50thCentile => 'DASII motor age (50th)',
    ReportColumn.dasiiMotorAgeAt97thCentile => 'DASII motor age (97th)',
    ReportColumn.dasiiMentalAgeAt50thCentile => 'DASII mental age (50th)',
    ReportColumn.dasiiMentalAgeAt97thCentile => 'DASII mental age (97th)',
    ReportColumn.other => 'Other',
    ReportColumn.picc => 'PICC',
    ReportColumn.user => 'Discharged by',
    ReportColumn.statusOk => 'Status verified',
  };

  bool get containsIdentifier => switch (this) {
    ReportColumn.serialNumber ||
    ReportColumn.babyName ||
    ReportColumn.motherName ||
    ReportColumn.contactNumber ||
    ReportColumn.contactNumber2 ||
    ReportColumn.address ||
    ReportColumn.street ||
    ReportColumn.area ||
    ReportColumn.city ||
    ReportColumn.pin ||
    ReportColumn.dateOfBirth ||
    ReportColumn.ipNumber => true,
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
      ReportColumn.prefix => _enumLabel(patient.prefix.name),
      ReportColumn.stay => (patient.stay ?? patient.daysStayed).toString(),
      ReportColumn.contactRelation => _enumLabel(patient.contactRelation.name),
      ReportColumn.contactNumber2 => patient.contactNumber2 ?? '',
      ReportColumn.contactRelation2 => _enumLabel(
        patient.contactRelation2?.name,
      ),
      ReportColumn.address => patient.address ?? '',
      ReportColumn.street => patient.street ?? '',
      ReportColumn.area => patient.area ?? '',
      ReportColumn.city => patient.city,
      ReportColumn.pin => patient.pin,
      ReportColumn.placeOfDelivery => patient.del,
      ReportColumn.patientStatus => _enumLabel(patient.status?.name),
      ReportColumn.remarks => patient.remarks ?? '',
      ReportColumn.lastRemarked => patient.lastRemarked ?? '',
      ReportColumn.ipNumber => patient.ipNo ?? '',
      ReportColumn.state => patient.state ?? '',
      ReportColumn.district => patient.district ?? '',
      ReportColumn.dateOfBirth => _dateLabel(patient.dateOfBirth),
      ReportColumn.admissionWeight => _numberLabel(patient.admissionWeight),
      ReportColumn.weightPercentile => _enumLabel(
        patient.weightPercentile?.name,
      ),
      ReportColumn.maternalMorbidities => _listLabel(
        patient.maternalMorbidities,
      ),
      ReportColumn.maternalMorbiditiesOther =>
        patient.maternalMorbiditiesOther ?? '',
      ReportColumn.ans => _enumLabel(patient.ans?.name),
      ReportColumn.antenatalScan => _listLabel(patient.antenatalScan),
      ReportColumn.antenatalScanOther => patient.antenatalScanOther ?? '',
      ReportColumn.modeOfDelivery => _enumLabel(patient.modeOfDelivery?.name),
      ReportColumn.resuscitationAtBirth => _listLabel(
        patient.resuscitationAtBirth,
      ),
      ReportColumn.respiratorySystem => _listLabel(patient.respiratorySystem),
      ReportColumn.respiratorySystemOther =>
        patient.respiratorySystemOther ?? '',
      ReportColumn.antibiotics => _listLabel(patient.antibiotics),
      ReportColumn.maternalReceivedAntibiotics => _boolLabel(
        patient.maternalReceivedAntibiotics,
      ),
      ReportColumn.maternalAntibiotics => _listLabel(
        patient.maternalAntibiotics,
      ),
      ReportColumn.maternalAntibioticsOther =>
        patient.maternalAntibioticsOther ?? '',
      ReportColumn.cardiovascularSystem => patient.cardiovascularSystem ?? '',
      ReportColumn.sepsis => patient.sepsis ?? '',
      ReportColumn.sepsisOther => patient.sepsisOther ?? '',
      ReportColumn.organism => patient.organism ?? '',
      ReportColumn.feeding => _listLabel(patient.feeding),
      ReportColumn.feedingOther => patient.feedingOther ?? '',
      ReportColumn.rtfStarted => patient.rtfStarted ?? '',
      ReportColumn.fullFeedsReached => patient.fullFeedsReached ?? '',
      ReportColumn.surfactant => _enumLabel(patient.surfactant?.name),
      ReportColumn.ventilation => _listLabel(patient.ventilation),
      ReportColumn.bpd => _enumLabel(patient.bpd?.name),
      ReportColumn.probiotics => _boolLabel(patient.probiotics),
      ReportColumn.bloodTransfusion => _boolLabel(patient.bloodTransfusion),
      ReportColumn.rop => _enumLabel(patient.rop?.name),
      ReportColumn.usgHead => patient.usgHead ?? '',
      ReportColumn.fileName => patient.fileName ?? '',
      ReportColumn.adductaAngle => patient.adductaAngle ?? '',
      ReportColumn.cdcHeadControl => patient.cdcHeadControl ?? '',
      ReportColumn.cdcSitting => patient.cdcSitting ?? '',
      ReportColumn.cdcStanding => patient.cdcStanding ?? '',
      ReportColumn.dasiiMotorAgeAt50thCentile =>
        patient.dasiiMotorAgeAt50thCentile ?? '',
      ReportColumn.dasiiMotorAgeAt97thCentile =>
        patient.dasiiMotorAgeAt97thCentile ?? '',
      ReportColumn.dasiiMentalAgeAt50thCentile =>
        patient.dasiiMentalAgeAt50thCentile ?? '',
      ReportColumn.dasiiMentalAgeAt97thCentile =>
        patient.dasiiMentalAgeAt97thCentile ?? '',
      ReportColumn.other => patient.other ?? '',
      ReportColumn.picc => _boolLabel(patient.picc),
      ReportColumn.user => patient.user ?? '',
      ReportColumn.statusOk => _boolLabel(patient.statusOk),
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

String _listLabel(List<String>? values) => values?.join(', ') ?? '';

String _boolLabel(bool? value) => value == null
    ? ''
    : value
    ? 'Yes'
    : 'No';

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
