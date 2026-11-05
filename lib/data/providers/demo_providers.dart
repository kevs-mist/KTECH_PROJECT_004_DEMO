import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backend/admissions/admissions_repository.dart';
import '../../backend/admissions/api_admissions_repository.dart';
import '../../backend/admissions/authorized_admissions_repository.dart';
import '../../backend/admissions/demo_admissions_repository.dart';
import '../../backend/admissions/local_patient_stay_store.dart';
import '../../backend/reports/mock_report_repository.dart';
import '../../core/demo_flag.dart';
import '../../features/admissions/models/patient_stay.dart';
import '../../features/auth/auth_controller.dart';
import '../api/admissions_api.dart';
import '../api/default_report_pdf_export_api.dart';
import '../api/default_report_excel_export_api.dart';
import '../api/mock_admissions_api.dart';
import '../api/mock_auth_api.dart';
import '../api/mock_reports_api.dart';
import '../api/reports_api.dart';
import '../api/report_pdf_export_api.dart';
import '../api/report_excel_export_api.dart';
import '../../features/discharge/document/discharge_document_api.dart';
import '../../features/discharge/document/local_discharge_document_api.dart';

/// Alias for authControllerProvider
final authProvider = authControllerProvider;

/// In-memory mock API. Seed data is only injected when the app is built
/// with `--dart-define=ENABLE_DEMO=true`.
final mockAdmissionsApiProvider = Provider<MockAdmissionsApi>((ref) {
  return MockAdmissionsApi(seedDemoData: DemoFlag.isEnabled);
});

final mockAuthApiProvider = Provider<MockAuthApi>((ref) => MockAuthApi());

final demoRepositoryProvider = Provider<AdmissionsRepository>((ref) {
  return DemoAdmissionsRepository(ref.watch(mockAdmissionsApiProvider));
});

/// Persistent API backed by the encrypted on-disk registry. Used as the
/// production data source and shared by reports so both layers read the
/// same records.
final persistentAdmissionsApiProvider = Provider<MockAdmissionsApi>((ref) {
  return MockAdmissionsApi(
    latency: Duration.zero,
    store: const DataFilePatientStayStore(),
    seedDemoData: false,
  );
});

final realAdmissionsRepositoryProvider = Provider<AdmissionsRepository>((ref) {
  return ApiAdmissionsRepository(
    DemoAdmissionsRepository(ref.watch(persistentAdmissionsApiProvider)),
  );
});

final mockApiRepositoryProvider = realAdmissionsRepositoryProvider;

/// Screens ALWAYS use this. It picks demo vs real from the auth state and
/// the ENABLE_DEMO compile-time flag, then enforces write permissions at
/// the data layer.
final admissionsRepositoryProvider = Provider<AdmissionsRepository>((ref) {
  final auth = ref.watch(authProvider);
  final useDemo = DemoFlag.isEnabled && auth.isDemo;
  final inner = useDemo
      ? ref.watch(demoRepositoryProvider)
      : ref.watch(realAdmissionsRepositoryProvider);
  return AuthorizedAdmissionsRepository(inner, canWrite: auth.canWrite);
});

final admissionsChangedProvider = StateProvider<int>((ref) => 0);

void notifyAdmissionsChanged(WidgetRef ref) {
  ref.read(admissionsChangedProvider.notifier).state++;
}

final reportsApiProvider = Provider<ReportsApi>((ref) {
  final auth = ref.watch(authProvider);
  final useDemo = DemoFlag.isEnabled && auth.isDemo;
  final api = useDemo
      ? ref.watch(mockAdmissionsApiProvider)
      : ref.watch(persistentAdmissionsApiProvider);
  return MockReportsApi(api);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return MockReportRepository(ref.watch(admissionsRepositoryProvider));
});

/// PDF export API for reports tab
final reportPdfExportApiProvider = Provider<ReportPdfExportApi>((ref) {
  return DefaultReportPdfExportApi();
});

/// Excel export API for reports tab
final reportExcelExportApiProvider = Provider<ReportExcelExportApi>((ref) {
  return DefaultReportExcelExportApi();
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
  final auth = ref.watch(authProvider);
  final isDemo = DemoFlag.isEnabled && auth.isDemo;
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
