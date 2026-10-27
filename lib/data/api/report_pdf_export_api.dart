import 'dart:typed_data';

import '../../backend/reports/report_models.dart';
import '../../features/admissions/models/patient_stay.dart';

/// Abstract contract for generating, saving, and printing report PDF documents.
abstract class ReportPdfExportApi {
  /// Generates the binary PDF document bytes for the specified report data.
  Future<Uint8List> generateReportPdf({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  });

  /// Prompts the user with a file save dialog, writes the PDF to disk,
  /// and returns the absolute saved file path (or null if canceled).
  Future<String?> exportAndSavePdf({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? suggestedFileName,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  });

  /// Opens the system print or PDF preview dialog.
  Future<void> printOrPreviewPdf({
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
