import '../../features/admissions/models/patient_stay.dart';

typedef Admission = PatientStay;

class MockApiException implements Exception {
  final String message;
  const MockApiException(this.message);

  @override
  String toString() => 'MockApiException: $message';
}

abstract class AdmissionsApi {
  Future<List<Admission>> listAdmissions({
    String? query,
    String? branch,
    DateTime? from,
    DateTime? to,
    bool? dischargedOnly,
  });
  Future<Admission?> getAdmission(String id);
  Future<Admission> createAdmission(Admission admission);
  Future<Admission> dischargeAdmission(String id, Map<String, dynamic> dischargeData);
  Future<DashboardStats> getDashboardStats();
  void reset();
  void clear();
}

class DashboardStats {
  final int totalAdmissions;
  final int totalDischarges;
  final int currentlyAdmitted;
  final Map<String, int> admissionsByMonth; // key: yyyy-MM
  final Map<String, int> dischargesByMonth;
  final Map<String, int> admissionsByDay; // key: yyyy-MM-dd
  final Map<String, int> dischargesByDay;
  final Map<String, int> admissionsByYear; // key: yyyy
  final Map<String, int> dischargesByYear;

  const DashboardStats({
    required this.totalAdmissions,
    required this.totalDischarges,
    required this.currentlyAdmitted,
    required this.admissionsByMonth,
    required this.dischargesByMonth,
    required this.admissionsByDay,
    required this.dischargesByDay,
    required this.admissionsByYear,
    required this.dischargesByYear,
  });
}
