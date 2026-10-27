import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ktech_project_004/features/auth/demo_role_dialog.dart';

void main() {
  testWidgets('Cancel in DemoRoleDialog does not change the route', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/current-test-route',
      routes: [
        GoRoute(
          path: '/current-test-route',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => DemoRoleDialog.show(context),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/roles',
          builder: (context, state) => const Scaffold(body: Text('Roles Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open Dialog'), findsOneWidget);

    // Open the DemoRoleDialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog is visible
    expect(find.byType(DemoRoleDialog), findsOneWidget);
    expect(find.text('Select Demo Role'), findsOneWidget);

    // Tap Cancel button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify dialog is dismissed
    expect(find.byType(DemoRoleDialog), findsNothing);

    // Verify route did not change to /roles or anywhere else
    expect(router.state.matchedLocation, '/current-test-route');
    expect(find.text('Roles Screen'), findsNothing);
  });
}
