import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/features/auth/validators.dart';

void main() {
  group('Validators', () {
    test('email accepts trimmed valid addresses and rejects invalid input', () {
      expect(Validators.validateEmail(' patient@example.org '), isNull);
      expect(Validators.validateEmail(null)?.message, 'Email is required');
      expect(Validators.validateEmail('  ')?.message, 'Email is required');
      expect(
        Validators.validateEmail('not-an-email')?.message,
        'Please enter a valid email address',
      );
    });

    test('password enforces presence and creation length', () {
      expect(
        Validators.validatePassword(null)?.message,
        'Password is required',
      );
      expect(
        Validators.validatePassword('   ')?.message,
        'Password is required',
      );
      expect(
        Validators.validatePassword('short', isCreate: true)?.message,
        'Password must be at least 12 characters',
      );
      expect(Validators.validatePassword('short'), isNull);
      expect(
        Validators.validatePassword('long-enough-password', isCreate: true),
        isNull,
      );
    });

    test('confirmation requires a matching password', () {
      expect(
        Validators.validateConfirmPassword('secret', null)?.message,
        'Please confirm your password',
      );
      expect(
        Validators.validateConfirmPassword('secret', '  ')?.message,
        'Please confirm your password',
      );
      expect(
        Validators.validateConfirmPassword('secret', 'different')?.message,
        'Passwords do not match',
      );
      expect(Validators.validateConfirmPassword('secret', 'secret'), isNull);
    });

    test('medical registration accepts only bounded permitted characters', () {
      expect(Validators.validateMedicalRegistration(' AB/123-CD '), isNull);
      expect(
        Validators.validateMedicalRegistration(null)?.message,
        'Medical registration number is required',
      );
      expect(
        Validators.validateMedicalRegistration('  ')?.message,
        'Medical registration number is required',
      );
      expect(
        Validators.validateMedicalRegistration('A12')?.message,
        'Must be 4-20 characters',
      );
      expect(
        Validators.validateMedicalRegistration('A' * 21)?.message,
        'Must be 4-20 characters',
      );
      expect(
        Validators.validateMedicalRegistration('AB 123')?.message,
        'Only letters, digits, slash, and hyphen allowed',
      );
    });

    test('access code requires non-whitespace input', () {
      expect(
        Validators.validateAccessCode(null)?.message,
        'Access code is required',
      );
      expect(
        Validators.validateAccessCode('  ')?.message,
        'Access code is required',
      );
      expect(Validators.validateAccessCode(' CODE-123 '), isNull);
    });
  });
}
