import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/data/api/mock_auth_api.dart';
import 'package:ktech_project_004/models/user_role.dart';

void main() {
  test(
    'demo session uses role-specific defaults and allows a custom name',
    () async {
      final api = MockAuthApi();

      final admin = await api.demoLogin(UserRole.admin);
      final dataEntry = await api.demoLogin(UserRole.dataEntry);
      final doctor = await api.demoLogin(UserRole.doctor);
      final custom = AuthSession.demo(
        role: UserRole.doctor,
        userName: 'Dr. User',
      );

      expect(admin.isAuthenticated, isTrue);
      expect(admin.isDemo, isTrue);
      expect(admin.userName, 'Demo Data Entry');
      expect(dataEntry.userName, 'Demo Data Entry');
      expect(doctor.userName, 'Dr. Demo User');
      expect(custom.userName, 'Dr. User');
      expect(custom.role, UserRole.doctor);
      expect(admin.accessToken, isNull);
      expect(admin.refreshToken, isNull);
    },
  );
}
