import 'admissions_repository.dart';
import 'demo_admissions_repository.dart';
import '../../features/admissions/models/patient_stay.dart';

/// Mock API adapter used until a real backend is available.
class ApiAdmissionsRepository implements AdmissionsRepository {
  final DemoAdmissionsRepository _mockStore;

  ApiAdmissionsRepository(this._mockStore);

  @override
  Future<List<PatientStay>> getAllPatients() => _mockStore.getAllPatients();

  @override
  Future<List<PatientStay>> getAdmittedPatients() =>
      _mockStore.getAdmittedPatients();

  @override
  Future<List<PatientStay>> getDischargedPatients() =>
      _mockStore.getDischargedPatients();

  @override
  Future<List<PatientStay>> searchPatients(String query) =>
      _mockStore.searchPatients(query);

  @override
  Future<PatientStay?> getPatientById(String id) =>
      _mockStore.getPatientById(id);

  @override
  Future<PatientStay> createAdmission(PatientStay patient) =>
      _mockStore.createAdmission(patient);

  @override
  Future<PatientStay> updatePatient(PatientStay patient) =>
      _mockStore.updatePatient(patient);

  @override
  Future<int> getNextSerialNumber(int financialYear) =>
      _mockStore.getNextSerialNumber(financialYear);

  @override
  Future<int> getAdmissionsCount(DateTime start, DateTime end) =>
      _mockStore.getAdmissionsCount(start, end);

  @override
  Future<int> getDischargesCount(DateTime start, DateTime end) =>
      _mockStore.getDischargesCount(start, end);

  @override
  Future<double> getAverageDaysStayed(DateTime start, DateTime end) =>
      _mockStore.getAverageDaysStayed(start, end);

  @override
  Future<void> clearAllData() => _mockStore.clearAllData();
}
