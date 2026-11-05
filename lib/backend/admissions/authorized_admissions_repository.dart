import '../../features/admissions/models/patient_stay.dart';
import 'admissions_repository.dart';

/// Thrown when a role without write permission attempts to mutate
/// clinical records at the data layer.
class SecurityException implements Exception {
  final String message;

  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

/// Wraps an [AdmissionsRepository] and enforces write permissions for
/// mutating operations. Read operations are always allowed so that
/// read-only clinical staff can still view the register.
class AuthorizedAdmissionsRepository implements AdmissionsRepository {
  final AdmissionsRepository _inner;
  final bool canWrite;

  const AuthorizedAdmissionsRepository(this._inner, {required this.canWrite});

  void _requireWrite() {
    if (!canWrite) {
      throw const SecurityException(
        'Your role does not have permission to modify patient records',
      );
    }
  }

  @override
  Future<List<PatientStay>> getAllPatients() => _inner.getAllPatients();

  @override
  Future<List<PatientStay>> getAdmittedPatients() =>
      _inner.getAdmittedPatients();

  @override
  Future<List<PatientStay>> getDischargedPatients() =>
      _inner.getDischargedPatients();

  @override
  Future<List<PatientStay>> searchPatients(String query) =>
      _inner.searchPatients(query);

  @override
  Future<PatientStay?> getPatientById(String id) => _inner.getPatientById(id);

  @override
  Future<PatientStay> createAdmission(PatientStay patient) {
    _requireWrite();
    return _inner.createAdmission(patient);
  }

  @override
  Future<PatientStay> updateAdmission(PatientStay patient) {
    _requireWrite();
    return _inner.updateAdmission(patient);
  }

  @override
  Future<PatientStay> updatePatient(PatientStay patient) {
    _requireWrite();
    return _inner.updatePatient(patient);
  }

  @override
  Future<int> getNextSerialNumber(int financialYear) =>
      _inner.getNextSerialNumber(financialYear);

  @override
  Future<int> getAdmissionsCount(DateTime start, DateTime end) =>
      _inner.getAdmissionsCount(start, end);

  @override
  Future<int> getDischargesCount(DateTime start, DateTime end) =>
      _inner.getDischargesCount(start, end);

  @override
  Future<double> getAverageDaysStayed(DateTime start, DateTime end) =>
      _inner.getAverageDaysStayed(start, end);

  @override
  Future<void> clearAllData() => _inner.clearAllData();
}
