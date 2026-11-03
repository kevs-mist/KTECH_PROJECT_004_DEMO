import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/backend/reports/field_config.dart';
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
    bool discharged = true,
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
      dod: discharged ? DateTime(2026, 10, 25) : null,
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
    test(
      'generateReportPdf creates valid PDF bytes starting with %PDF',
      () async {
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
      },
    );

    test(
      'generateReportPdf masks identifiers when hideIdentifiers is true',
      () async {
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
      },
    );

    test(
      'generateReportPdf produces valid PDF with empty patient list',
      () async {
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
      },
    );

    test(
      'all report columns are grouped into two landscape form pages',
      () async {
        final patient = makeTestPatient(
          id: 'wide-report',
          mothersName: 'Example Mother',
          babyName: 'B/O Example Mother',
          contact: '9876543210',
        );

        final bytes = await api.generateReportPdf(
          patients: [patient],
          filters: const ReportFilters(),
          columns: ReportColumn.values,
          hideIdentifiers: false,
        );

        final document = latin1.decode(bytes);
        final mediaBoxes = RegExp(
          r'/MediaBox\s*\[\s*0\s+0\s+([\d.]+)\s+([\d.]+)\s*\]',
        ).allMatches(document).toList();
        expect(mediaBoxes, hasLength(2));
        for (final mediaBox in mediaBoxes) {
          final width = double.parse(mediaBox.group(1)!);
          final height = double.parse(mediaBox.group(2)!);
          expect(width, greaterThan(height));
          expect(width, closeTo(842, 2));
          expect(height, closeTo(595, 2));
        }
      },
    );

    test(
      'thirty selected fields produce Admission and Discharge pages',
      () async {
        final patient = makeTestPatient(
          id: 'thirty-fields',
          mothersName: 'Example Mother',
          babyName: 'Baby Example',
          contact: '9876543210',
        );
        final bytes = await api.generateReportPdf(
          patients: [patient],
          filters: const ReportFilters(),
          columns: ReportColumn.values.take(30).toList(),
          hideIdentifiers: false,
        );
        final pages = RegExp(r'/Type\s*/Page\b')
            .allMatches(latin1.decode(bytes));

        expect(pages.length, 2);
      },
    );

    test('long selected values do not prevent form PDF generation', () async {
      final patient =
          makeTestPatient(
            id: 'long-values',
            mothersName: 'Example Mother',
            babyName: 'Baby Example',
            contact: '9876543210',
          ).copyWith(
            address: List.filled(90, 'Long address value').join(' '),
            street: List.filled(60, 'Street detail').join(' '),
          );
      final bytes = await api.generateReportPdf(
        patients: [patient],
        filters: const ReportFilters(),
        columns: const [
          ReportColumn.address,
          ReportColumn.street,
          ReportColumn.diagnosis,
          ReportColumn.ventilation,
        ],
        hideIdentifiers: false,
      );

      expect(bytes, isNotEmpty);
      expect(ascii.decode(bytes.sublist(0, 4)), '%PDF');
    });

    test('PDF omits values from columns that were not selected', () async {
      final patient = makeTestPatient(
        id: 'selection-only',
        mothersName: 'Unselected Mother Name',
        babyName: 'Unselected Baby Name',
        contact: '9991234567',
      );
      final bytes = await api.generateReportPdf(
        patients: [patient],
        filters: const ReportFilters(),
        columns: const [ReportColumn.branch],
        hideIdentifiers: false,
      );

      final document = latin1.decode(bytes);
      expect(document.contains('Unselected Mother Name'), isFalse);
      expect(document.contains('Unselected Baby Name'), isFalse);
      expect(document.contains('9991234567'), isFalse);
    });

    test('one patient always has Admission and Discharge form pages', () async {
      final patient = makeTestPatient(
        id: 'selected-only',
        mothersName: 'Example Mother',
        babyName: 'B/O Example Mother',
        contact: '9876543210',
        discharged: false,
      );

      final bytes = await api.generateReportPdf(
        patients: [patient],
        filters: const ReportFilters(),
        columns: const [
          ReportColumn.serialNumber,
          ReportColumn.babyName,
          ReportColumn.dischargeDate,
        ],
        hideIdentifiers: false,
      );
      final document = latin1.decode(bytes);
      final pages = RegExp(r'/Type\s*/Page\b').allMatches(document);
      expect(pages, hasLength(2));

      final selected = FieldConfigRegistry.splitSelectedFieldsByGroup(const [
        ReportColumn.serialNumber,
        ReportColumn.dischargeDate,
      ]);
      expect(selected.admission.map((field) => field.column), [
        ReportColumn.serialNumber,
      ]);
      expect(selected.discharge.map((field) => field.column), [
        ReportColumn.dischargeDate,
      ]);
    });

    test('all configured columns are classified exactly once', () {
      final configuredColumns = FieldConfigRegistry.allFields
          .map((field) => field.column)
          .toList();
      expect(configuredColumns.toSet(), ReportColumn.values.toSet());
      expect(configuredColumns.length, configuredColumns.toSet().length);
    });
  });
}
