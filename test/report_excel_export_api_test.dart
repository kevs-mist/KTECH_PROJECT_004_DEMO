import 'package:excel_plus/excel_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/backend/reports/field_config.dart';
import 'package:ktech_project_004/backend/reports/report_models.dart';
import 'package:ktech_project_004/data/api/default_report_excel_export_api.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DefaultReportExcelExportApi api;

  setUp(() {
    api = DefaultReportExcelExportApi();
  });

  final patient = PatientStay(
    id: 'excel-patient',
    serialNo: 17,
    financialYear: 2026,
    prefix: Prefix.bo,
    mothersName: 'Example Mother',
    babyName: 'Baby Example',
    doa: DateTime(2026, 10, 20),
    dod: DateTime(2026, 10, 25),
    contactNumber: '9876543210',
    contactRelation: Relation.mother,
    pin: '380001',
    del: 'Civil Hospital',
    dateOfBirth: DateTime(2026, 10, 20),
    sex: Sex.female,
    birthWeight: 2.45,
    dischargeWeight: 2.3,
    headCircumference: 33.2,
    maternalReceivedAntibiotics: true,
    user: 'Dr. Example',
    statusOk: true,
  );

  Future<Excel> generate(List<ReportColumn> columns) async {
    final bytes = await api.generateReportExcel(
      patients: [patient],
      filters: const ReportFilters(),
      columns: columns,
      hideIdentifiers: false,
    );
    return Excel.decodeBytes(bytes);
  }

  List<String> headers(Sheet sheet) => sheet.rows[7]
      .map((cell) => (cell?.value as TextCellValue?)?.value.text ?? '')
      .toList();

  List<String> expectedHeaders(List<FieldConfig> fields) => [
    FieldConfigRegistry.getConfig(ReportColumn.serialNumber)!.label,
    FieldConfigRegistry.getConfig(ReportColumn.babyName)!.label,
    ...fields
        .where(
          (field) =>
              field.column != ReportColumn.serialNumber &&
              field.column != ReportColumn.babyName,
        )
        .map((field) => field.label),
  ];

  test(
    'three selected columns export only selected fields on two sheets',
    () async {
      const selected = [
        ReportColumn.admissionDate,
        ReportColumn.birthWeight,
        ReportColumn.dischargeDate,
      ];
      final workbook = await generate(selected);
      final split = FieldConfigRegistry.splitSelectedFieldsByGroup(selected);

      expect(workbook.tables.keys.toSet(), {'Admission', 'Discharge'});
      expect(headers(workbook['Admission']), expectedHeaders(split.admission));
      expect(headers(workbook['Discharge']), expectedHeaders(split.discharge));
      expect(headers(workbook['Admission']), isNot(contains('Contact')));
      expect(headers(workbook['Discharge']), isNot(contains('Head (cm)')));
    },
  );

  test(
    'Excel values are editable native dates, numbers, and booleans',
    () async {
      final workbook = await generate(const [
        ReportColumn.admissionDate,
        ReportColumn.birthWeight,
        ReportColumn.statusOk,
      ]);
      final admission = workbook['Admission'];
      final data = admission.rows[8];

      expect(data[2]?.value, isA<DateCellValue>());
      expect(data[3]?.value, isA<DoubleCellValue>());
      expect(workbook['Discharge'].rows[8][2]?.value, isA<BoolCellValue>());
    },
  );

  test('thirty selected columns use the shared group selection', () async {
    final selected = ReportColumn.values.take(30).toList();
    final workbook = await generate(selected);
    final split = FieldConfigRegistry.splitSelectedFieldsByGroup(selected);

    expect(headers(workbook['Admission']), expectedHeaders(split.admission));
    expect(headers(workbook['Discharge']), expectedHeaders(split.discharge));
  });

  test('all selected columns export across both sheets', () async {
    final workbook = await generate(ReportColumn.values);
    final split = FieldConfigRegistry.splitSelectedFieldsByGroup(
      ReportColumn.values,
    );

    expect(headers(workbook['Admission']), expectedHeaders(split.admission));
    expect(headers(workbook['Discharge']), expectedHeaders(split.discharge));
    expect(headers(workbook['Discharge']), contains('Discharged by'));
    expect(headers(workbook['Discharge']), contains('Status verified'));
    expect(headers(workbook['Admission']), contains('Gender'));
  });

  test(
    'mixed admission and discharge selection stays in its own sheet',
    () async {
      const selected = [
        ReportColumn.motherName,
        ReportColumn.contactNumber,
        ReportColumn.maternalMorbidities,
        ReportColumn.dischargeType,
        ReportColumn.respiratorySystem,
        ReportColumn.dasiiMotorAgeAt50thCentile,
      ];
      final workbook = await generate(selected);
      final split = FieldConfigRegistry.splitSelectedFieldsByGroup(selected);

      expect(headers(workbook['Admission']), expectedHeaders(split.admission));
      expect(headers(workbook['Discharge']), expectedHeaders(split.discharge));
    },
  );
}
