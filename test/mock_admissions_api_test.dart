import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ktech_project_004/data/api/admissions_api.dart';
import 'package:ktech_project_004/data/api/mock_admissions_api.dart';
import 'package:ktech_project_004/data/providers/demo_providers.dart';
import 'package:ktech_project_004/backend/admissions/api_admissions_repository.dart';
import 'package:ktech_project_004/backend/admissions/demo_admissions_repository.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MockAdmissionsApi unit tests', () {
    late MockAdmissionsApi api;

    setUp(() {
      api = MockAdmissionsApi(latency: Duration.zero);
    });

    test('seed count > 0', () async {
      final admissions = await api.listAdmissions();
      expect(admissions.length, greaterThan(0));
    });

    test('createAdmission shows up in listAdmissions AND in getDashboardStats', () async {
      final initialStats = await api.getDashboardStats();
      final newAdmission = await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test Mother Dashboard',
          doa: DateTime(2026, 10, 27),
          contactNumber: '9876543210',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Hospital',
        ),
      );

      final list = await api.listAdmissions(query: 'Test Mother Dashboard');
      expect(list.any((a) => a.id == newAdmission.id), isTrue);

      final updatedStats = await api.getDashboardStats();
      expect(updatedStats.totalAdmissions, initialStats.totalAdmissions + 1);
      expect(updatedStats.currentlyAdmitted, initialStats.currentlyAdmitted + 1);
      expect(updatedStats.admissionsByDay['2026-10-27'], isNotNull);
      expect(updatedStats.admissionsByDay['2026-10-27']!, greaterThanOrEqualTo(1));
    });

    test('dischargeAdmission updates currentlyAdmitted', () async {
      final admission = await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Discharge Test Mother',
          doa: DateTime(2026, 10, 20),
          contactNumber: '9876543210',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Hospital',
        ),
      );

      final statsBefore = await api.getDashboardStats();
      final admittedBefore = statsBefore.currentlyAdmitted;

      final discharged = await api.dischargeAdmission(admission.id!, {
        'dod': DateTime(2026, 10, 25),
        'dischargeType': DischargeType.routine,
        'length': 48.0,
      });

      expect(discharged.dod, DateTime(2026, 10, 25));
      expect(discharged.stay, 5);

      final statsAfter = await api.getDashboardStats();
      expect(statsAfter.currentlyAdmitted, admittedBefore - 1);
      expect(statsAfter.totalDischarges, statsBefore.totalDischarges + 1);
    });

    test('double-discharge throws', () async {
      final admission = await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Double Discharge Mother',
          doa: DateTime(2026, 10, 20),
          contactNumber: '9876543210',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Hospital',
        ),
      );

      await api.dischargeAdmission(admission.id!, {
        'dod': DateTime(2026, 10, 22),
      });

      expect(
        () => api.dischargeAdmission(admission.id!, {
          'dod': DateTime(2026, 10, 23),
        }),
        throwsA(isA<MockApiException>()),
      );
    });

    test('twins get the A/B names', () async {
      final twinA = await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Twin Mother Sample',
          birthType: BirthType.twin,
          doa: DateTime(2026, 10, 27),
          contactNumber: '9876543210',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Hospital',
        ),
      );

      final twinB = await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Twin Mother Sample',
          birthType: BirthType.twin,
          doa: DateTime(2026, 10, 27),
          contactNumber: '9876543210',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Hospital',
        ),
      );

      expect(twinA.babyName, contains('- A'));
      expect(twinB.babyName, contains('- B'));
    });

    test('Sr. No. resets on April 1', () async {
      final marchAdmission = await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'March Mother',
          doa: DateTime(2030, 3, 31),
          contactNumber: '9876543210',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Hospital',
        ),
      );

      final aprilAdmission = await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'April Mother',
          doa: DateTime(2030, 4, 1),
          contactNumber: '9876543210',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Hospital',
        ),
      );

      expect(marchAdmission.financialYear, 2029);
      expect(marchAdmission.serialNo, 1);
      expect(aprilAdmission.financialYear, 2030);
      expect(aprilAdmission.serialNo, 1);
    });

    test('reset() restores the seed', () async {
      final initialCount = (await api.listAdmissions()).length;

      await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Temporary Mother',
          doa: DateTime(2026, 10, 27),
          contactNumber: '9876543210',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Hospital',
        ),
      );

      expect((await api.listAdmissions()).length, initialCount + 1);

      api.reset();

      expect((await api.listAdmissions()).length, initialCount);
      expect(
        (await api.listAdmissions(query: 'Temporary Mother')),
        isEmpty,
      );
    });
  });

  test('mock API provider persists records in its own store', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final api = container.read(mockApiRepositoryProvider);
    await api.clearAllData();
    final created = await api.createAdmission(
      PatientStay(
        prefix: Prefix.bo,
        mothersName: 'Shared Store Mother',
        doa: DateTime(2026, 10, 24),
        contactNumber: '1234567890',
        contactRelation: Relation.mother,
        pin: '380001',
        del: 'Demo Hospital',
      ),
    );

    expect(await api.getPatientById(created.id!), isNotNull);
  });

  group('Mock admissions API workflow', () {
    late ApiAdmissionsRepository api;

    setUp(() async {
      final store = DemoAdmissionsRepository();
      await store.clearAllData();
      api = ApiAdmissionsRepository(store);
    });

    test('creates admission and then updates it through discharge', () async {
      final admitted = await api.createAdmission(
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Workflow Mother',
          babyName: 'B/O Workflow Mother',
          branch: Branch.arpanMother,
          admissionType: AdmissionType.inborn,
          admissionHistory: AdmissionHistory.firstAdmission,
          birthType: BirthType.single,
          doa: DateTime(2026, 10, 24),
          contactNumber: '1234567890',
          contactRelation: Relation.mother,
          pin: '380001',
          del: 'Demo Hospital',
        ),
      );

      expect(admitted.id, isNotNull);
      expect(admitted.serialNo, 1);
      expect(admitted.financialYear, 2026);
      expect(
        (await api.getPatientById(admitted.id!))?.babyName,
        'B/O Workflow Mother',
      );
      expect((await api.getAdmittedPatients()).single.id, admitted.id);

      final discharged = await api.updatePatient(
        admitted.copyWith(
          dod: DateTime(2026, 10, 25),
          length: 45.5,
          dischargeType: DischargeType.shift,
          shiftedTo: 'Receiving Hospital',
          shiftReason: 'Higher level of care',
        ),
      );

      expect(discharged.dod, DateTime(2026, 10, 25));
      expect((await api.getAdmittedPatients()), isEmpty);
      expect(
        (await api.getDischargedPatients()).single.shiftedTo,
        'Receiving Hospital',
      );
      expect((await api.getPatientById(admitted.id!))?.length, 45.5);
    });
  });
}
