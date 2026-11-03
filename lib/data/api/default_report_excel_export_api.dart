import 'dart:io';
import 'dart:typed_data';

import 'package:excel_plus/excel_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../backend/reports/field_config.dart';
import '../../backend/reports/report_models.dart';
import '../../features/admissions/models/patient_stay.dart';
import 'report_excel_export_api.dart';

/// Concrete implementation of ReportExcelExportApi producing Excel reports
/// with Admission and Discharge sheets.
class DefaultReportExcelExportApi implements ReportExcelExportApi {
  @override
  Future<Uint8List> generateReportExcel({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  }) async {
    final excel = Excel.createExcel();

    final effectiveHospital =
        hospitalName ?? 'K-TECH CLINICAL REGISTRY - ARPAN NICU & PEDIATRICS';
    final effectiveTitle =
        reportTitle ?? 'Clinical Admissions & Outcomes Summary Report';
    final nowFormatted = DateFormat('dd MMM yyyy, HH:mm')
        .format(DateTime.now());

    // Get selected fields grouped by Admission/Discharge using shared split function
    final splitFields = FieldConfigRegistry.splitSelectedFieldsByGroup(columns);
    final admissionFields = splitFields.admission;
    final dischargeFields = splitFields.discharge;

    // Create Admission sheet (always create, even if empty, to maintain exactly two sheets)
    final admissionSheet = excel['Admission'];
    _addMetadata(
      admissionSheet,
      effectiveHospital,
      effectiveTitle,
      filters,
      nowFormatted,
      generatedBy,
    );
    _addSheetData(admissionSheet, patients, admissionFields, hideIdentifiers);

    // Create Discharge sheet (always create, even if empty, to maintain exactly two sheets)
    final dischargeSheet = excel['Discharge'];
    _addMetadata(
      dischargeSheet,
      effectiveHospital,
      effectiveTitle,
      filters,
      nowFormatted,
      generatedBy,
    );
    _addSheetData(dischargeSheet, patients, dischargeFields, hideIdentifiers);

    excel.delete('Sheet1');

    // Save to bytes
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to encode Excel file');
    }
    return Uint8List.fromList(bytes);
  }

  void _addMetadata(
    Sheet sheet,
    String hospitalName,
    String reportTitle,
    ReportFilters filters,
    String generatedTime,
    String? generatedBy,
  ) {
    // Add metadata rows at the top with centered title
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      hospitalName,
    );
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
      reportTitle,
    );
    sheet.cell(CellIndex.indexByString('A2')).cellStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
      'Generated: $generatedTime',
    );
    if (generatedBy != null && generatedBy.isNotEmpty) {
      sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue(
        'By: $generatedBy',
      );
    }
    if (filters.description.isNotEmpty) {
      sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue(
        'Filters: ${filters.description}',
      );
    }
    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue(
      'CONFIDENTIAL MEDICAL RECORD - STRICTLY FOR AUTHORIZED CLINICAL USE ONLY',
    );
    sheet.cell(CellIndex.indexByString('A6')).cellStyle = CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Center,
    );
  }

  void _addSheetData(
    Sheet sheet,
    List<PatientStay> patients,
    List<FieldConfig> fields,
    bool hideIdentifiers,
  ) {
    // Determine starting row after metadata (row 7)
    const headerRow = 7;

    final orderedFields = <FieldConfig>[
      FieldConfigRegistry.getConfig(ReportColumn.serialNumber)!,
      FieldConfigRegistry.getConfig(ReportColumn.babyName)!,
    ];
    for (final field in fields) {
      if (field.column != ReportColumn.serialNumber &&
          field.column != ReportColumn.babyName) {
        orderedFields.add(field);
      }
    }

    // Calculate column widths based on content
    final columnWidths = _calculateColumnWidths(
      orderedFields,
      patients,
      hideIdentifiers,
    );

    // Add header row with styling
    for (var i = 0; i < orderedFields.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: headerRow),
      );
      cell.value = TextCellValue(orderedFields[i].label);

      // Style header
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#244C5A'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      // Set column width
      sheet.setColumnWidth(i, columnWidths[i]);
    }

    // Add data rows with proper data types
    for (var patientIndex = 0; patientIndex < patients.length; patientIndex++) {
      final patient = patients[patientIndex];
      final rowIndex = headerRow + 1 + patientIndex;

      for (var colIndex = 0; colIndex < orderedFields.length; colIndex++) {
        final field = orderedFields[colIndex];
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
        );

        final value = FieldConfigRegistry.excelValue(
          field,
          patient,
          hideIdentifiers: hideIdentifiers,
        );
        cell.value = switch (value) {
          null => TextCellValue(''),
          DateTime date => DateCellValue.fromDateTime(date),
          int number => IntCellValue(number),
          num number => DoubleCellValue(number.toDouble()),
          bool boolean => BoolCellValue(boolean),
          _ => TextCellValue(value.toString()),
        };
        cell.cellStyle = CellStyle(
          textWrapping: TextWrapping.WrapText,
          verticalAlign: VerticalAlign.Top,
          numberFormat: field.dataType == FieldDataType.date
              ? NumFormat.defaultDate
              : NumFormat.defaultFloat,
        );
      }
    }

    // Estimate wrapped row height from the longest visible cell in each row.
    for (var i = 0; i < patients.length; i++) {
      final patient = patients[i];
      var lineCount = 1;
      for (
        var columnIndex = 0;
        columnIndex < orderedFields.length;
        columnIndex++
      ) {
        final field = orderedFields[columnIndex];
        final value = FieldConfigRegistry.excelValue(
          field,
          patient,
          hideIdentifiers: hideIdentifiers,
        );
        final width = columnWidths[columnIndex];
        final charsPerLine = (width * 1.15).floor().clamp(8, 70);
        final valueLines = ((value?.toString().length ?? 0) / charsPerLine)
            .ceil();
        if (valueLines > lineCount) lineCount = valueLines;
      }
      sheet.setRowHeight(
        headerRow + 1 + i,
        (lineCount * 15 + 10).clamp(25, 240).toDouble(),
      );
    }

    // Freeze header row and first two columns
    sheet.freezePanes(rows: headerRow + 1, columns: 2);

    // Enable AutoFilter
    sheet.setAutoFilter(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: headerRow),
      CellIndex.indexByColumnRow(
        columnIndex: orderedFields.length - 1,
        rowIndex: headerRow + patients.length,
      ),
    );
  }

  List<double> _calculateColumnWidths(
    List<FieldConfig> fields,
    List<PatientStay> patients,
    bool hideIdentifiers,
  ) {
    final widths = <double>[];

    for (final field in fields) {
      // Start with header length
      int maxLength = field.label.length;

      // Check all values in this column
      for (final patient in patients) {
        final value = field.column.value(
          patient,
          hideIdentifiers: hideIdentifiers,
        );
        if (value.length > maxLength) {
          maxLength = value.length;
        }
      }

      // Calculate width based on character count (approximate)
      // Minimum width of 12, maximum of 50
      double width = (maxLength * 1.5).toDouble();
      width = width.clamp(14.0, 60.0);

      // Special handling for known long fields
      if (field.dataType == FieldDataType.text ||
          field.dataType == FieldDataType.list) {
        width = width.clamp(24.0, 60.0);
      }

      widths.add(width);
    }

    return widths;
  }

  @override
  Future<String?> exportAndSaveExcel({
    required List<PatientStay> patients,
    required ReportFilters filters,
    required List<ReportColumn> columns,
    required bool hideIdentifiers,
    String? suggestedFileName,
    String? hospitalName,
    String? reportTitle,
    String? generatedBy,
  }) async {
    final excelBytes = await generateReportExcel(
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
        'Clinical_Report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';

    final outputUri = await FilePicker.saveFile(
      dialogTitle: 'Save Report Excel',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: excelBytes,
    );

    if (outputUri == null) return null;

    final filePath = outputUri.toFilePath();
    final file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsBytes(excelBytes);
    }
    return filePath;
  }
}
