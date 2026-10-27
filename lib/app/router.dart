import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/demo_providers.dart';
import '../features/admissions/admission_form_screen.dart';
import '../features/admissions/discharge_form_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_shell.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/widgets/role_selection_cards.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/patients/patient_detail_screen.dart';
import '../features/patients/patients_screen.dart';
import '../features/reports/report_screen.dart';
import '../models/user_role.dart';
import '../splash_screen.dart';

enum ScreenType { roleSelection, login, forgotPassword, register }

class RiverpodAuthListenable extends ChangeNotifier {
  RiverpodAuthListenable({Ref? ref, ProviderContainer? container}) {
    if (ref != null) {
      ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
    } else if (container != null) {
      container.listen<AuthState>(authProvider, (_, _) => notifyListeners());
    }
  }
}

final defaultProviderContainer = ProviderContainer();

final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(ref: ref);
});

GoRouter createRouter({
  Ref? ref,
  ProviderContainer? container,
  String initialLocation = '/splash',
}) {
  final effectiveContainer =
      container ?? (ref == null ? defaultProviderContainer : null);

  AuthState readAuth() {
    if (ref != null) return ref.read(authProvider);
    if (effectiveContainer != null) {
      return effectiveContainer.read(authProvider);
    }
    return const AuthState();
  }

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: RiverpodAuthListenable(
      ref: ref,
      container: effectiveContainer,
    ),
    redirect: (context, state) {
      final auth = readAuth();
      final loggedIn = auth.isAuthenticated || auth.isDemo;
      final loc = state.matchedLocation;
      if (loc == '/splash') return null;
      final isPublic = loc == '/roles' ||
          loc.startsWith('/login') ||
          loc.startsWith('/forgot') ||
          loc.startsWith('/register');
      if (!loggedIn && !isPublic) return '/roles';
      if (loggedIn && isPublic) return '/dashboard';

      // Also block doctor-role demo users from the admission/discharge form routes (redirect to /dashboard).
      final isDoctor = auth.role == UserRole.doctor;
      if (isDoctor &&
          (loc.startsWith('/admission') || loc.startsWith('/discharge'))) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Unified shell with nested routes
      ShellRoute(
        builder: (context, state, child) {
          final path = state.uri.path;
          ScreenType screenType;
          UserRole? role;

          if (path == '/roles') {
            screenType = ScreenType.roleSelection;
          } else if (path.startsWith('/login/')) {
            screenType = ScreenType.login;
            final roleParam = state.pathParameters['role'] ?? 'doctor';
            role = roleParam == 'data-entry'
                ? UserRole.dataEntry
                : UserRole.doctor;
          } else if (path.startsWith('/forgot/')) {
            screenType = ScreenType.forgotPassword;
            final roleParam = state.pathParameters['role'] ?? 'doctor';
            role = roleParam == 'data-entry'
                ? UserRole.dataEntry
                : UserRole.doctor;
          } else if (path.startsWith('/register/')) {
            screenType = ScreenType.register;
            final roleParam = state.pathParameters['role'] ?? 'doctor';
            role = roleParam == 'data-entry'
                ? UserRole.dataEntry
                : UserRole.doctor;
          } else {
            screenType = ScreenType.roleSelection;
          }

          return AppShell(screenType: screenType, role: role, child: child);
        },
        routes: [
          // Role selection
          GoRoute(
            path: '/roles',
            name: 'roles',
            builder: (context, state) => const RoleSelectionCards(),
          ),
          // Login
          GoRoute(
            path: '/login/:role',
            name: 'login',
            builder: (context, state) {
              final roleParam = state.pathParameters['role'] ?? 'doctor';
              final role = roleParam == 'data-entry'
                  ? UserRole.dataEntry
                  : UserRole.doctor;
              return LoginScreen(role: role);
            },
          ),
          // Forgot password
          GoRoute(
            path: '/forgot/:role',
            name: 'forgot',
            builder: (context, state) {
              final roleParam = state.pathParameters['role'] ?? 'doctor';
              final role = roleParam == 'data-entry'
                  ? UserRole.dataEntry
                  : UserRole.doctor;
              return ForgotPasswordScreen(role: role);
            },
          ),
          // Register
          GoRoute(
            path: '/register/:role',
            name: 'register',
            builder: (context, state) {
              final roleParam = state.pathParameters['role'] ?? 'doctor';
              final role = roleParam == 'data-entry'
                  ? UserRole.dataEntry
                  : UserRole.doctor;
              return RegisterScreen(role: role);
            },
          ),
        ],
      ),
      // Dashboard (protected by auth check)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const _AuthGuard(child: DashboardScreen()),
      ),
      // Patients list (protected by auth check)
      GoRoute(
        path: '/patients',
        name: 'patients',
        builder: (context, state) => const _AuthGuard(child: PatientsScreen()),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const _AuthGuard(child: ReportScreen()),
      ),
      // Patient detail (protected by auth check)
      GoRoute(
        path: '/patients/:id',
        name: 'patient-detail',
        builder: (context, state) {
          final patientId = state.pathParameters['id'] ?? '';
          return _AuthGuard(child: PatientDetailScreen(patientId: patientId));
        },
      ),
      // New admission (protected by auth + write permission check)
      GoRoute(
        path: '/admission/new',
        name: 'new-admission',
        builder: (context, state) => const _AuthGuard(
          child: _WritePermissionGuard(child: AdmissionFormScreen()),
        ),
      ),
      // Discharge (protected by auth + write permission check)
      GoRoute(
        path: '/discharge',
        name: 'discharge',
        builder: (context, state) => const _AuthGuard(
          child: _WritePermissionGuard(child: DischargeFormScreen()),
        ),
      ),
    ],
  );
}

final router = createRouter();

/// Guard widget that checks if user is authenticated
class _AuthGuard extends ConsumerWidget {
  final Widget child;

  const _AuthGuard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/roles');
      });
      return const SizedBox();
    }

    return child;
  }
}

/// Guard widget that checks if user has write permission
class _WritePermissionGuard extends ConsumerWidget {
  final Widget child;

  const _WritePermissionGuard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.canWrite) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/dashboard');
      });
      return const SizedBox();
    }

    return child;
  }
}
