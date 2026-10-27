import '../../models/user_role.dart';

class AuthSession {
  final bool isAuthenticated;
  final bool isDemo;
  final String userName;
  final UserRole role;
  final String? accessToken;
  final String? refreshToken;

  const AuthSession({
    required this.isAuthenticated,
    required this.isDemo,
    required this.userName,
    required this.role,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthSession.demo({required UserRole role, String? userName}) {
    final defaultName = switch (role) {
      UserRole.admin => 'Demo Data Entry',
      UserRole.dataEntry => 'Demo Data Entry',
      UserRole.doctor => 'Dr. Demo User',
    };
    return AuthSession(
      isAuthenticated: true,
      isDemo: true,
      userName: userName ?? defaultName,
      role: role,
    );
  }
}

class MockAuthApi {
  Future<AuthSession> demoLogin(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AuthSession.demo(role: role);
  }
}
