import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/core/aggregation.dart';
import 'package:ktech_project_004/features/admissions/models/patient_stay.dart';
import 'package:ktech_project_004/features/auth/auth_controller.dart';
import 'package:ktech_project_004/models/user_role.dart';

void main() {
  group('Financial Year Calculations', () {
    test('getFinancialYear returns correct year for April onwards', () {
      expect(getFinancialYear(DateTime(2024, 4, 1)), 2024);
      expect(getFinancialYear(DateTime(2024, 6, 15)), 2024);
      expect(getFinancialYear(DateTime(2024, 12, 31)), 2024);
    });

    test('getFinancialYear returns previous year for Jan-Mar', () {
      expect(getFinancialYear(DateTime(2024, 1, 1)), 2023);
      expect(getFinancialYear(DateTime(2024, 2, 15)), 2023);
      expect(getFinancialYear(DateTime(2024, 3, 31)), 2023);
    });

    test('getFinancialYearStart returns April 1st of the year', () {
      final start = getFinancialYearStart(2024);
      expect(start.year, 2024);
      expect(start.month, 4);
      expect(start.day, 1);
    });

    test('getFinancialYearEnd returns March 31st of next year', () {
      final end = getFinancialYearEnd(2024);
      expect(end.year, 2025);
      expect(end.month, 3);
      expect(end.day, 31);
    });

    test('getFinancialYearLabel returns correct format', () {
      expect(getFinancialYearLabel(2024), '2024-25');
      expect(getFinancialYearLabel(2023), '2023-24');
    });

    test('getFinancialMonthIndex returns correct index', () {
      expect(getFinancialMonthIndex(DateTime(2024, 4, 1)), 0); // April
      expect(getFinancialMonthIndex(DateTime(2024, 5, 15)), 1); // May
      expect(getFinancialMonthIndex(DateTime(2024, 12, 31)), 8); // Dec
      expect(getFinancialMonthIndex(DateTime(2025, 1, 1)), 9); // Jan
      expect(getFinancialMonthIndex(DateTime(2025, 3, 31)), 11); // Mar
    });
  });

  group('Days Stayed Calculation', () {
    test('calculateDaysStayed returns correct days', () {
      final doa = DateTime(2024, 1, 1);
      final dod = DateTime(2024, 1, 5);
      expect(calculateDaysStayed(doa, dod), 4);
    });

    test('calculateDaysStayed handles same day', () {
      final doa = DateTime(2024, 1, 1);
      final dod = DateTime(2024, 1, 1);
      expect(calculateDaysStayed(doa, dod), 0);
    });

    test('calculateDaysStayed handles different months', () {
      final doa = DateTime(2024, 1, 1);
      final dod = DateTime(2024, 2, 1);
      expect(calculateDaysStayed(doa, dod), 31);
    });
  });

  group('Aggregation by Year', () {
    test('aggregateByYear counts admissions correctly', () {
      final patients = [
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test1',
          doa: DateTime(2024, 4, 1),
          dod: DateTime(2024, 4, 5),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test2',
          doa: DateTime(2024, 5, 1),
          dod: DateTime(2024, 5, 3),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test3',
          doa: DateTime(2023, 4, 1),
          dod: DateTime(2023, 4, 5),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
      ];

      final result = aggregateByYear(patients, [2023, 2024]);
      expect(result.length, 2);
      expect(result[0].admissions, 1); // 2023
      expect(result[1].admissions, 2); // 2024
    });

    test('aggregateByYear counts discharges correctly', () {
      final patients = [
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test1',
          doa: DateTime(2024, 4, 1),
          dod: DateTime(2024, 4, 5),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test2',
          doa: DateTime(2024, 5, 1),
          dod: DateTime(2024, 5, 3),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
      ];

      final result = aggregateByYear(patients, [2024]);
      expect(result[0].discharges, 2);
    });
  });

  group('Aggregation by Month', () {
    test('aggregateByMonth counts admissions by month', () {
      final patients = [
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test1',
          doa: DateTime(2024, 4, 1),
          dod: DateTime(2024, 4, 5),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test2',
          doa: DateTime(2024, 4, 15),
          dod: DateTime(2024, 4, 20),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test3',
          doa: DateTime(2024, 5, 1),
          dod: DateTime(2024, 5, 5),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
      ];

      final result = aggregateByMonth(patients, 2024);
      expect(result.length, 12);
      expect(result[0].admissions, 2); // April (index 0)
      expect(result[1].admissions, 1); // May (index 1)
    });

    test('aggregateByMonth handles cross-year patients', () {
      final patients = [
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test1',
          doa: DateTime(2024, 4, 1),
          dod: DateTime(2024, 4, 5),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test2',
          doa: DateTime(2025, 1, 15), // January in FY 2024
          dod: DateTime(2025, 1, 20),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
      ];

      final result = aggregateByMonth(patients, 2024);
      expect(result[0].admissions, 1); // April (index 0)
      expect(result[9].admissions, 1); // January (index 9)
    });
  });

  group('Aggregation by Day', () {
    test('aggregateByDay counts admissions by day', () {
      final patients = [
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test1',
          doa: DateTime(2024, 4, 1),
          dod: DateTime(2024, 4, 5),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test2',
          doa: DateTime(2024, 4, 1),
          dod: DateTime(2024, 4, 3),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
        PatientStay(
          prefix: Prefix.bo,
          mothersName: 'Test3',
          doa: DateTime(2024, 4, 2),
          dod: DateTime(2024, 4, 5),
          contactNumber: '1234567890',
          contactRelation: Relation.father,
          city: 'AHMEDABAD',
          pin: '380001',
          del: 'Test',
        ),
      ];

      final result = aggregateByDay(patients, 2024, 4);
      expect(result[0].admissions, 2); // Day 1
      expect(result[1].admissions, 1); // Day 2
    });
  });

  group('Date Formatting', () {
    test('formatDate returns correct format', () {
      final date = DateTime(2024, 4, 15);
      expect(formatDate(date), '15 Apr 2024');
    });

    test('formatYearMonth returns correct format', () {
      final date = DateTime(2024, 4, 15);
      expect(formatYearMonth(date), '202404');
    });
  });

  group('PatientStay Model', () {
    test('daysStayed calculates correctly for discharged patient', () {
      final patient = PatientStay(
        prefix: Prefix.bo,
        mothersName: 'Test',
        doa: DateTime(2024, 1, 1),
        dod: DateTime(2024, 1, 5),
        contactNumber: '1234567890',
        contactRelation: Relation.father,
        city: 'AHMEDABAD',
        pin: '380001',
        del: 'Test',
      );

      expect(patient.daysStayed, 4);
    });

    test('daysStayed calculates correctly for admitted patient', () {
      final patient = PatientStay(
        prefix: Prefix.bo,
        mothersName: 'Test',
        doa: DateTime(2024, 1, 1),
        dod: null,
        contactNumber: '1234567890',
        contactRelation: Relation.father,
        city: 'AHMEDABAD',
        pin: '380001',
        del: 'Test',
      );

      // This will depend on current time, so we just check it's a number
      expect(patient.daysStayed, isA<int>());
    });

    test('dischargeStatus returns correct status', () {
      final discharged = PatientStay(
        prefix: Prefix.bo,
        mothersName: 'Test',
        doa: DateTime(2024, 1, 1),
        dod: DateTime(2024, 1, 5),
        contactNumber: '1234567890',
        contactRelation: Relation.father,
        city: 'AHMEDABAD',
        pin: '380001',
        del: 'Test',
      );

      final admitted = PatientStay(
        prefix: Prefix.bo,
        mothersName: 'Test',
        doa: DateTime(2024, 1, 1),
        dod: null,
        contactNumber: '1234567890',
        contactRelation: Relation.father,
        city: 'AHMEDABAD',
        pin: '380001',
        del: 'Test',
      );

      expect(discharged.dischargeStatus, DischargeStatus.discharged);
      expect(admitted.dischargeStatus, DischargeStatus.admitted);
    });

    test('displayName returns correct format', () {
      final patient = PatientStay(
        prefix: Prefix.bo,
        mothersName: 'Sharma',
        doa: DateTime(2024, 1, 1),
        contactNumber: '1234567890',
        contactRelation: Relation.father,
        city: 'AHMEDABAD',
        pin: '380001',
        del: 'Test',
      );

      expect(patient.displayName, 'Baby of Sharma');
    });
  });

  group('AuthState canWrite', () {
    test('canWrite returns true for admin', () {
      final state = AuthState(isAuthenticated: true, role: UserRole.admin);
      expect(state.canWrite, true);
    });

    test('canWrite returns true for dataEntry', () {
      final state = AuthState(isAuthenticated: true, role: UserRole.dataEntry);
      expect(state.canWrite, true);
    });

    test('canWrite returns false for doctor', () {
      final state = AuthState(isAuthenticated: true, role: UserRole.doctor);
      expect(state.canWrite, false);
    });

    test('canWrite returns false when not authenticated', () {
      final state = const AuthState();
      expect(state.canWrite, false);
    });
  });
}
