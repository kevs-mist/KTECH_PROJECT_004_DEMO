import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ktech_project_004/backend/admissions/demo_admissions_repository.dart';
import 'package:ktech_project_004/backend/admissions/demo_seed.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('demo seed remains small and contains multiple-birth examples', () {
    final patients = DemoSeed.generateSeedData();

    expect(patients, hasLength(24));
    expect(
      patients.where((patient) => patient.dod == null).length,
      greaterThanOrEqualTo(4),
    );
    expect(
      patients.where((patient) => patient.birthType == BirthType.twin),
      hasLength(2),
    );
    expect(
      patients.where((patient) => patient.birthType == BirthType.triplet),
      hasLength(3),
    );
  });

  group('Mock admission serial numbers', () {
    late DemoAdmissionsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = DemoAdmissionsRepository();
      await repository.clearAllData();
    });

    test('resets serial at the April 1 financial-year boundary', () async {
      final marchAdmission = await repository.createAdmission(
        _patient(DateTime(2026, 3, 31)),
      );
      final aprilAdmission = await repository.createAdmission(
        _patient(DateTime(2026, 4, 1)),
      );
      final secondMarchAdmission = await repository.createAdmission(
        _patient(DateTime(2026, 3, 30)),
      );

      expect(marchAdmission.financialYear, 2025);
      expect(marchAdmission.serialNo, 1);
      expect(aprilAdmission.financialYear, 2026);
      expect(aprilAdmission.serialNo, 1);
      expect(secondMarchAdmission.financialYear, 2025);
      expect(secondMarchAdmission.serialNo, 2);
    });

    test('concurrent creates receive distinct serials in one FY', () async {
      final admissions = await Future.wait([
        repository.createAdmission(_patient(DateTime(2026, 4, 1))),
        repository.createAdmission(_patient(DateTime(2026, 4, 2))),
      ]);

      expect(admissions.map((patient) => patient.serialNo).toSet(), {1, 2});
      expect(admissions.map((patient) => patient.financialYear).toSet(), {
        2026,
      });
    });
  });
}

PatientStay _patient(DateTime doa) => PatientStay(
  prefix: Prefix.bo,
  mothersName: 'Example Mother',
  doa: doa,
  contactNumber: '1234567890',
  contactRelation: Relation.mother,
  pin: '380001',
  del: 'Hospital',
);
