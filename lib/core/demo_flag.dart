/// Demo mode flag - only enabled with --dart-define=ENABLE_DEMO=true
/// This provides a compile-time check for demo mode availability
class DemoFlag {
  static const bool isEnabled = bool.fromEnvironment(
    'ENABLE_DEMO',
    defaultValue: false,
  );
}
