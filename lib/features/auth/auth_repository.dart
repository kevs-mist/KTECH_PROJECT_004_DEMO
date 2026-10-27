import '../../models/user_role.dart';

abstract class AuthRepository {
  Future<void> signIn({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> register({
    required String email,
    required String password,
    required String medicalRegistration,
    required String accessCode,
    required UserRole role,
  });

  Future<void> forgotPassword({
    required String email,
    required UserRole role,
  });

  Future<void> signOut();
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 900));

    // Fake authentication - always succeeds for demo
    // In production, this would validate against a backend
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String medicalRegistration,
    required String accessCode,
    required UserRole role,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 900));

    // Fake registration - always succeeds for demo
    // In production, this would create an account on the backend
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required UserRole role,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 900));

    // Fake password reset - always succeeds for demo
    // In production, this would send a reset email
  }

  @override
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Fake sign out - always succeeds for demo
  }
}
