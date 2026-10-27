import '../../data/api/admissions_api.dart';
import '../../data/api/mock_admissions_api.dart';
import '../../features/admissions/models/patient_stay.dart';
import 'admissions_repository.dart';
import 'local_patient_stay_store.dart';

/// Thin adapter implementing AdmissionsRepository by delegating to AdmissionsApi.
/// Owns no list or seed data of its own.
class DemoAdmissionsRepository implements AdmissionsRepository {
  final AdmissionsApi _api;

  DemoAdmissionsRepository([AdmissionsApi? api])
      : _api = api ?? MockAdmissionsApi(latency: Duration.zero);

  DemoAdmissionsRepository.withStore({PatientStayStore? store})
      : _api = MockAdmissionsApi(latency: Duration.zero, store: store);

  @override
  Future<List<PatientStay>> getAllPatients() {
    return _api.listAdmissions();
  }

  @override
  Future<List<PatientStay>> getAdmittedPatients() {
    return _api.listAdmissions(dischargedOnly: false);
  }

  @override
  Future<List<PatientStay>> getDischargedPatients() {
    return _api.listAdmissions(dischargedOnly: true);
  }

  @override
  Future<List<PatientStay>> searchPatients(String query) {
    return _api.listAdmissions(query: query);
  }

  @override
  Future<PatientStay?> getPatientById(String id) {
    return _api.getAdmission(id);
  }

  @override
  Future<PatientStay> createAdmission(PatientStay patient) {
    return _api.createAdmission(patient);
  }

  @override
  Future<PatientStay> updatePatient(PatientStay patient) async {
    final id = patient.id ?? '';
    return _api.dischargeAdmission(id, {'patient': patient});
  }

  @override
  Future<int> getNextSerialNumber(int financialYear) async {
    final all = await _api.listAdmissions();
    final maxSerial = all
        .where(
          (patient) =>
              (patient.financialYear ??
                  (patient.doa.month >= 4
                      ? patient.doa.year
                      : patient.doa.year - 1)) ==
              financialYear,
        )
        .map((patient) => patient.serialNo ?? 0)
        .fold<int>(0, (maximum, serial) => serial > maximum ? serial : maximum);
    return maxSerial + 1;
  }

  @override
  Future<int> getAdmissionsCount(DateTime start, DateTime end) async {
    final all = await _api.listAdmissions(from: start, to: end);
    return all.length;
  }

  @override
  Future<int> getDischargesCount(DateTime start, DateTime end) async {
    final discharges =
        await _api.listAdmissions(from: start, to: end, dischargedOnly: true);
    return discharges.length;
  }

  @override
  Future<double> getAverageDaysStayed(DateTime start, DateTime end) async {
    final dischargedInRange =
        await _api.listAdmissions(from: start, to: end, dischargedOnly: true);
    if (dischargedInRange.isEmpty) return 0.0;
    final totalDays = dischargedInRange.fold<int>(
      0,
      (sum, p) => sum + p.daysStayed,
    );
    return totalDays / dischargedInRange.length;
  }

  @override
  Future<void> clearAllData() async {
    _api.clear();
  }
}
