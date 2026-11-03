import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';
import 'package:ktech_project_004/features/discharge/document/discharge_draft.dart';

void main() {
  final admission = PatientStay(
    id: 'admission-1',
    serialNo: 12,
    financialYear: 2026,
    prefix: Prefix.bo,
    mothersName: 'Example Mother',
    doa: DateTime(2026, 10, 1),
    contactNumber: '1234567890',
    contactRelation: Relation.mother,
    pin: '380001',
    del: 'City Hospital',
    birthWeight: 2.4,
    admissionWeight: 2.3,
    sepsis: 'Sepsis',
    user: 'Dr. Example',
  );

  test('defaults and copyWith preserve or replace draft fields', () {
    const initial = DischargeDraft();
    expect(initial.dischargeType, DischargeType.routine);
    expect(initial.sepsis, 'No Sepsis');
    expect(initial.maternalMorbidities, isEmpty);

    final changed = initial.copyWith(
      dischargeType: DischargeType.shift,
      shiftedTo: 'Regional NICU',
      ventilation: ['CPAP'],
      dischargeTime: '10:30',
      treatmentSummary: 'Supportive care',
    );
    expect(changed.dischargeType, DischargeType.shift);
    expect(changed.shiftedTo, 'Regional NICU');
    expect(changed.ventilation, ['CPAP']);
    expect(changed.dischargeTime, '10:30');
    expect(changed.treatmentSummary, 'Supportive care');
    expect(changed.sepsis, initial.sepsis);
  });

  test('fromPatient maps available admission fields and applies defaults', () {
    final draft = DischargeDraft.fromPatient(admission);
    expect(draft.dischargeType, DischargeType.routine);
    expect(draft.conditionAtDischarge, 'Stable');
    expect(draft.finalDiagnosis, 'Sepsis');
    expect(draft.birthWeight, '2.4');
    expect(draft.admissionWeight, '2.3');
    expect(draft.attendingDoctor, 'Dr. Example');
    expect(draft.user, 'Dr. Example');
    expect(draft.sepsis, 'Sepsis');
  });

  test(
    'toDischargeData parses values and conditionally includes shift details',
    () {
      final data = DischargeDraft(
        dischargeDate: DateTime(2026, 10, 8),
        dischargeType: DischargeType.shift,
        stay: '7',
        ipNo: 'IP-123',
        gestAgeWeeks: '34',
        gestAgeDays: '5',
        birthWeight: '1.75',
        admissionWeight: '1.8',
        weightAtDischarge: '2.05',
        headCircumference: '31.5',
        length: '44',
        shiftedTo: 'Regional NICU',
        shiftReason: 'Higher level of care',
        maternalMorbidities: ['Hypertension'],
        respiratorySystem: ['CPAP'],
        antibiotics: ['Ampicillin'],
        feeding: ['Breast milk'],
        sepsis: 'Culture positive',
        remarks: 'Stable for transfer',
        user: 'Dr. Example',
      ).toDischargeData(admission);

      expect(data['dod'], DateTime(2026, 10, 8));
      expect(data['stay'], 7);
      expect(data['gestAgeWeeks'], 34);
      expect(data['gestAgeDays'], 5);
      expect(data['birthWeight'], 1.75);
      expect(data['dischargeWeight'], 2.05);
      expect(data['shiftedTo'], 'Regional NICU');
      expect(data['shiftReason'], 'Higher level of care');
      expect(data['maternalMorbidities'], ['Hypertension']);
      expect(data['respiratorySystem'], ['CPAP']);
      expect(data['antibiotics'], ['Ampicillin']);
      expect(data['feeding'], ['Breast milk']);
      expect(data['remarks'], 'Stable for transfer');
      expect(data['statusOk'], isTrue);
    },
  );

  test('toDischargeData falls back for absent or invalid optional values', () {
    final data = const DischargeDraft(
      dischargeType: DischargeType.routine,
      stay: 'invalid',
      ipNo: '',
      gestAgeWeeks: 'unknown',
      birthWeight: 'unknown',
      shiftedTo: 'ignored',
      shiftReason: 'ignored',
    ).toDischargeData(admission);

    expect(data['stay'], isNonNegative);
    expect(data['ipNo'], isNull);
    expect(data['gestAgeWeeks'], isNull);
    expect(data['birthWeight'], isNull);
    expect(data['shiftedTo'], isNull);
    expect(data['shiftReason'], isNull);
    expect(data['maternalMorbidities'], isNull);
    expect(data['dod'], isA<DateTime>());
  });
}
