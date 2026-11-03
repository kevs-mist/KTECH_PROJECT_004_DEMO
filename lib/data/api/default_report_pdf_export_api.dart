import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../backend/reports/field_config.dart';
import '../../backend/reports/report_models.dart';
import '../../features/admissions/models/patient_stay.dart';
import 'report_pdf_export_api.dart';

/// Concrete implementation of ReportPdfExportApi producing publication-quality
/// clinical registry reports with metrics summaries and data tables.
class DefaultReportPdfExportApi implements ReportPdfExportApi {
  pw.Font? _baseFont;
  pw.Font? _gujaratiFont;

  static const PdfColor _primaryColor = PdfColor.fromInt(
    0xFF244C5A,
  ); // AppTheme.inkTeal
  static const PdfColor _lightBgColor = PdfColor.fromInt(
    0xFFF4F7F6,
  ); // AppTheme.paper
  static const PdfColor _mintBgColor = PdfColor.fromInt(
    0xFFE3F1EC,
  ); // AppTheme.softMint
  static const PdfColor _borderColor = PdfColor.fromInt(
    0xFFD9E1DF,
  ); // AppTheme.hairline
  static const PdfColor _textPrimary = PdfColor.fromInt(0xFF1B2A30);
  static const PdfColor _textSecondary = PdfColor.fromInt(0xFF5B676C);

  Future<void> _loadFonts() async {
    _baseFont ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    _gujaratiFont ??= pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansGujarati-Regular.ttf'),
    );
  }

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
    await _loadFonts();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: _baseFont,
        bold: _baseFont,
        italic: _baseFont,
        boldItalic: _baseFont,
        fontFallback: [_gujaratiFont!],
      ),
    );

    final nowFormatted = DateFormat('dd MMM yyyy, HH:mm')
        .format(DateTime.now());
    final effectiveHospital =
        hospitalName ?? 'K-TECH CLINICAL REGISTRY - ARPAN NICU & PEDIATRICS';
    final effectiveTitle = reportTitle ?? 'Data For a Quick Glance';
    final selectedFields = FieldConfigRegistry.splitSelectedFieldsByGroup(
      columns,
    );
    final fieldGroups = [
      (title: 'Admission Form', fields: selectedFields.admission),
      (title: 'Discharge Form', fields: selectedFields.discharge),
    ];

    for (var groupIndex = 0; groupIndex < fieldGroups.length; groupIndex++) {
      final group = fieldGroups[groupIndex];
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.fromLTRB(16, 16, 16, 22),
          header: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                effectiveHospital,
                effectiveTitle,
                filters,
                nowFormatted,
                generatedBy,
                hideIdentifiers,
                formType: group.title,
              ),
              pw.SizedBox(height: 8),
            ],
          ),
          footer: _buildFooter,
          build: (pw.Context context) => [
            if (group.fields.isEmpty)
              pw.Text(
                'No selected fields for this form',
                style: const pw.TextStyle(color: _textSecondary, fontSize: 9),
              )
            else
              _buildQuickGlanceTable(
                patients,
                group.fields,
                hideIdentifiers,
              ),
          ],
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildQuickGlanceTable(
    List<PatientStay> patients,
    List<FieldConfig> fields,
    bool hideIdentifiers,
  ) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _primaryColor),
        children: [
          for (final field in fields)
            _buildTableCell(
              field.label,
              header: true,
              emphasize:
                  field.column == ReportColumn.serialNumber ||
                  field.column == ReportColumn.babyName,
            ),
        ],
      ),
      for (var index = 0; index < patients.length; index++)
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: index.isEven ? PdfColors.white : _lightBgColor,
          ),
          children: [
            for (final field in fields)
              _buildTableCell(
                field.column.value(
                  patients[index],
                  hideIdentifiers: hideIdentifiers,
                ),
                emphasize:
                    field.column == ReportColumn.serialNumber ||
                    field.column == ReportColumn.babyName,
              ),
          ],
        ),
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      columnWidths: {
        for (var index = 0; index < fields.length; index++)
          index: pw.FlexColumnWidth(
            fields[index].column == ReportColumn.babyName ? 1.5 : 1,
          ),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  pw.Widget _buildTableCell(
    String value, {
    bool header = false,
    bool emphasize = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
      child: pw.Text(
        value.isEmpty ? '-' : value,
        maxLines: 3,
        style: pw.TextStyle(
          color: header ? PdfColors.white : _textPrimary,
          fontSize: header ? 6.5 : 6,
          fontWeight: header || emphasize
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildHeader(
    String hospitalName,
    String reportTitle,
    ReportFilters filters,
    String generatedTime,
    String? generatedBy,
    bool hideIdentifiers, {
    String? formType,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _borderColor, width: 1)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      hospitalName,
                      style: pw.TextStyle(
                        color: _primaryColor,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      reportTitle,
                      style: pw.TextStyle(
                        color: _textPrimary,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (formType != null) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        formType,
                        style: pw.TextStyle(
                          color: _primaryColor,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
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
                    'Generated: $generatedTime',
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
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
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
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'CONFIDENTIAL MEDICAL RECORD - STRICTLY FOR AUTHORIZED CLINICAL USE ONLY',
            style: const pw.TextStyle(color: _textSecondary, fontSize: 6.5),
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

    final defaultName =
        suggestedFileName ??
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

    final title =
        suggestedFileName ??
        'Clinical_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }
}
