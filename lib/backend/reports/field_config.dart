import '../../backend/reports/report_models.dart';
import '../../features/admissions/models/patient_stay.dart';

/// Field group for organizing report columns into Admission and Discharge forms.
enum FieldGroup { admission, discharge }

/// Data type hint for formatting in exports
enum FieldDataType { text, number, date, boolean, list }

/// Configuration for a single report field
class FieldConfig {
  final ReportColumn column;
  final String label;
  final FieldGroup group;
  final FieldDataType dataType;
  final String section;

  const FieldConfig({
    required this.column,
    required this.label,
    required this.group,
    required this.dataType,
    required this.section,
  });
}

/// Shared configuration for all report fields, groups, labels, and sections.
class FieldConfigRegistry {
  static const List<FieldConfig> allFields = [
    // ADMISSION FIELDS - Patient Section (entered in Admission Form)
    FieldConfig(
      column: ReportColumn.serialNumber,
      label: 'FY / Sr. No.',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.babyName,
      label: 'Baby',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.motherName,
      label: 'Mother',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.prefix,
      label: 'Name prefix',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.branch,
      label: 'Branch',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.admissionType,
      label: 'Admission type',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.admissionHistory,
      label: 'Admission history',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.birthType,
      label: 'Birth type',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.gender,
      label: 'Gender',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.admissionDate,
      label: 'Admitted date',
      group: FieldGroup.admission,
      dataType: FieldDataType.date,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.dateOfBirth,
      label: 'Date of birth',
      group: FieldGroup.admission,
      dataType: FieldDataType.date,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.ipNumber,
      label: 'IP No.',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.patientStatus,
      label: 'Admission status',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.admissionWeight,
      label: 'Admission wt. (kg)',
      group: FieldGroup.admission,
      dataType: FieldDataType.number,
      section: 'Birth',
    ),
    FieldConfig(
      column: ReportColumn.birthWeight,
      label: 'Birth wt. (kg)',
      group: FieldGroup.admission,
      dataType: FieldDataType.number,
      section: 'Birth',
    ),
    FieldConfig(
      column: ReportColumn.weightPercentile,
      label: 'Weight percentile',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Birth',
    ),
    FieldConfig(
      column: ReportColumn.gestationalAge,
      label: 'Gest. age',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Birth',
    ),
    FieldConfig(
      column: ReportColumn.placeOfDelivery,
      label: 'Place of delivery',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Patient',
    ),
    FieldConfig(
      column: ReportColumn.maternalMorbidities,
      label: 'Maternal morbidities',
      group: FieldGroup.admission,
      dataType: FieldDataType.list,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.maternalMorbiditiesOther,
      label: 'Other maternal morbidities',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.ans,
      label: 'Antenatal steroids',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.antenatalScan,
      label: 'Antenatal scan',
      group: FieldGroup.admission,
      dataType: FieldDataType.list,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.antenatalScanOther,
      label: 'Other antenatal scan',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.modeOfDelivery,
      label: 'Mode of delivery',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.maternalReceivedAntibiotics,
      label: 'Maternal antibiotics (7 days)',
      group: FieldGroup.admission,
      dataType: FieldDataType.boolean,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.maternalAntibiotics,
      label: 'Maternal antibiotic names',
      group: FieldGroup.admission,
      dataType: FieldDataType.list,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.maternalAntibioticsOther,
      label: 'Other maternal antibiotic',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Maternal',
    ),
    FieldConfig(
      column: ReportColumn.resuscitationAtBirth,
      label: 'Resuscitation at birth',
      group: FieldGroup.admission,
      dataType: FieldDataType.list,
      section: 'Resuscitation',
    ),
    FieldConfig(
      column: ReportColumn.state,
      label: 'State',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Address',
    ),
    FieldConfig(
      column: ReportColumn.district,
      label: 'District',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Address',
    ),
    FieldConfig(
      column: ReportColumn.diagnosis,
      label: 'Clinical notes',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Clinical Notes',
    ),

    // ADMISSION FIELDS - Contact Section (entered in Admission Form)
    FieldConfig(
      column: ReportColumn.contactNumber,
      label: 'Contact',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Contact',
    ),
    FieldConfig(
      column: ReportColumn.contactRelation,
      label: 'Contact relation',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Contact',
    ),
    FieldConfig(
      column: ReportColumn.contactNumber2,
      label: 'Contact 2',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Contact',
    ),
    FieldConfig(
      column: ReportColumn.contactRelation2,
      label: 'Contact 2 relation',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Contact',
    ),

    // ADMISSION FIELDS - Address Section (entered in Admission Form)
    FieldConfig(
      column: ReportColumn.address,
      label: 'Address',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Address',
    ),
    FieldConfig(
      column: ReportColumn.street,
      label: 'Street',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Address',
    ),
    FieldConfig(
      column: ReportColumn.area,
      label: 'Area',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Address',
    ),
    FieldConfig(
      column: ReportColumn.city,
      label: 'City',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Address',
    ),
    FieldConfig(
      column: ReportColumn.pin,
      label: 'PIN code',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Address',
    ),

    // ADMISSION FIELDS - Clinical Notes Section (entered in Admission Form)
    FieldConfig(
      column: ReportColumn.remarks,
      label: 'Remarks',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Clinical Notes',
    ),
    FieldConfig(
      column: ReportColumn.lastRemarked,
      label: 'Last remarked',
      group: FieldGroup.admission,
      dataType: FieldDataType.text,
      section: 'Clinical Notes',
    ),

    // DISCHARGE FIELDS - Discharge Info Section (entered in Discharge Form)
    FieldConfig(
      column: ReportColumn.dischargeType,
      label: 'Discharge type',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Discharge Info',
    ),
    FieldConfig(
      column: ReportColumn.shiftedTo,
      label: 'Shifted to',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Discharge Info',
    ),
    FieldConfig(
      column: ReportColumn.shiftReason,
      label: 'Shift reason',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Discharge Info',
    ),
    FieldConfig(
      column: ReportColumn.dischargeDate,
      label: 'Discharged date',
      group: FieldGroup.discharge,
      dataType: FieldDataType.date,
      section: 'Discharge Info',
    ),
    FieldConfig(
      column: ReportColumn.stay,
      label: 'Stay (days)',
      group: FieldGroup.discharge,
      dataType: FieldDataType.number,
      section: 'Discharge Info',
    ),
    FieldConfig(
      column: ReportColumn.fileName,
      label: 'Uploaded file name',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Discharge Info',
    ),

    // DISCHARGE FIELDS - Measurements Section
    FieldConfig(
      column: ReportColumn.dischargeWeight,
      label: 'Discharge wt.',
      group: FieldGroup.discharge,
      dataType: FieldDataType.number,
      section: 'Measurements',
    ),
    FieldConfig(
      column: ReportColumn.headCircumference,
      label: 'Head (cm)',
      group: FieldGroup.discharge,
      dataType: FieldDataType.number,
      section: 'Measurements',
    ),
    FieldConfig(
      column: ReportColumn.length,
      label: 'Length (cm)',
      group: FieldGroup.discharge,
      dataType: FieldDataType.number,
      section: 'Measurements',
    ),

    // DISCHARGE FIELDS - Respiratory Section (entered in Discharge Form)
    FieldConfig(
      column: ReportColumn.respiratorySystem,
      label: 'Respiratory system',
      group: FieldGroup.discharge,
      dataType: FieldDataType.list,
      section: 'Respiratory',
    ),
    FieldConfig(
      column: ReportColumn.respiratorySystemOther,
      label: 'Other respiratory details',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Respiratory',
    ),

    // DISCHARGE FIELDS - Cardiovascular Section (entered in Discharge Form)
    FieldConfig(
      column: ReportColumn.cardiovascularSystem,
      label: 'Cardiovascular system',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Cardiovascular',
    ),

    // DISCHARGE FIELDS - Antibiotics & Sepsis Section (entered in Discharge Form)
    FieldConfig(
      column: ReportColumn.antibiotics,
      label: 'Antibiotics',
      group: FieldGroup.discharge,
      dataType: FieldDataType.list,
      section: 'Antibiotics & Sepsis',
    ),
    FieldConfig(
      column: ReportColumn.sepsis,
      label: 'Sepsis',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Antibiotics & Sepsis',
    ),
    FieldConfig(
      column: ReportColumn.sepsisOther,
      label: 'Other sepsis details',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Antibiotics & Sepsis',
    ),
    FieldConfig(
      column: ReportColumn.organism,
      label: 'Organism',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Antibiotics & Sepsis',
    ),

    // DISCHARGE FIELDS - Feeding Section (entered in Discharge Form)
    FieldConfig(
      column: ReportColumn.feeding,
      label: 'Feeding',
      group: FieldGroup.discharge,
      dataType: FieldDataType.list,
      section: 'Feeding',
    ),
    FieldConfig(
      column: ReportColumn.feedingOther,
      label: 'Other feeding details',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Feeding',
    ),
    FieldConfig(
      column: ReportColumn.rtfStarted,
      label: 'RTF started',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Feeding',
    ),
    FieldConfig(
      column: ReportColumn.fullFeedsReached,
      label: 'Full feeds reached',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Feeding',
    ),

    // DISCHARGE FIELDS - Treatment Section (entered in Discharge Form)
    FieldConfig(
      column: ReportColumn.surfactant,
      label: 'Surfactant',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Treatment',
    ),
    FieldConfig(
      column: ReportColumn.ventilation,
      label: 'Ventilation',
      group: FieldGroup.discharge,
      dataType: FieldDataType.list,
      section: 'Treatment',
    ),
    FieldConfig(
      column: ReportColumn.bpd,
      label: 'BPD',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Treatment',
    ),
    FieldConfig(
      column: ReportColumn.probiotics,
      label: 'Probiotics',
      group: FieldGroup.discharge,
      dataType: FieldDataType.boolean,
      section: 'Treatment',
    ),
    FieldConfig(
      column: ReportColumn.bloodTransfusion,
      label: 'Blood transfusion',
      group: FieldGroup.discharge,
      dataType: FieldDataType.boolean,
      section: 'Treatment',
    ),
    FieldConfig(
      column: ReportColumn.rop,
      label: 'ROP',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Treatment',
    ),
    FieldConfig(
      column: ReportColumn.usgHead,
      label: 'USG head',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Treatment',
    ),
    FieldConfig(
      column: ReportColumn.picc,
      label: 'PICC',
      group: FieldGroup.discharge,
      dataType: FieldDataType.boolean,
      section: 'Treatment',
    ),
    FieldConfig(
      column: ReportColumn.user,
      label: 'Discharged by',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Discharge Info',
    ),
    FieldConfig(
      column: ReportColumn.statusOk,
      label: 'Status verified',
      group: FieldGroup.discharge,
      dataType: FieldDataType.boolean,
      section: 'Discharge Info',
    ),

    // DISCHARGE FIELDS - Other Section (entered in Discharge Form)
    FieldConfig(
      column: ReportColumn.other,
      label: 'Other',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Other',
    ),

    // DISCHARGE FIELDS - Developmental Assessment Section (entered in Discharge Form)
    FieldConfig(
      column: ReportColumn.adductaAngle,
      label: 'Adducta angle',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Developmental Assessment',
    ),
    FieldConfig(
      column: ReportColumn.cdcHeadControl,
      label: 'CDC head control',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Developmental Assessment',
    ),
    FieldConfig(
      column: ReportColumn.cdcSitting,
      label: 'CDC sitting',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Developmental Assessment',
    ),
    FieldConfig(
      column: ReportColumn.cdcStanding,
      label: 'CDC standing',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Developmental Assessment',
    ),
    FieldConfig(
      column: ReportColumn.dasiiMotorAgeAt50thCentile,
      label: 'DASII motor age (50th)',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Developmental Assessment',
    ),
    FieldConfig(
      column: ReportColumn.dasiiMotorAgeAt97thCentile,
      label: 'DASII motor age (97th)',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Developmental Assessment',
    ),
    FieldConfig(
      column: ReportColumn.dasiiMentalAgeAt50thCentile,
      label: 'DASII mental age (50th)',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Developmental Assessment',
    ),
    FieldConfig(
      column: ReportColumn.dasiiMentalAgeAt97thCentile,
      label: 'DASII mental age (97th)',
      group: FieldGroup.discharge,
      dataType: FieldDataType.text,
      section: 'Developmental Assessment',
    ),
  ];

