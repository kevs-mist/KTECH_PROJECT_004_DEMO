# KTECH_PROJECT_004 — Demo Mode Fix Task List

> Generated from the Demo Mode UX & UI Audit — October 21, 2026  
> App: **Arpan Newborn Care Centre — Admissions Register** (Flutter)  
> Full report: see `demo_mode_report.md`

---

## 🔴 CRITICAL

### TASK-01 — Fix Repository Isolation: Share One `DemoAdmissionsRepository` Across All Screens
**Priority:** Critical  
**Affected Files:**
- `lib/features/dashboard/dashboard_screen.dart` (line 27)
- `lib/features/patients/patients_screen.dart` (line 26)
- `lib/features/patients/patient_detail_screen.dart` (line 24)
- `lib/features/admissions/admission_form_screen.dart`
- `lib/features/admissions/discharge_form_screen.dart`

**Problem:**  
Every screen creates its own `new DemoAdmissionsRepository()`. Because the demo repo is in-memory, each screen has a completely separate list of patients. Data admitted on one screen is invisible on all others.

**Solution:**  
1. Create a new file `lib/features/admissions/admissions_providers.dart`.
2. Declare a Riverpod provider that returns a shared singleton:
   ```dart
   final demoRepositoryProvider = Provider<AdmissionsRepository>((ref) {
     return DemoAdmissionsRepository();
   });
   ```
3. In every screen, replace the field declaration:
   ```dart
   // REMOVE this:
   final _repository = DemoAdmissionsRepository();
   
   // ADD this (inside ConsumerState.build or initState):
   final _repository = ref.read(demoRepositoryProvider);
   ```
4. For real (non-demo) mode, create an `apiRepositoryProvider` that returns `ApiAdmissionsRepository` and switch between them based on `authState.isDemo`.

**Acceptance Criteria:**  
- A patient admitted in `AdmissionFormScreen` appears immediately on the Dashboard and Patients screen without reload.
- Tapping a patient card from the Dashboard navigates to `PatientDetailScreen` and shows the correct patient record.

---

## 🔴 HIGH

### TASK-02 — Add "Try Demo" Entry Point to Role-Selection Screen
**Priority:** High  
**Affected Files:**
- `lib/features/auth/widgets/role_selection_cards.dart`
- `lib/screens/role_selection_screen.dart`

**Problem:**  
The demo mode is completely undiscoverable. There is no button or link on the role-selection screen.

**Solution:**  
1. Below the two role cards and above the footer divider, add a text link or subtle button:
   ```
   ─────────────────────────────────────────
   Or, explore with sample data  →
   ```
2. This button should call `DemoRoleDialog.show(context)` on tap.
3. Style it using `textSecondary` colour, small font (13–14sp), no fill, no border — visually subordinate to the real cards so real users are not distracted.

**Acceptance Criteria:**  
- A first-time user can see and tap "Explore with sample data" without any prior knowledge.
- Tapping it opens the `DemoRoleDialog` with role tiles.

---

### TASK-03 — Fix Broken "Cancel" Button in `DemoRoleDialog`
**Priority:** High  
**Affected Files:**
- `lib/features/auth/demo_role_dialog.dart` (line 98)

**Problem:**  
The Cancel button calls `context.go('/roles')`, which navigates the whole app instead of dismissing the dialog.

**Solution:**  
Replace line 98:
```dart
// REMOVE:
onPressed: () => context.go('/roles'),

// REPLACE WITH:
onPressed: () => Navigator.of(context).pop(),
```

**Acceptance Criteria:**  
- Tapping Cancel in the demo role dialog closes only the dialog.
- The screen behind the dialog (role-selection, login, etc.) remains unchanged.

---

### TASK-04 — Change Demo Banner from Alarm-Red to a Calm Info Style
**Priority:** High  
**Affected Files:**
- `lib/features/dashboard/dashboard_screen.dart` (lines 67–94)
- `lib/features/patients/patients_screen.dart` (lines 137–164)
- `lib/features/patients/patient_detail_screen.dart` (lines 76–103)

**Problem:**  
The demo banner uses `AppTheme.error` (red), `Icons.warning_amber_rounded`, and all-caps "DEMO MODE" text. This makes the app look broken and alarming on every screen.

**Solution:**  
1. Extract the banner into a shared widget at `lib/widgets/demo_banner.dart`:
   ```dart
   class DemoBanner extends StatelessWidget {
     const DemoBanner({super.key});
     
     @override
     Widget build(BuildContext context) {
       return Container(
         width: double.infinity,
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         color: const Color(0xFFFFF3CD), // soft amber
         child: Row(
           children: [
             const Icon(Icons.science_outlined, color: Color(0xFF856404), size: 18),
             const SizedBox(width: 8),
             Text(
               'Demo mode — changes won\'t be saved',
               style: Theme.of(context).textTheme.bodySmall?.copyWith(
                 color: const Color(0xFF856404),
                 fontWeight: FontWeight.w500,
               ),
             ),
           ],
         ),
       );
     }
   }
   ```
