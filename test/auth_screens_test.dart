import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ktech_project_004/features/auth/auth_form_state.dart';
import 'package:ktech_project_004/features/auth/screens/forgot_password_screen.dart';
import 'package:ktech_project_004/features/auth/screens/login_screen.dart';
import 'package:ktech_project_004/features/auth/screens/register_screen.dart';
import 'package:ktech_project_004/models/user_role.dart';

Widget _authApp(Widget child, ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'login validates required fields and toggles password visibility',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _authApp(const LoginScreen(role: UserRole.doctor), container),
      );
      expect(find.text('Sign in as Doctor'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(find.byTooltip('Hide password'), findsOneWidget);
    },
  );

  testWidgets('forgot-password saves email and displays dismissible success', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _authApp(const ForgotPasswordScreen(role: UserRole.dataEntry), container),
    );
    await tester.enterText(find.byType(TextFormField), 'user@example.org');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(
      find.text('Password reset link sent to user@example.org'),
      findsOneWidget,
    );
    expect(container.read(authFormStateProvider).email, 'user@example.org');

    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pumpAndSettle();
    expect(
      find.text('Password reset link sent to user@example.org'),
      findsNothing,
    );
  });

  testWidgets('registration displays validation errors for incomplete input', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _authApp(const RegisterScreen(role: UserRole.dataEntry), container),
    );
    expect(find.text('Create Data Entry account'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
    expect(
      find.text('Medical registration number is required'),
      findsOneWidget,
    );
    expect(find.text('Access code is required'), findsOneWidget);
  });
}
