import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/api/admissions_api.dart';
import '../../admissions/models/patient_stay.dart';
import 'discharge_document_api.dart';
import 'discharge_draft.dart';

class LocalDischargeDocumentApi implements DischargeDocumentApi {
  pw.Font? _base;
  pw.Font? _gujarati;

  Future<void> _loadFonts() async {
    try {
      _base ??= pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
      _gujarati ??=
          pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansGujarati-Regular.ttf'));
    } catch (_) {
      // Falls back to the built-in Helvetica (Latin only).
    }
  }

  @override
  String suggestedFileName(Admission a, DischargeDraft d) {
    final date = DateFormat('yyyyMMdd').format(d.dischargeDate ?? DateTime.now());
    final safe = a.displayName.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    return 'Discharge_${safe}_$date.pdf';
  }

  @override
  Future<Uint8List> renderPdf(Admission a, DischargeDraft d) async {
    await _loadFonts();
    final theme = pw.ThemeData.withFont(
      base: _base,
      bold: _base,
      fontFallback: [?_gujarati],
    );
    final df = DateFormat('dd MMM yyyy');
    String dt(DateTime? v) => v == null ? '-' : df.format(v);
    String s(String? v) => (v == null || v.trim().isEmpty) ? '-' : v.trim();

    const primaryColor = PdfColor.fromInt(0xFF244C5A); // AppTheme.inkTeal
    const lightBg = PdfColor.fromInt(0xFFF4F7F6);
    const borderColor = PdfColor.fromInt(0xFFD9E1DF);

    pw.Widget row(String k, String v) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 140,
                child: pw.Text(
                  k,
                  style: pw.TextStyle(
                    color: PdfColors.grey700,
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  v,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
        );

    pw.Widget section(String title, List<pw.Widget> children) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: const pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    title.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            pw.Divider(color: borderColor, thickness: 0.5),
            ...children,
          ],
        );

    final doc = pw.Document(theme: theme, title: 'Discharge Summary');

    final stayDays = d.stay?.isNotEmpty == true
        ? '${d.stay} days'
        : (d.dischargeDate != null
            ? '${d.dischargeDate!.difference(a.doa).inDays} days'
            : (a.stay != null ? '${a.stay} days' : '-'));

