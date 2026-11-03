import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/data/api/admissions_api.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';
import 'package:ktech_project_004/features/discharge/document/discharge_draft.dart';
import 'package:ktech_project_004/features/discharge/document/local_discharge_document_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final admission = Admission(
    id: 'doc-1',
    serialNo: 9,
    financialYear: 2026,
    prefix: Prefix.bo,
    mothersName: 'Example Mother',
    doa: DateTime(2026, 10, 1),
    contactNumber: '1234567890',
    contactRelation: Relation.mother,
    pin: '380001',
    del: 'City Hospital',
    branch: Branch.arpanMother,
    ipNo: 'IP 123',
  );

  test(
    'suggested filename sanitizes the patient name and uses discharge date',
    () {
      final api = LocalDischargeDocumentApi();
      final namedAdmission = Admission(
        id: admission.id,
        serialNo: admission.serialNo,
        financialYear: admission.financialYear,
        prefix: admission.prefix,
        mothersName: 'Example Mother',
        babyName: 'Baby / Example',
        doa: admission.doa,
        contactNumber: admission.contactNumber,
        contactRelation: admission.contactRelation,
        pin: admission.pin,
        del: admission.del,
      );

      expect(
        api.suggestedFileName(
          namedAdmission,
          DischargeDraft(dischargeDate: DateTime(2026, 10, 8)),
        ),
        'Discharge_Baby_Example_20261008.pdf',
      );
    },
  );

  test(
    'renderPdf returns PDF bytes for routine and transfer summaries',
    () async {
      final api = LocalDischargeDocumentApi();
      final routinePdf = await api.renderPdf(
        admission,
        DischargeDraft(
          dischargeDate: DateTime(2026, 10, 8),
          finalDiagnosis: 'Neonatal sepsis',
          treatmentSummary: 'Antibiotics and respiratory support',
          adviceOnDischarge: 'Continue follow-up',
        ),
      );
      final transferPdf = await api.renderPdf(
        admission,
        const DischargeDraft(
          dischargeType: DischargeType.shift,
          shiftedTo: 'Regional NICU',
          shiftReason: 'Higher level of care',
        ),
      );

      expect(ascii.decode(routinePdf.sublist(0, 4)), '%PDF');
      expect(ascii.decode(transferPdf.sublist(0, 4)), '%PDF');
      expect(routinePdf, isNotEmpty);
      expect(transferPdf, isNotEmpty);
    },
  );
}
