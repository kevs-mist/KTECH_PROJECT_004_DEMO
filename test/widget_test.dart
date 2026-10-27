// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ktech_project_004/app/router.dart' show createRouter;
import 'package:ktech_project_004/main.dart';

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
}