    final branchName = switch (a.branch) {
      Branch.arpanMother => 'Arpan Mother Care Hospital',
      Branch.arpanViolet => 'Arpan Violet Pediatric Unit',
      _ => 'Arpan Newborn Care Center',
    };

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      branchName.toUpperCase(),
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 1),
                    pw.Text(
                      d.dischargeType == DischargeType.shift
                          ? 'PATIENT TRANSFER / SHIFT SUMMARY'
                          : 'NEONATAL DISCHARGE SUMMARY',
                      style: pw.TextStyle(
                        color: PdfColors.grey800,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'IP No: ${s(d.ipNo.isNotEmpty ? d.ipNo : a.ipNo)}',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Sr No: ${a.financialYear ?? ''} / ${a.serialNo ?? '-'}',
                      style: const pw.TextStyle(
                        color: PdfColors.grey700,
                        fontSize: 8,
                      ),
                    ),
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
              border: pw.Border(top: pw.BorderSide(color: borderColor, width: 0.5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'CONFIDENTIAL MEDICAL RECORD - VALID WITH AUTHORIZED CLINICAL SIGNATURE',
                  style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 6.5),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(
                    color: primaryColor,
                    fontSize: 7.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Patient Identification
            section('1. Patient Identification', [
              row('Baby of / Child Name:', s(a.babyNameWithPrefix)),
              row("Mother's Name:", s(a.mothersName)),
              row('Gender / Birth Type:',
                  '${s(d.sex?.name ?? a.sex?.name)} / ${s(a.birthType?.name)}'),
              row('Date of Birth:', dt(d.dateOfBirth ?? a.dateOfBirth)),
              row('Contact Number:',
                  '${a.contactNumber} (${a.contactRelation.name})'),
              if (a.contactNumber2 != null && a.contactNumber2!.isNotEmpty)
                row('Secondary Contact:',
                    '${a.contactNumber2} (${a.contactRelation2?.name ?? ""})'),
              row('Residential Address:',
                  '${s(a.address)} ${s(a.area)} ${s(a.city)} ${s(a.pin)}'),
            ]),

            // Hospital Stay Timeline
            section('2. Hospital Stay Details', [
              row('Date of Admission (DOA):', dt(a.doa)),
              row('Date of Discharge (DOD):', dt(d.dischargeDate ?? a.dod)),
              if (d.dischargeTime != null && d.dischargeTime!.isNotEmpty)
                row('Time of Discharge:', s(d.dischargeTime)),
              row('Total Duration of Stay:', stayDays),
              row('Discharge Type:', s(d.dischargeType.name.toUpperCase())),
              if (d.dischargeType == DischargeType.shift) ...[
                row('Shifted / Transferred To:', s(d.shiftedTo)),
                row('Reason for Transfer:', s(d.shiftReason)),
              ],
              row('Condition at Discharge:',
                  d.conditionAtDischarge.isNotEmpty
                      ? d.conditionAtDischarge
                      : (d.dischargeType == DischargeType.expired ? 'Expired' : 'Stable')),
            ]),

            // Birth History & Initial Vitals
            section('3. Birth History & Anthropometry', [
              row('Place of Delivery:',
                  s(d.placeOfDeliveryDischarge ?? a.del)),
              row('Mode of Delivery:', s(d.modeOfDelivery?.name ?? a.modeOfDelivery?.name)),
              row('Gestational Age:',
                  '${s(d.gestAgeWeeks.isNotEmpty ? d.gestAgeWeeks : a.gestAgeWeeks?.toString())} weeks ${s(d.gestAgeDays.isNotEmpty ? d.gestAgeDays : a.gestAgeDays?.toString())} days'),
              row('Birth Weight:',
                  '${s(d.birthWeight.isNotEmpty ? d.birthWeight : a.birthWeight?.toStringAsFixed(3))} kg'),
              row('Admission Weight:',
                  '${s(d.admissionWeight.isNotEmpty ? d.admissionWeight : a.admissionWeight?.toStringAsFixed(3))} kg'),
              row('Discharge Weight:',
                  '${s(d.weightAtDischarge.isNotEmpty ? d.weightAtDischarge : a.dischargeWeight?.toStringAsFixed(3))} kg'),
              row('Weight Percentile:', s(d.weightPercentile?.name ?? a.weightPercentile?.name)),
              row('Length / Head Circumference:',
                  'Length: ${s(d.length.isNotEmpty ? d.length : a.length?.toStringAsFixed(1))} cm | Head: ${s(d.headCircumference.isNotEmpty ? d.headCircumference : a.headCircumference?.toStringAsFixed(1))} cm'),
            ]),

            // Clinical Course & Diagnoses
            section('4. Clinical Course & Diagnoses', [
              if (d.finalDiagnosis.isNotEmpty)
                row('Final Diagnosis:', d.finalDiagnosis)
              else if (a.sepsis != null && a.sepsis!.isNotEmpty)
                row('Primary Diagnosis:', a.sepsis!),
              if (d.maternalMorbidities.isNotEmpty ||
                  (a.maternalMorbidities != null && a.maternalMorbidities!.isNotEmpty))
                row('Maternal Morbidities:',
                    (d.maternalMorbidities.isNotEmpty
                            ? d.maternalMorbidities
                            : a.maternalMorbidities!)
                        .join(', ')),
              if (d.respiratorySystem.isNotEmpty ||
                  (a.respiratorySystem != null && a.respiratorySystem!.isNotEmpty))
                row('Respiratory System Support:',
                    (d.respiratorySystem.isNotEmpty
                            ? d.respiratorySystem
                            : a.respiratorySystem!)
                        .join(', ')),
              if (d.surfactant != null || a.surfactant != null)
                row('Surfactant Therapy:',
                    s((d.surfactant ?? a.surfactant)?.name)),
              if (d.ventilation.isNotEmpty ||
                  (a.ventilation != null && a.ventilation!.isNotEmpty))
                row('Mechanical Ventilation:',
                    (d.ventilation.isNotEmpty ? d.ventilation : a.ventilation!)
                        .join(', ')),
              row('Infection / Sepsis Status:',
                  '${s(d.sepsis.isNotEmpty ? d.sepsis : a.sepsis)} ${d.organism.isNotEmpty ? "(${d.organism})" : (a.organism != null ? "(${a.organism})" : "")}'),
              if (d.antibiotics.isNotEmpty ||
                  (a.antibiotics != null && a.antibiotics!.isNotEmpty))
                row('Antibiotics Administered:',
                    (d.antibiotics.isNotEmpty ? d.antibiotics : a.antibiotics!)
                        .join(', ')),
              if (d.feeding.isNotEmpty ||
                  (a.feeding != null && a.feeding!.isNotEmpty))
                row('Enteral / Parenteral Feeding:',
                    (d.feeding.isNotEmpty ? d.feeding : a.feeding!).join(', ')),
              if (d.rtfStarted.isNotEmpty || d.fullFeedsReached.isNotEmpty)
                row('Feed Milestones:',
                    'RTF: ${s(d.rtfStarted)} | Full Feeds: ${s(d.fullFeedsReached)}'),
              if (d.bpd != null || a.bpd != null)
                row('Bronchopulmonary Dysplasia (BPD):',
                    s((d.bpd ?? a.bpd)?.name)),
              if (d.rop != null || a.rop != null)
                row('Retinopathy of Prematurity (ROP):',
                    s((d.rop ?? a.rop)?.name)),
              if (d.usgHead.isNotEmpty || a.usgHead != null)
                row('Neurosonogram (USG Head):',
                    s(d.usgHead.isNotEmpty ? d.usgHead : a.usgHead)),
            ]),

            // Treatment & Discharge Advice
            section('5. Treatment Given & Advice on Discharge', [
              if (d.treatmentSummary.isNotEmpty)
                row('Treatment Summary:', d.treatmentSummary),
              if (d.adviceOnDischarge.isNotEmpty)
                row('Advice on Discharge:', d.adviceOnDischarge),
              if (d.followUpDate.isNotEmpty)
                row('Follow-up Appointment:', d.followUpDate),
              row('Attending Doctor / Neonatologist:',
                  s(d.attendingDoctor.isNotEmpty
                      ? d.attendingDoctor
                      : (d.user.isNotEmpty ? d.user : a.user))),
              if (d.remarks.isNotEmpty || (a.remarks != null && a.remarks!.isNotEmpty))
                row('Clinical Remarks:', s(d.remarks.isNotEmpty ? d.remarks : a.remarks)),
            ]),

            pw.SizedBox(height: 24),
            // Signatures block
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(width: 150, child: pw.Divider(color: borderColor)),
                    pw.Text(
                      'Resident Medical Officer (RMO)',
                      style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 8),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(width: 150, child: pw.Divider(color: borderColor)),
                    pw.Text(
                      'Consultant Neonatologist',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  @override
  Future<File> saveToTemp(Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Future<void> openExternally(File file) async {
    final uri = Uri.file(file.path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Future<void> printPdf(Uint8List bytes, String jobName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: jobName,
    );
  }
}
