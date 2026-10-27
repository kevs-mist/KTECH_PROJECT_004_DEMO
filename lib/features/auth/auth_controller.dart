import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_role.dart';
import '../../backend/admissions/admissions_providers.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isDemo;
  final String? userName;
  final UserRole? role;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({
    this.isAuthenticated = false,
    this.isDemo = false,
    this.userName,
    this.role,
    this.accessToken,
    this.refreshToken,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isDemo,
    String? userName,
    UserRole? role,
    String? accessToken,
    String? refreshToken,
    bool clearTokens = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isDemo: isDemo ?? this.isDemo,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      accessToken: clearTokens ? null : (accessToken ?? this.accessToken),
      refreshToken: clearTokens ? null : (refreshToken ?? this.refreshToken),
    );
  }

  bool get canWrite {
    if (!isAuthenticated) return false;
    return role == UserRole.admin || role == UserRole.dataEntry;
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;

  AuthController(this.ref) : super(const AuthState());

  void startDemo({required UserRole role, required String userName}) {
    state = AuthState(
      isAuthenticated: true,
      isDemo: true,
      userName: userName,
      role: role,
      accessToken: null,
      refreshToken: null,
    );
  }

  void login({
    required String userName,
    required UserRole role,
    required String accessToken,
    required String refreshToken,
  }) {
    state = AuthState(
      isAuthenticated: true,
      isDemo: false,
      userName: userName,
      role: role,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  void logout() {
    // If logging out from demo mode, invalidate the demo repository to clear data
    if (state.isDemo) {
      ref.invalidate(demoRepositoryProvider);
    }
    state = const AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref);
  },
);
