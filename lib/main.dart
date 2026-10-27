import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'app/router.dart';
import 'app/theme.dart';

Future<void> configureDesktopWindow() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize window_manager on desktop platforms
  try {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(AppTheme.minWindowWidth, AppTheme.minWindowHeight),
      center: true,
      backgroundColor: AppTheme.inkTeal,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } catch (e) {
    // window_manager not available on mobile, continue without it
  }
}

Future<void> main() async {
  await configureDesktopWindow();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  final GoRouter? routerConfig;
  final String appTitle;

  const MyApp({
    super.key,
    this.routerConfig,
    this.appTitle = 'Arpan Newborn Care Centre',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveRouter = routerConfig ?? ref.watch(routerProvider);
    return MaterialApp.router(
      title: appTitle,
      theme: AppTheme.lightTheme,
      routerConfig: effectiveRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
