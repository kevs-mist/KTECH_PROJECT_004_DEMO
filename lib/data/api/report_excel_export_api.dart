import 'dart:typed_data';

import '../../backend/reports/report_models.dart';
import '../../features/admissions/models/patient_stay.dart';

/// Abstract contract for generating and saving report Excel documents.
abstract class ReportExcelExportApi {
  /// Generates the binary Excel document bytes for the specified report data.
  Future<Uint8List> generateReportExcel({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  });

  /// Prompts the user with a file save dialog, writes the Excel to disk,
  /// and returns the absolute saved file path (or null if canceled).
  Future<String?> exportAndSaveExcel({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? suggestedFileName,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  });
}
