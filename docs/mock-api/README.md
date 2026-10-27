# Temporary Demo API

**TEMPORARY - DELETE WHEN REAL API IS LIVE**

The current application has a Dart `MockAdmissionsApi` and demo repository inside the Flutter app. It is an in-process data adapter for local evaluation, not a standalone Node/Express mock server. It does not implement HTTP routes or establish parity with a production network contract. The compile-time demo switch is `--dart-define=ENABLE_DEMO=true`; `USE_MOCK_API=true` is not currently supported.

The real API contract and deployment target have not been supplied. Do not claim route-level contract parity until that specification exists. Before a production API is connected, document its request/response and error shapes, add contract tests against both implementations, and switch providers behind one configuration boundary.

## Deletion Checklist

- [ ] Delete the temporary `mock-api` branch after its changes have been merged or discarded.
- [ ] Remove the mock implementation and demo-only fixtures from `lib/data/api/` and related demo providers/repositories.
- [ ] Remove the `ENABLE_DEMO` compile-time flag and all demo-only UI/configuration paths.
- [ ] Remove any mock-only CI job or contract-test wiring added during the temporary period.
- [ ] Confirm production API tests pass and no mock data is reachable in release builds.