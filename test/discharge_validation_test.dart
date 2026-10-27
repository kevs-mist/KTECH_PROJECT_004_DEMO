import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/core/discharge_validation.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  group('Shift discharge validation', () {
    test('requires the destination hospital when Shift is selected', () {
      expect(
        validateShiftDetails(
          dischargeType: DischargeType.shift,
          hospital: ' ',
          reason: 'Clinical escalation',
        ),
        'Hospital the baby was shifted to is required',
      );
    });

    test('requires the shift reason when Shift is selected', () {
      expect(
        validateShiftDetails(
          dischargeType: DischargeType.shift,
          hospital: 'Receiving Hospital',
          reason: '',
        ),
        'Reason for shifting is required',
      );
    });

    test('does not require Shift fields for other discharge types', () {
      expect(
        validateShiftDetails(
          dischargeType: DischargeType.routine,
          hospital: '',
          reason: '',
        ),
        isNull,
      );
    });
  });
}
