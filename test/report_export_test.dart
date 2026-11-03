import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/backend/reports/field_config.dart';
import 'package:ktech_project_004/backend/reports/report_models.dart';
import 'package:ktech_project_004/data/api/default_report_excel_export_api.dart';
import 'package:ktech_project_004/data/api/default_report_pdf_export_api.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Report Export Tests', () {
    late DefaultReportPdfExportApi pdfApi;
    late DefaultReportExcelExportApi excelApi;
    late List<PatientStay> samplePatients;
    late ReportFilters filters;

    setUp(() {
      pdfApi = DefaultReportPdfExportApi();
      excelApi = DefaultReportExcelExportApi();
      filters = const ReportFilters();

      // Create sample patients
      samplePatients = [
        PatientStay(
          id: '1',
          serialNo: 1,
          financialYear: 2024,
          prefix: Prefix.bo,
          mothersName: 'Test Mother',
          babyName: 'Test Baby',
          branch: Branch.arpanMother,
          admissionType: AdmissionType.inborn,
          admissionHistory: AdmissionHistory.firstAdmission,
          birthType: BirthType.single,
          doa: DateTime(2024, 1, 15),
          dod: DateTime(2024, 1, 25),
          stay: 10,
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Hospital',
          status: PatientStatus.alive,
          // Discharge fields
          ipNo: 'IP001',
          sex: Sex.male,
          state: 'Gujarat',
          district: 'Ahmedabad',
          dateOfBirth: DateTime(2024, 1, 15),
          gestAgeWeeks: 38,
          gestAgeDays: 2,
          birthWeight: 2.5,
          admissionWeight: 2.5,
          weightPercentile: WeightPercentile.afd,
          dischargeWeight: 2.8,
          headCircumference: 33.5,
          length: 48.0,
          dischargeType: DischargeType.routine,
          user: 'Dr. Test',
          statusOk: true,
        ),
        PatientStay(
          id: '2',
          serialNo: 2,
          financialYear: 2024,
          prefix: Prefix.so,
          mothersName: 'Test Mother 2',
          babyName: 'Test Baby 2',
          branch: Branch.arpanViolet,
          admissionType: AdmissionType.outborn,
          admissionHistory: AdmissionHistory.reAdmission,
          birthType: BirthType.twin,
          doa: DateTime(2024, 2, 1),
          contactNumber: '0987654321',
          contactRelation: Relation.mother,
          city: 'AHMEDABAD',
          pin: '380002',
          del: 'Home',
          status: PatientStatus.alive,
          // Discharge fields
          ipNo: 'IP002',
          sex: Sex.female,
          state: 'Gujarat',
          district: 'Ahmedabad',
          dateOfBirth: DateTime(2024, 1, 30),
          gestAgeWeeks: 35,
          gestAgeDays: 1,
          birthWeight: 1.8,
          admissionWeight: 1.8,
          weightPercentile: WeightPercentile.sfd,
          headCircumference: 30.0,
          length: 44.0,
          dischargeType: DischargeType.shift,
          shiftedTo: 'Another Hospital',
          shiftReason: 'Transfer',
          user: 'Dr. Test',
          statusOk: true,
        ),
        PatientStay(
          id: '3',
          serialNo: 3,
          financialYear: 2024,
          prefix: Prefix.do_,
          mothersName: 'Test Mother 3',
          babyName: 'Test Baby 3',
          branch: Branch.arpanMother,
          admissionType: AdmissionType.inborn,
          admissionHistory: AdmissionHistory.firstAdmission,
          birthType: BirthType.triplet,
          doa: DateTime.now(), // Currently admitted
          contactNumber: '5555555555',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380003',
          del: 'Hospital',
          status: PatientStatus.alive,
          // Discharge fields - not discharged yet
          ipNo: 'IP003',
          sex: Sex.male,
          state: 'Gujarat',
          district: 'Ahmedabad',
          dateOfBirth: DateTime.now().subtract(const Duration(days: 1)),
          gestAgeWeeks: 40,
          gestAgeDays: 0,
          birthWeight: 3.0,
          admissionWeight: 3.0,
          weightPercentile: WeightPercentile.lfd,
          user: 'Dr. Test',
          statusOk: false,
        ),
      ];
    });

    test('Test with 3 selected columns', () async {
      final columns = [
        ReportColumn.serialNumber,
        ReportColumn.babyName,
        ReportColumn.admissionDate,
      ];

      // Test PDF generation
      final pdfBytes = await pdfApi.generateReportPdf(
        patients: samplePatients,
        filters: filters,
        columns: columns,
        hideIdentifiers: false,
        hospitalName: 'K-TECH CLINICAL REGISTRY - ARPAN NICU & PEDIATRICS',
        reportTitle: 'Clinical Admissions & Outcomes Summary Report',
        generatedBy: 'Test User',
      );

      expect(pdfBytes.isNotEmpty, true);
      expect(_pdfPageCount(pdfBytes), 2);

      // Save test PDF
      final testDir = Directory('test_outputs');
      if (!await testDir.exists()) {
        await testDir.create();
      }
      final pdfFile = File('test_outputs/test_3_columns.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      // Test Excel generation
      final excelBytes = await excelApi.generateReportExcel(
        patients: samplePatients,
        filters: filters,
        columns: columns,
        hideIdentifiers: false,
        hospitalName: 'K-TECH CLINICAL REGISTRY - ARPAN NICU & PEDIATRICS',
        reportTitle: 'Clinical Admissions & Outcomes Summary Report',
        generatedBy: 'Test User',
      );

      expect(excelBytes.isNotEmpty, true);

      final excelFile = File('test_outputs/test_3_columns.xlsx');
      await excelFile.writeAsBytes(excelBytes);
    });

    test('Test with ~30 selected columns', () async {
      final columns = [
        ReportColumn.serialNumber,
        ReportColumn.babyName,
        ReportColumn.motherName,
        ReportColumn.branch,
        ReportColumn.admissionType,
        ReportColumn.admissionDate,
        ReportColumn.dischargeDate,
        ReportColumn.birthWeight,
        ReportColumn.dischargeWeight,
        ReportColumn.gestationalAge,
        ReportColumn.gender,
        ReportColumn.contactNumber,
        ReportColumn.address,
        ReportColumn.city,
        ReportColumn.state,
        ReportColumn.pin,
        ReportColumn.placeOfDelivery,
        ReportColumn.patientStatus,
        ReportColumn.maternalMorbidities,
        ReportColumn.antenatalScan,
        ReportColumn.modeOfDelivery,
        ReportColumn.resuscitationAtBirth,
        ReportColumn.antibiotics,
        ReportColumn.sepsis,
        ReportColumn.feeding,
        ReportColumn.ventilation,
        ReportColumn.bpd,
        ReportColumn.rop,
        ReportColumn.dischargeType,
        ReportColumn.stay,
      ];

      final pdfBytes = await pdfApi.generateReportPdf(
        patients: samplePatients,
        filters: filters,
        columns: columns,
        hideIdentifiers: false,
      );

      expect(pdfBytes.isNotEmpty, true);
      expect(_pdfPageCount(pdfBytes), 2);

      final testDir = Directory('test_outputs');
      if (!await testDir.exists()) {
        await testDir.create();
      }
      final pdfFile = File('test_outputs/test_30_columns.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      final excelBytes = await excelApi.generateReportExcel(
        patients: samplePatients,
        filters: filters,
        columns: columns,
        hideIdentifiers: false,
      );

      expect(excelBytes.isNotEmpty, true);

      final excelFile = File('test_outputs/test_30_columns.xlsx');
      await excelFile.writeAsBytes(excelBytes);
    });

    test('Test with all columns', () async {
      final columns = ReportColumn.values.toList();

      final pdfBytes = await pdfApi.generateReportPdf(
        patients: samplePatients,
        filters: filters,
        columns: columns,
        hideIdentifiers: false,
      );

      expect(pdfBytes.isNotEmpty, true);
      expect(_pdfPageCount(pdfBytes), 2);

      final testDir = Directory('test_outputs');
      if (!await testDir.exists()) {
        await testDir.create();
      }
      final pdfFile = File('test_outputs/test_all_columns.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      final excelBytes = await excelApi.generateReportExcel(
        patients: samplePatients,
        filters: filters,
        columns: columns,
        hideIdentifiers: false,
      );

      expect(excelBytes.isNotEmpty, true);

      final excelFile = File('test_outputs/test_all_columns.xlsx');
      await excelFile.writeAsBytes(excelBytes);
    });

    test('Test with mixed Admission and Discharge columns', () async {
      final columns = [
        ReportColumn.serialNumber,
        ReportColumn.babyName,
        ReportColumn.admissionDate,
        ReportColumn.admissionType,
        ReportColumn.birthWeight,
        ReportColumn.gestationalAge,
        ReportColumn.dischargeDate,
        ReportColumn.dischargeType,
        ReportColumn.dischargeWeight,
        ReportColumn.headCircumference,
        ReportColumn.length,
        ReportColumn.ventilation,
        ReportColumn.bpd,
        ReportColumn.feeding,
        ReportColumn.sepsis,
      ];

      final pdfBytes = await pdfApi.generateReportPdf(
        patients: samplePatients,
        filters: filters,
        columns: columns,
        hideIdentifiers: false,
      );

      expect(pdfBytes.isNotEmpty, true);
      expect(_pdfPageCount(pdfBytes), 2);

      final testDir = Directory('test_outputs');
      if (!await testDir.exists()) {
        await testDir.create();
      }
      final pdfFile = File('test_outputs/test_mixed_columns.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      final excelBytes = await excelApi.generateReportExcel(
        patients: samplePatients,
        filters: filters,
        columns: columns,
        hideIdentifiers: false,
      );

      expect(excelBytes.isNotEmpty, true);

      final excelFile = File('test_outputs/test_mixed_columns.xlsx');
      await excelFile.writeAsBytes(excelBytes);
    });

    test('Verify field configuration covers all ReportColumn values', () {
      final unclassifiedColumns = <ReportColumn>[];

      for (final column in ReportColumn.values) {
        final config = FieldConfigRegistry.getConfig(column);
        if (config == null) {
          unclassifiedColumns.add(column);
        }
      }

      expect(
        unclassifiedColumns.isEmpty,
        true,
        reason: 'All columns should be classified',
      );
    });
  });
}

int _pdfPageCount(Uint8List bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(String.fromCharCodes(bytes)).length;