  /// Get field config for a specific column
  /// Returns null if column is not in config (removed or unclassified)
  static FieldConfig? getConfig(ReportColumn column) {
    for (final config in allFields) {
      if (config.column == column) return config;
    }
    return null;
  }

  static List<ReportColumn> filterRemovedColumns(List<ReportColumn> columns) {
    return columns.where((column) => getConfig(column) != null).toList();
  }

  /// Get all fields for a specific group
  static List<FieldConfig> getFieldsByGroup(FieldGroup group) {
    return allFields.where((f) => f.group == group).toList();
  }

  /// Get fields for a specific group and section
  static List<FieldConfig> getFieldsBySection(
    FieldGroup group,
    String section,
  ) {
    return allFields
        .where((f) => f.group == group && f.section == section)
        .toList();
  }

  /// Get all section names for a group
  static List<String> getSections(FieldGroup group) {
    final sections = allFields
        .where((f) => f.group == group)
        .map((f) => f.section)
        .toSet()
        .toList();
    sections.sort();
    return sections;
  }

  /// Get field configs for selected columns, omitting only unclassified fields.
  /// This is the SHARED selection function used by both PDF and Excel
  static List<FieldConfig> getSelectedFieldConfigs(
    List<ReportColumn> selectedColumns,
  ) {
    return selectedColumns
        .map((col) => getConfig(col))
        .whereType<FieldConfig>()
        .toList();
  }

