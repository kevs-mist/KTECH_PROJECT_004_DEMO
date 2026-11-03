// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ktech_project_004/app/router.dart' show createRouter;
import 'package:ktech_project_004/features/auth/auth_controller.dart';
import 'package:ktech_project_004/main.dart';
import 'package:ktech_project_004/models/user_role.dart';

void main() {
  testWidgets('application root renders the splash route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: MyApp(routerConfig: createRouter())),
    );

    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.text('Made with KTech'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });

  testWidgets('discharge form opens and renders the patient selector', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(authControllerProvider.notifier).startDemo(
      role: UserRole.dataEntry,
      userName: 'Test User',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: createRouter(
            container: container,
            initialLocation: '/discharge',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Discharge Patient'), findsOneWidget);
    expect(find.text('Select Patient to Discharge'), findsOneWidget);
  });
}
