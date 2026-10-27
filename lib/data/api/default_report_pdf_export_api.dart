import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../backend/reports/report_models.dart';
import '../../features/admissions/models/patient_stay.dart';
import 'report_pdf_export_api.dart';

/// Concrete implementation of ReportPdfExportApi producing publication-quality
/// clinical registry reports with metrics summaries and data tables.
class DefaultReportPdfExportApi implements ReportPdfExportApi {
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF244C5A); // AppTheme.inkTeal
  static const PdfColor _lightBgColor = PdfColor.fromInt(0xFFF4F7F6); // AppTheme.paper
  static const PdfColor _mintBgColor = PdfColor.fromInt(0xFFE3F1EC); // AppTheme.softMint
  static const PdfColor _borderColor = PdfColor.fromInt(0xFFD9E1DF); // AppTheme.hairline
  static const PdfColor _textPrimary = PdfColor.fromInt(0xFF1B2A30);
  static const PdfColor _textSecondary = PdfColor.fromInt(0xFF5B676C);

  @override
  Future<Uint8List> generateReportPdf({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
        boldItalic: pw.Font.helveticaBoldOblique(),
      ),
    );

    final summary = ReportSummary.fromPatients(patients);
    final nowFormatted = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
    final effectiveHospital = hospitalName ?? 'K-TECH CLINICAL REGISTRY - ARPAN NICU & PEDIATRICS';
    final effectiveTitle = reportTitle ?? 'Clinical Admissions & Outcomes Summary Report';
    final isLandscape = columns.length > 5;

    final tableHeaders = columns.map((col) => col.label).toList();
    final tableData = patients.map((patient) {
      return columns.map((col) {
        return col.value(patient, hideIdentifiers: hideIdentifiers);
      }).toList();
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: isLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: _borderColor, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        effectiveHospital,
                        style: pw.TextStyle(
                          color: _primaryColor,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        effectiveTitle,
                        style: pw.TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (filters.description.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Filters: ${filters.description}',
                          style: const pw.TextStyle(
                            color: _textSecondary,
                            fontSize: 7.5,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated: $nowFormatted',
                      style: const pw.TextStyle(
                        color: _textSecondary,
                        fontSize: 7.5,
                      ),
                    ),
                    if (generatedBy != null && generatedBy.isNotEmpty) ...[
                      pw.SizedBox(height: 1),
                      pw.Text(
                        'By: $generatedBy',
                        style: const pw.TextStyle(
                          color: _textSecondary,
                          fontSize: 7.5,
                        ),
                      ),
                    ],
                    if (hideIdentifiers) ...[
                      pw.SizedBox(height: 1),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: pw.BoxDecoration(
                          color: _mintBgColor,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'IDENTIFIERS MASKED',
                          style: pw.TextStyle(
                            color: _primaryColor,
                            fontSize: 6.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: _borderColor, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'CONFIDENTIAL MEDICAL RECORD - STRICTLY FOR AUTHORIZED CLINICAL USE ONLY',
                  style: const pw.TextStyle(
                    color: _textSecondary,
                    fontSize: 6.5,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(
                    color: _primaryColor,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),
            // Metrics summary banner
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: _lightBgColor,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: _borderColor, width: 0.5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricPill('Total Patients', summary.total.toString()),
                  _buildMetricPill('Currently Admitted', summary.admitted.toString()),
                  _buildMetricPill('Discharged', summary.discharged.toString()),
                  _buildMetricPill('Gender (M/F)', '${summary.male} / ${summary.female}'),
                  _buildMetricPill(
                    'Multiples',
                    '${summary.twins} twins, ${summary.triplets} triplets',
                  ),
                  _buildMetricPill('Shifted Out', summary.shifted.toString()),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            // Clinical Data Table
            if (patients.isEmpty)
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(32),
                child: pw.Text(
                  'No patient records match the selected filters.',
                  style: const pw.TextStyle(color: _textSecondary, fontSize: 10),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: tableHeaders,
                data: tableData,
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7.5,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: _primaryColor,
                ),
                headerPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                cellStyle: const pw.TextStyle(
                  color: _textPrimary,
                  fontSize: 7,
                ),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: const pw.BoxDecoration(
                  color: _lightBgColor,
                ),
                border: pw.TableBorder.all(
                  color: _borderColor,
                  width: 0.5,
                ),
              ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildMetricPill(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            color: _textSecondary,
            fontSize: 6.5,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: _primaryColor,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Future<String?> exportAndSavePdf({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? suggestedFileName,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  }) async {
    final pdfBytes = await generateReportPdf(
      patients: patients,
      filters: filters,
      columns: columns,
      hideIdentifiers: hideIdentifiers,
      hospitalName: hospitalName,
      reportTitle: reportTitle,
      generatedBy: generatedBy,
    );

    final defaultName = suggestedFileName ??
        'Clinical_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    final outputUri = await FilePicker.saveFile(
      dialogTitle: 'Save Report PDF',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      bytes: pdfBytes,
    );

    if (outputUri == null) return null;

    final filePath = outputUri.toFilePath();
    final file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsBytes(pdfBytes);
    }
    return filePath;
  }

  @override
  Future<void> printOrPreviewPdf({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? suggestedFileName,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  }) async {
    final pdfBytes = await generateReportPdf(
      patients: patients,
      filters: filters,
      columns: columns,
      hideIdentifiers: hideIdentifiers,
      hospitalName: hospitalName,
      reportTitle: reportTitle,
      generatedBy: generatedBy,
    );

    final title = suggestedFileName ??
        'Clinical_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }
}
