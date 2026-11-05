import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  test(
    'copyWith can explicitly clear blood transfusion without changing defaults',
    () {
      final patient = PatientStay(
        prefix: Prefix.bo,
        mothersName: 'Example',
        doa: DateTime(2026, 1, 1),
        contactNumber: '1234567890',
        contactRelation: Relation.mother,
        pin: '380001',
        del: 'Hospital',
        bloodTransfusion: true,
      );
      expect(patient.copyWith().bloodTransfusion, isTrue);
      expect(
        patient.copyWith(bloodTransfusion: false).bloodTransfusion,
        isFalse,
      );
      expect(
        patient.copyWith(clearBloodTransfusion: true).bloodTransfusion,
        isNull,
      );
    },
  );

  test('new clinical and developmental fields round-trip through JSON', () {
    final patient = PatientStay(
      prefix: Prefix.bo,
      serialNo: 88,
      mothersName: 'Example',
      babyName: 'B/O Example - A',
      doa: DateTime(2026, 1, 1),
      financialYear: 2025,
      branch: Branch.arpanMother,
      admissionType: AdmissionType.inborn,
      admissionHistory: AdmissionHistory.firstAdmission,
      birthType: BirthType.twin,
      contactNumber: '1234567890',
      contactRelation: Relation.father,
      pin: '380001',
      del: 'Hospital',
      antibiotics: const ['Ampicillin'],
      maternalReceivedAntibiotics: true,
      maternalAntibiotics: const ['Gentamicin', 'Others'],
      maternalAntibioticsOther: 'Cefixime',
      headCircumference: 33.2,
      length: 45.5,
      fileName: 'birth-record.pdf',
      adductaAngle: 'Normal',
      cdcHeadControl: 'Grade II',
      cdcSitting: 'Grade III',
      cdcStanding: 'Grade IV',
      dasiiMotorAgeAt50thCentile: '6 months',
      dasiiMotorAgeAt97thCentile: '8 months',
      dasiiMentalAgeAt50thCentile: '5 months',
      dasiiMentalAgeAt97thCentile: '7 months',
      dischargeType: DischargeType.shift,
      shiftedTo: 'Receiving Hospital',
      shiftReason: 'Higher level of care',
    );

    final restored = PatientStay.fromJson(patient.toJson());

    expect(restored.antibiotics, ['Ampicillin']);
    expect(restored.maternalReceivedAntibiotics, isTrue);
    expect(restored.maternalAntibiotics, ['Gentamicin', 'Others']);
    expect(restored.maternalAntibioticsOther, 'Cefixime');
    expect(restored.babyName, 'B/O Example - A');
    expect(restored.financialYear, 2025);
    expect(restored.branch, Branch.arpanMother);
    expect(restored.admissionType, AdmissionType.inborn);
    expect(restored.admissionHistory, AdmissionHistory.firstAdmission);
    expect(restored.birthType, BirthType.twin);
    expect(restored.dischargeType, DischargeType.shift);
    expect(restored.shiftedTo, 'Receiving Hospital');
    expect(restored.shiftReason, 'Higher level of care');
    expect(restored.headCircumference, 33.2);
    expect(restored.length, 45.5);
    expect(restored.fileName, 'birth-record.pdf');
    expect(restored.adductaAngle, 'Normal');
    expect(restored.cdcHeadControl, 'Grade II');
    expect(restored.cdcSitting, 'Grade III');
    expect(restored.cdcStanding, 'Grade IV');
    expect(restored.dasiiMotorAgeAt50thCentile, '6 months');
    expect(restored.dasiiMotorAgeAt97thCentile, '8 months');
    expect(restored.dasiiMentalAgeAt50thCentile, '5 months');
    expect(restored.dasiiMentalAgeAt97thCentile, '7 months');

    final legacyJson = patient.toJson()..remove('financialYear');
    legacyJson.remove('length');
    final restoredLegacy = PatientStay.fromJson(legacyJson);
    expect(restoredLegacy.serialNo, 88);
    expect(restoredLegacy.financialYear, 2025);
    expect(restoredLegacy.length, isNull);
  });
}
