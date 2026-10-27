import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/admissions/admissions_repository.dart';
import '../../backend/admissions/api_admissions_repository.dart';
import '../../backend/admissions/demo_admissions_repository.dart';
import '../../backend/admissions/local_patient_stay_store.dart';
import '../../backend/reports/mock_report_repository.dart';
import '../../features/admissions/models/patient_stay.dart';
import '../../features/auth/auth_controller.dart';
import '../api/admissions_api.dart';
import '../api/default_report_pdf_export_api.dart';
import '../api/mock_admissions_api.dart';
import '../api/mock_auth_api.dart';
import '../api/report_pdf_export_api.dart';
import '../../features/discharge/document/discharge_document_api.dart';
import '../../features/discharge/document/local_discharge_document_api.dart';

/// Alias for authControllerProvider
final authProvider = authControllerProvider;

/// One mock API instance for the whole demo session (non-autoDispose on purpose).
final mockAdmissionsApiProvider = Provider<MockAdmissionsApi>((ref) {
  return MockAdmissionsApi();
});

final mockAuthApiProvider = Provider<MockAuthApi>((ref) => MockAuthApi());

final demoRepositoryProvider = Provider<AdmissionsRepository>((ref) {
  return DemoAdmissionsRepository(ref.watch(mockAdmissionsApiProvider));
});

final realAdmissionsRepositoryProvider = Provider<AdmissionsRepository>((ref) {
  return ApiAdmissionsRepository(
    DemoAdmissionsRepository.withStore(
      store: const SharedPreferencesPatientStayStore(
        storageKey: 'mock_api_patient_stays',
      ),
    ),
  );
});

final mockApiRepositoryProvider = realAdmissionsRepositoryProvider;

/// Screens ALWAYS use this. It picks demo vs real from the auth state.
final admissionsRepositoryProvider = Provider<AdmissionsRepository>((ref) {
  final isDemo = ref.watch(authProvider.select((s) => s.isDemo));
  if (isDemo) return ref.watch(demoRepositoryProvider);
  return ref.watch(realAdmissionsRepositoryProvider);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return MockReportRepository(ref.watch(admissionsRepositoryProvider));
});

/// PDF export API for reports tab
final reportPdfExportApiProvider = Provider<ReportPdfExportApi>((ref) {
  return DefaultReportPdfExportApi();
});

/// Discharge Document API for discharge summary PDF generation & export
final dischargeDocumentApiProvider = Provider<DischargeDocumentApi>((ref) {
  return LocalDischargeDocumentApi();
});

/// Tracks welcome snackbar shown for demo session
final demoWelcomeShownProvider = StateProvider<bool>((ref) => false);

/// List and stats providers that can be invalidated
final admissionsListProvider = FutureProvider<List<PatientStay>>((ref) async {
  final repo = ref.watch(admissionsRepositoryProvider);
  return repo.getAllPatients();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final isDemo = ref.watch(authProvider.select((s) => s.isDemo));
  if (isDemo) {
    final api = ref.watch(mockAdmissionsApiProvider);
    return api.getDashboardStats();
  }
  final repo = ref.watch(admissionsRepositoryProvider);
  final patients = await repo.getAllPatients();

  final totalAdmissions = patients.length;
  final totalDischarges = patients.where((p) => p.dod != null).length;
  final currentlyAdmitted = patients.where((p) => p.dod == null).length;

  final Map<String, int> admissionsByMonth = {};
  final Map<String, int> dischargesByMonth = {};
  final Map<String, int> admissionsByDay = {};
  final Map<String, int> dischargesByDay = {};
  final Map<String, int> admissionsByYear = {};
  final Map<String, int> dischargesByYear = {};

  for (final a in patients) {
    final y = a.doa.year.toString();
    final ym = '$y-${a.doa.month.toString().padLeft(2, '0')}';
    final ymd = '$ym-${a.doa.day.toString().padLeft(2, '0')}';

    admissionsByYear[y] = (admissionsByYear[y] ?? 0) + 1;
    admissionsByMonth[ym] = (admissionsByMonth[ym] ?? 0) + 1;
    admissionsByDay[ymd] = (admissionsByDay[ymd] ?? 0) + 1;

    if (a.dod != null) {
      final dy = a.dod!.year.toString();
      final dym = '$dy-${a.dod!.month.toString().padLeft(2, '0')}';
      final dymd = '$dym-${a.dod!.day.toString().padLeft(2, '0')}';

      dischargesByYear[dy] = (dischargesByYear[dy] ?? 0) + 1;
      dischargesByMonth[dym] = (dischargesByMonth[dym] ?? 0) + 1;
      dischargesByDay[dymd] = (dischargesByDay[dymd] ?? 0) + 1;
    }
  }

  return DashboardStats(
    totalAdmissions: totalAdmissions,
    totalDischarges: totalDischarges,
    currentlyAdmitted: currentlyAdmitted,
    admissionsByMonth: admissionsByMonth,
    dischargesByMonth: dischargesByMonth,
    admissionsByDay: admissionsByDay,
    dischargesByDay: dischargesByDay,
    admissionsByYear: admissionsByYear,
    dischargesByYear: dischargesByYear,
  );
});
