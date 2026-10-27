import '../../features/admissions/models/patient_stay.dart';

abstract class AdmissionsRepository {
  // Get all patient stays
  Future<List<PatientStay>> getAllPatients();

  // Get admitted patients (dod is null)
  Future<List<PatientStay>> getAdmittedPatients();

  // Get discharged patients (dod is not null)
  Future<List<PatientStay>> getDischargedPatients();

  // Search patients by mother's name, contact numbers, or IP No
  Future<List<PatientStay>> searchPatients(String query);

  // Get patient by ID
  Future<PatientStay?> getPatientById(String id);

  // Create new admission
  Future<PatientStay> createAdmission(PatientStay patient);

  // Update patient (for discharge)
  Future<PatientStay> updatePatient(PatientStay patient);

  // Get next serial number for a financial year
  Future<int> getNextSerialNumber(int financialYear);

  // Get admissions count for a date range
  Future<int> getAdmissionsCount(DateTime start, DateTime end);

  // Get discharges count for a date range
  Future<int> getDischargesCount(DateTime start, DateTime end);

  // Get average days stayed for discharged patients in a date range
  Future<double> getAverageDaysStayed(DateTime start, DateTime end);

  // Clear all data (for demo mode logout)
  Future<void> clearAllData();
}
