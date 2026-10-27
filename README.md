# KTECH_PROJECT_004_DEMO

[![CI](https://github.com/kevs-mist/KTECH_PROJECT_004_DEMO/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/kevs-mist/KTECH_PROJECT_004_DEMO/actions/workflows/ci.yml)
![Coverage policy](https://img.shields.io/badge/coverage%20gate-80%25-informational)
![License](https://img.shields.io/badge/license-not%20selected-lightgrey)

## Overview

KTECH Project 004 is a Flutter desktop application for the Arpan Newborn Care Centre admissions register. It provides role-based access, admissions and discharge workflows, patient records, dashboards, and reports. The compile-time demo mode uses seeded in-process data; it is intended for evaluation and does not connect to a production HTTP API.

## Features

- Admissions, patient stay, and discharge workflows.
- Dashboard and patient views backed by Riverpod providers.
- Report aggregation and PDF export.
- GoRouter navigation and role selection.
- Optional demo mode enabled at build/run time.

## Tech Stack

- Flutter and Dart
- Riverpod for state management
- GoRouter for navigation
- `flutter_test` for unit and widget tests
- GitHub Actions for analysis, tests, and coverage artifacts

## Architecture

The repository is kept in its working Flutter layout. The requested React `ui/` and Node `backend/` split does not describe this application; moving files into those folders would break package imports and Flutter asset discovery. `lib/backend/` contains application repositories and report services, not an Express server.

```text
assets/                  Fonts and image assets
database/                Database schema
lib/
	app/                   App theme and router
	backend/               Admissions repositories and report services
	core/                  Shared calculations and validation
	data/                  API abstractions and providers
	features/              Admissions, auth, dashboard, patients, reports
	models/                Shared models
	screens/                Top-level screens
	widgets/               Shared widgets
test/                    Unit, widget, repository, and API-adapter tests
scripts/                 Coverage gate and branch push helpers
.github/workflows/       CI and deployment placeholder
```

## Requirements

- Flutter stable with the Dart SDK constraint in `pubspec.yaml`
- Git
- Python 3 for the local coverage-threshold helper

Install dependencies and run the Windows desktop application from PowerShell:

```powershell
flutter pub get
flutter run -d windows
```

To enable the compile-time demo experience:

```powershell
flutter run -d windows --dart-define=ENABLE_DEMO=true
```

Demo mode defaults to disabled. The flag is `ENABLE_DEMO`; `USE_MOCK_API` is not used by this Flutter app. See [the temporary demo API note](docs/mock-api/README.md) for the mock's actual scope and cleanup checklist.

## Tests and Coverage

Run static analysis and all tests:

```powershell
flutter analyze --fatal-infos
flutter test --coverage
python scripts/check_coverage.py coverage/lcov.info --threshold 80
```

The coverage gate measures line coverage for `lib/` and fails below 80%. The current checked-in tests pass, but the measured baseline is 34.7%; therefore the coverage step will remain red until tests raise coverage to the threshold. Coverage is uploaded by CI even when a test or threshold step fails. Do not lower the threshold to hide a shortfall.

## CI and Deployment

`.github/workflows/ci.yml` runs for pushes and pull requests targeting any branch, analyzes the Dart code, runs the complete test suite, enforces the coverage threshold, and uploads an LCOV artifact. Since this repository is one Flutter application rather than separate UI and backend packages, CI tests the complete app instead of path-filtering nonexistent `ui/` and `backend/` folders.

`.github/workflows/cd.yml` listens for changes merged to `main` and for manual dispatch, but deployment is intentionally disabled: no deployment provider or target has been selected. No GitHub secrets are currently required. Once a target is selected, configure its credentials as repository Actions secrets and replace the placeholder job with the provider's deploy action. Do not store credentials in the repository.

For `main` branch protection, require pull requests and require the `CI / analyze` and `CI / tests` checks before merge. Optionally require one approval and dismiss stale approvals. Apply the rule to `main`; do not require administrators to bypass it unless your team policy allows that.

## Branching Strategy

The requested branch names can be used as parallel work streams without pretending they are separate deployable packages:

- `main`: reviewed, integrated application.
- `ui`: Flutter UI work based on `main`.
- `backend`: Flutter repositories, data, and reporting work based on `main`; this is not a Node server.
- `ui-screens`: screen-specific work based on `ui` (`ui/screens` cannot coexist with the `ui` branch in Git).
- `ui-components`: shared widget work based on `ui` (`ui/components` has the same Git ref-name conflict).
- `mock-api`: temporary work on the existing in-process mock/demo data path, based on `main`.

Create the branches after the complete Flutter baseline has been committed to `main`. The full creation and push sequence is in [PUSH_PLAN.md](PUSH_PLAN.md). The push helper limits successful pushes to one main-level feature branch and two UI sub-branches per local calendar day. README-first publication is a separate manual Day 1 operation.

## Contributing

1. Create a focused branch from the appropriate base branch.
2. Keep commits small and use conventional prefixes such as `feat:`, `fix:`, `test:`, `ci:`, `docs:`, and `chore:`.
3. Run `flutter analyze --fatal-infos`, `flutter test --coverage`, and the coverage checker before opening a pull request.
4. Open a pull request to `main` with the behavior change, tests, and any known limitations described.
5. Merge only after required checks pass and branch protection requirements are satisfied.

## License

No license has been selected for this repository. All rights are reserved by default; do not redistribute or reuse the software until the owner adds an explicit license.
