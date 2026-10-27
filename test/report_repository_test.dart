import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/backend/admissions/demo_admissions_repository.dart';
import 'package:ktech_project_004/backend/admissions/local_patient_stay_store.dart';
import 'package:ktech_project_004/backend/reports/mock_report_repository.dart';
import 'package:ktech_project_004/backend/reports/report_models.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  late MockReportRepository repository;

  setUp(() async {
    final store = _MemoryPatientStore([
      _patient(
        id: 'one',
        name: 'Mother One',
        baby: 'B/O Mother One - A',
        admissionDate: DateTime(2026, 10, 2),
        branch: Branch.arpanMother,
        birthType: BirthType.twin,
        weight: 2.4,
        length: 45.5,
        notes: 'Culture positive sepsis',
      ),
      _patient(
        id: 'two',
        name: 'Mother Two',
        baby: 'B/O Mother Two',
        admissionDate: DateTime(2026, 10, 3),
        branch: Branch.arpanMother,
        birthType: BirthType.triplet,
        weight: 1.8,
        length: 42,
        dischargeDate: DateTime(2026, 10, 8),
        dischargeType: DischargeType.shift,
        notes: 'Respiratory distress',
      ),
      _patient(
        id: 'three',
        name: 'Mother Three',
        baby: 'B/O Mother Three',
        admissionDate: DateTime(2026, 9, 18),
        branch: Branch.arpanViolet,
        birthType: BirthType.single,
        weight: 3.1,
        length: 48,
        notes: 'Routine care',
      ),
    ]);
    final admissions = DemoAdmissionsRepository.withStore(store: store);
    repository = MockReportRepository(admissions);
  });

  test(
    'combines report filters with AND and summarizes all matches before paging',
    () async {
      final result = await repository.search(
        ReportPageRequest(
          filters: ReportFilters(
            admissionFrom: DateTime(2026, 10, 1),
            admissionTo: DateTime(2026, 10, 31),
            branch: Branch.arpanMother,
            minimumWeightKg: 2,
          ),
          pageIndex: 0,
          pageSize: 1,
        ),
      );

      expect(result.totalCount, 1);
      expect(result.rows.single.id, 'one');
      expect(result.summary.total, 1);
      expect(result.summary.twins, 1);
      expect(result.summary.triplets, 0);
      expect(result.pageCount, 1);
    },
  );

  test(
    'supports clinical text, Length range, discharge date and Shift filters',
    () async {
      final result = await repository.search(
        ReportPageRequest(
          filters: ReportFilters(
            dischargeFrom: DateTime(2026, 10, 8),
            dischargeTo: DateTime(2026, 10, 8),
            dischargeType: DischargeType.shift,
            minimumLengthCm: 41,
            maximumLengthCm: 43,
            diagnosisQuery: 'respiratory',
          ),
        ),
      );

      expect(result.totalCount, 1);
      expect(result.rows.single.id, 'two');
      expect(result.summary.shifted, 1);
    },
  );

  test('sorts rows and records presentation audit metadata', () async {
    final result = await repository.search(
      const ReportPageRequest(
        sortField: ReportSortField.babyName,
        ascending: true,
        pageSize: 2,
      ),
    );
    expect(result.rows.map((patient) => patient.id), ['one', 'three']);
    expect(result.totalCount, 3);

    await repository.recordPresentation(
      filters: const ReportFilters(branch: Branch.arpanMother),
      rowCount: result.totalCount,
      userId: 'local-doctor',
    );
    expect(repository.auditEvents, hasLength(1));
    expect(repository.auditEvents.single.action, 'PRESENT');
    expect(repository.auditEvents.single.userId, 'local-doctor');
    expect(repository.auditEvents.single.rowCount, 3);
    expect(repository.auditEvents.single.occurredAtUtc.isUtc, isTrue);
  });

  test('masks identifiers in report columns', () {
    final patient = _patient(
      id: 'private',
      name: 'Private Mother',
      baby: 'Private Baby',
      admissionDate: DateTime(2026, 10, 1),
      branch: Branch.arpanMother,
      birthType: BirthType.single,
      weight: 2.5,
      length: 45,
      serialNo: 12,
      notes: 'Private record',
    );

    expect(
      ReportColumn.babyName.value(patient, hideIdentifiers: true),
      'Hidden',
    );
    expect(
      ReportColumn.serialNumber.value(patient, hideIdentifiers: true),
      'Hidden',
    );
    expect(ReportColumn.length.value(patient, hideIdentifiers: true), '45.0');
  });
}

PatientStay _patient({
  required String id,
  required String name,
  required String baby,
  required DateTime admissionDate,
  required Branch branch,
  required BirthType birthType,
  required double weight,
  required double length,
  DateTime? dischargeDate,
  DischargeType? dischargeType,
  required String notes,
  int serialNo = 1,
}) => PatientStay(
  id: id,
  serialNo: serialNo,
  financialYear: 2026,
  prefix: Prefix.bo,
  mothersName: name,
  babyName: baby,
  branch: branch,
  admissionType: AdmissionType.inborn,
  admissionHistory: AdmissionHistory.firstAdmission,
  birthType: birthType,
  doa: admissionDate,
  dod: dischargeDate,
  contactNumber: '5550100',
  contactRelation: Relation.mother,
  pin: '380001',
  del: 'Test Hospital',
  birthWeight: weight,
  length: length,
  dischargeType: dischargeType,
  sepsis: notes,
);

class _MemoryPatientStore implements PatientStayStore {
  List<PatientStay>? patients;

  _MemoryPatientStore(this.patients);

  @override
  Future<List<PatientStay>?> readAll() async => patients;

  @override
  Future<void> writeAll(List<PatientStay> patients) async {
    this.patients = List.of(patients);
  }
}
