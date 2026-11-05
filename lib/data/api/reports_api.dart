import '../../backend/reports/report_models.dart';
import '../../features/admissions/models/patient_stay.dart';

abstract class ReportsApi {
  Future<ReportPage> search(ReportPageRequest request);

  Future<List<PatientStay>> exportRows(ReportPageRequest request);

  Future<void> recordPresentation({
    required ReportFilters filters,
    required int rowCount,
    required String userId,
  });

  List<ReportAuditEvent> get auditEvents;
}
