import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/backend/reports/report_models.dart';
import 'package:ktech_project_004/data/api/default_report_pdf_export_api.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DefaultReportPdfExportApi api;

  setUp(() {
    api = DefaultReportPdfExportApi();
  });

  PatientStay makeTestPatient({
    required String id,
    required String mothersName,
    required String babyName,
    required String contact,
  }) {
    return PatientStay(
      id: id,
      serialNo: 1,
      financialYear: 2026,
      prefix: Prefix.bo,
      mothersName: mothersName,
      babyName: babyName,
      branch: Branch.arpanMother,
      admissionType: AdmissionType.inborn,
      admissionHistory: AdmissionHistory.firstAdmission,
      birthType: BirthType.single,
      sex: Sex.male,
      doa: DateTime(2026, 10, 20),
      dod: DateTime(2026, 10, 25),
      stay: 5,
      contactNumber: contact,
      contactRelation: Relation.mother,
      pin: '380001',
      del: 'Civil Hospital',
      birthWeight: 2.5,
      length: 46.0,
      headCircumference: 33.0,
    );
  }

  group('ReportPdfExportApi tests', () {
    test('generateReportPdf creates valid PDF bytes starting with %PDF', () async {
      final patient = makeTestPatient(
        id: 'p1',
        mothersName: 'Sita Sharma',
        babyName: 'B/O Sita Sharma',
        contact: '9876543210',
      );

      final bytes = await api.generateReportPdf(
        patients: [patient],
        filters: const ReportFilters(),
        columns: [
          ReportColumn.serialNumber,
          ReportColumn.babyName,
          ReportColumn.motherName,
          ReportColumn.branch,
          ReportColumn.admissionDate,
          ReportColumn.dischargeDate,
        ],
        hideIdentifiers: false,
        hospitalName: 'Test Arpan NICU',
        reportTitle: 'Monthly Patient Report',
        generatedBy: 'Dr. Test',
      );

      expect(bytes, isNotEmpty);
      // Valid PDF files start with "%PDF"
      final header = ascii.decode(bytes.sublist(0, 4));
      expect(header, '%PDF');
    });

    test('generateReportPdf masks identifiers when hideIdentifiers is true', () async {
      final patient = makeTestPatient(
        id: 'p2',
        mothersName: 'UnmaskedSensitiveMotherName',
        babyName: 'B/O UnmaskedSensitiveMotherName',
        contact: '9988776655',
      );

      final bytes = await api.generateReportPdf(
        patients: [patient],
        filters: const ReportFilters(),
        columns: [
          ReportColumn.serialNumber,
          ReportColumn.babyName,
          ReportColumn.motherName,
          ReportColumn.contactNumber,
        ],
        hideIdentifiers: true,
      );

      expect(bytes, isNotEmpty);
      final rawPdf = latin1.decode(bytes);
      // When hideIdentifiers is true, the sensitive names and contact must be masked (as 'Hidden')
      expect(rawPdf.contains('UnmaskedSensitiveMotherName'), isFalse);
      expect(rawPdf.contains('9988776655'), isFalse);
    });

    test('generateReportPdf produces valid PDF with empty patient list', () async {
      final bytes = await api.generateReportPdf(
        patients: [],
        filters: const ReportFilters(),
        columns: [
          ReportColumn.serialNumber,
          ReportColumn.babyName,
          ReportColumn.branch,
        ],
        hideIdentifiers: false,
      );

      expect(bytes, isNotEmpty);
      final header = ascii.decode(bytes.sublist(0, 4));
      expect(header, '%PDF');
    });
  });
}