2. Replace all three `_buildDemoBanner()` methods with `const DemoBanner()`.

**Acceptance Criteria:**  
- Banner is amber/gold, not red.
- Icon is informational (not warning).
- Text is sentence-case, not all-caps.
- Banner is defined in one place only.

---

### TASK-05 — Add a Route Guard to Prevent Unauthenticated Access to Protected Routes
**Priority:** High  
**Affected Files:**
- `lib/app/router.dart` (lines 104–158)

**Problem:**  
Routes `/dashboard`, `/patients`, `/patients/:id`, `/admission/new`, and `/discharge` have no authentication check. A user who types `/dashboard` directly bypasses all auth.

**Solution:**  
Use GoRouter's `redirect` callback on the router level to check auth state:
```dart
redirect: (context, state) {
  final authState = ref.read(authControllerProvider);
  final protectedRoutes = ['/dashboard', '/patients', '/admission', '/discharge'];
  final isProtected = protectedRoutes.any((r) => state.uri.path.startsWith(r));
  
  if (isProtected && !authState.isAuthenticated) {
    return '/roles';
  }
  return null;
},
```

**Acceptance Criteria:**  
- Navigating to `/dashboard` without auth redirects to `/roles`.
- Demo and real auth sessions still work normally.

---

## 🟠 MEDIUM

### TASK-06 — Rename "Logout" to "Exit Demo" When in Demo Mode
**Priority:** Medium  
**Affected Files:**
- `lib/features/dashboard/dashboard_screen.dart` (line 127–134)
- `lib/features/patients/patients_screen.dart` (line 197–204)

**Problem:**  
The generic "Logout" label does not communicate that demo data will be discarded.

**Solution:**  
1. Make the button label conditional:
   ```dart
   label: Text(authState.isDemo ? 'Exit Demo' : 'Logout'),
   ```
2. After logout, show a brief `SnackBar` on the roles screen:
   ```
   'Demo session ended — all sample changes were discarded.'
   ```

**Acceptance Criteria:**  
- Button reads "Exit Demo" when `isDemo == true`.
- Button reads "Logout" for real auth sessions.
- A snackbar confirms the exit on the roles screen.

---

### TASK-07 — Remove Dead Code from `DemoRoleDialog`
**Priority:** Medium  
**Affected Files:**
- `lib/features/auth/demo_role_dialog.dart` (lines 8–38)

**Problem:**  
The public `DemoRoleDialog.build()` renders a broken empty `AlertDialog` that is never displayed. It is dead code that could be used accidentally.

**Solution:**  
1. Delete the `DemoRoleDialog` class `build()` method entirely (lines 12–31).
2. Keep only the static `show()` factory.
3. Rename `_DemoRoleSelectionDialog` to `_DemoRoleDialog` for clarity.

**Acceptance Criteria:**  
- The file contains only one dialog widget + the static `show()` method.
- No dead widget code remains.

---

### TASK-08 — Standardise Role Naming ("Admin" vs "Data Entry")
**Priority:** Medium  
**Affected Files:**
- `lib/features/auth/auth_shell.dart` (lines 336–346)
- `lib/features/auth/demo_role_dialog.dart` (lines 67–93)
- `lib/models/user_role.dart`

**Problem:**  
The left panel says "Data entry sign in", the demo dialog says "Admin", and `UserRole.dataEntry` is never used for demo mode.

**Solution (recommended):**  
Standardise on "Admin" across all locations:
1. Change `auth_shell.dart` `_getLoginTitle()` to return `'Admin sign in'` when `role == UserRole.admin`.
2. Update `_getLoginDescription()` to match.
3. Ensure the demo role chip, left panel, and dialog all say "Admin" consistently.

**Acceptance Criteria:**  
- Role is named consistently in the left panel, dialog, chip, and role card.

---

### TASK-09 — Add Demo Banner and Post-Submit Note to Admission & Discharge Forms
**Priority:** Medium  
**Affected Files:**
- `lib/features/admissions/admission_form_screen.dart`
- `lib/features/admissions/discharge_form_screen.dart`

**Problem:**  
Forms show no demo indication. A user could submit and think they created a real record.

**Solution:**  
1. Read `authState.isDemo` via Riverpod in both form screens.
2. Show `const DemoBanner()` at the top when `isDemo == true`.
3. After a successful demo submission, add a note:
   ```
   'Patient added to the demo session. This record will be cleared when you exit.'
   ```