  /// Return the underlying value for a typed Excel cell.
  static Object? excelValue(
    FieldConfig field,
    PatientStay patient, {
    required bool hideIdentifiers,
  }) {
    if (hideIdentifiers && field.column.containsIdentifier) return 'Hidden';

    return switch (field.column) {
      ReportColumn.admissionDate => patient.doa,
      ReportColumn.dischargeDate => patient.dod,
      ReportColumn.dateOfBirth => patient.dateOfBirth,
      ReportColumn.stay => patient.stay ?? patient.daysStayed,
      ReportColumn.birthWeight => patient.birthWeight,
      ReportColumn.admissionWeight => patient.admissionWeight,
      ReportColumn.dischargeWeight => patient.dischargeWeight,
      ReportColumn.headCircumference => patient.headCircumference,
      ReportColumn.length => patient.length,
      ReportColumn.maternalReceivedAntibiotics =>
        patient.maternalReceivedAntibiotics,
      ReportColumn.probiotics => patient.probiotics,
      ReportColumn.bloodTransfusion => patient.bloodTransfusion,
      ReportColumn.picc => patient.picc,
      ReportColumn.statusOk => patient.statusOk,
      _ => field.column.value(patient, hideIdentifiers: hideIdentifiers),
    };
  }

  /// Split selected field configs by group (admission vs discharge)
  /// This is the SHARED split function used by both PDF and Excel
  static ({List<FieldConfig> admission, List<FieldConfig> discharge})
  splitSelectedFieldsByGroup(List<ReportColumn> selectedColumns) {
    final selectedConfigs = getSelectedFieldConfigs(selectedColumns);
    final admissionFields = selectedConfigs
        .where((f) => f.group == FieldGroup.admission)
        .toList();
    final dischargeFields = selectedConfigs
        .where((f) => f.group == FieldGroup.discharge)
        .toList();
    return (admission: admissionFields, discharge: dischargeFields);
  }
}
