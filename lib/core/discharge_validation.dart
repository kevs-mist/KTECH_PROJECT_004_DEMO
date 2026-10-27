import '../features/admissions/models/patient_stay.dart';

String? validateShiftDetails({
  required DischargeType dischargeType,
  required String hospital,
  required String reason,
}) {
  if (dischargeType != DischargeType.shift) {
    return null;
  }
  if (hospital.trim().isEmpty) {
    return 'Hospital the baby was shifted to is required';
  }
  if (reason.trim().isEmpty) {
    return 'Reason for shifting is required';
  }
  return null;
}