**Acceptance Criteria:**  
- Demo banner visible at the top of both forms in demo mode.
- Post-submission note shown only in demo mode.

---

### TASK-10 — Add Visual Differentiation Between Demo Role Tiles
**Priority:** Medium  
**Affected Files:**
- `lib/features/auth/demo_role_dialog.dart` (lines 67–107)

**Problem:**  
Both Doctor and Admin tiles look identical. No visual signal about capability level.

**Solution:**  
1. Style the Admin tile as filled/primary (teal background, white text).
2. Style the Doctor tile as outlined/secondary (white background, teal border).
3. Add a capability line below each title:
   - Admin: `"Full access — admit, discharge, view"`
   - Doctor: `"Read only — view records"`

**Acceptance Criteria:**  
- The two tiles are visually distinct at a glance.
- A user can immediately tell which role has more permissions.

---

## 🟡 LOW

### TASK-11 — Make Patient Grid Responsive to Window Width
**Priority:** Low  
**Affected Files:**
- `lib/features/patients/patients_screen.dart` (lines 343–359)

**Problem:**  
`crossAxisCount: 3` is hardcoded regardless of window size.

**Solution:**  
```dart
// Replace:
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3, ...
),

// With:
gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 380,
  crossAxisSpacing: AppTheme.space16,
  mainAxisSpacing: AppTheme.space16,
  childAspectRatio: 2.5,
),
```

**Acceptance Criteria:**  
- Grid adapts columns to window width automatically.

---

### TASK-12 — Add "Demo" Indicator to the Top Bar Role Chip
**Priority:** Low  
**Affected Files:**
- `lib/features/dashboard/dashboard_screen.dart` (`_RoleChip` — lines 350–390)
- `lib/features/patients/patients_screen.dart` (`_RoleChip` — lines 363–403)

**Problem:**  
Role chip shows "Doctor" or "Admin" identically in real and demo sessions.

**Solution:**  
Pass `isDemo` into `_RoleChip` and append `" (Demo)"`:
```dart
Text('${_getRoleLabel(role)}${isDemo ? ' (Demo)' : ''}', ...)
```

**Acceptance Criteria:**  
- Demo mode shows "Doctor (Demo)" or "Admin (Demo)" in top bar.
- Real auth mode shows "Doctor" or "Admin" only.

---

### TASK-13 — Show a Welcome Snackbar on First Demo Dashboard Entry
**Priority:** Low  
**Affected Files:**
- `lib/features/dashboard/dashboard_screen.dart`

**Problem:**  
Users enter demo mode with no orientation or guidance.

**Solution:**  
In `DashboardScreen.initState()`, check `authState.isDemo` and show a one-time `SnackBar`:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Welcome to the demo. Try Patients → New Admission to explore the full workflow.',
      ),
      duration: Duration(seconds: 6),
    ),
  );
});
```

**Acceptance Criteria:**  
- Snackbar appears once on first demo dashboard entry.
- Does not appear on return visits or in real auth sessions.

---

### TASK-14 — Add "Try Demo" Link to Login Screens
**Priority:** Low  
**Affected Files:**
- `lib/features/auth/screens/login_screen.dart`

**Problem:**  
Users on the login screen have no path to demo mode without going back.

**Solution:**  
Add a `TextButton` below the login form:
```
Just exploring? Try the demo →
```
Calls `DemoRoleDialog.show(context)` on tap.

**Acceptance Criteria:**  
- Link is visible on both Doctor and Admin login screens.
- Tapping it opens the demo role selection dialog.

---

## Completion Checklist

| Task | Description | Status |
|---|---|---|
| TASK-01 | Shared demo repository via Riverpod provider | ☐ |
| TASK-02 | "Try Demo" entry point on role-selection screen | ☐ |
| TASK-03 | Fix Cancel button navigation bug in demo dialog | ☐ |
| TASK-04 | Amber info-style demo banner + shared widget | ☐ |
| TASK-05 | Auth route guard on protected routes | ☐ |
| TASK-06 | "Exit Demo" button label + confirmation snackbar | ☐ |
| TASK-07 | Remove dead `DemoRoleDialog.build()` code | ☐ |
| TASK-08 | Standardise "Admin" / "Data Entry" naming | ☐ |
| TASK-09 | Demo banner + post-submit note on forms | ☐ |
| TASK-10 | Visual differentiation between demo role tiles | ☐ |
| TASK-11 | Responsive patient grid (MaxCrossAxisExtent) | ☐ |
| TASK-12 | "Demo" label in top-bar role chip | ☐ |
| TASK-13 | Welcome snackbar on first demo entry | ☐ |
| TASK-14 | "Try Demo" link on login screens | ☐ |
