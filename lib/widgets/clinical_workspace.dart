import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/providers/demo_providers.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/demo_role_dialog.dart';
import '../models/user_role.dart';
import 'demo_banner.dart';

class ClinicalWorkspace extends ConsumerWidget {
  final String title;
  final Widget child;

  const ClinicalWorkspace({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final path = GoRouterState.of(context).uri.path;
    final compact = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: Column(
        children: [
          if (auth.isDemo) const DemoBanner(),
          _WorkspaceHeader(
            title: title,
            userName: auth.userName ?? 'User',
            role: auth.role,
            isDemo: auth.isDemo,
            compact: compact,
            onSwitchRole: () => DemoRoleDialog.show(context),
            onLogout: () async {
              if (auth.isDemo) {
                final shouldExit = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Exit demo?'),
                    content: const Text(
                      'Exit demo? All sample data was temporary.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
                );

                if (shouldExit == true) {
                  ref.read(mockAdmissionsApiProvider).reset();
                  ref.read(demoWelcomeShownProvider.notifier).state = false;
                  ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/roles');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Demo session ended — all sample changes were discarded.',
                        ),
                      ),
                    );
                  }
                }
              } else {
                ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/roles');
                }
              }
            },
          ),
          _WorkspaceNavigation(
            path: path,
            canWrite: auth.canWrite,
            compact: compact,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth.clamp(0, 1480),
                  height: constraints.maxHeight,
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  final String title;
  final String userName;
  final UserRole? role;
  final bool isDemo;
  final bool compact;
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const _WorkspaceHeader({
    required this.title,
    required this.userName,
    required this.role,
    required this.isDemo,
    required this.compact,
    required this.onSwitchRole,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppTheme.space16 : AppTheme.space32,
        vertical: AppTheme.space16,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.hairline)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.inkTeal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.child_care, color: Colors.white, size: 23),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  compact ? title : 'Arpan Newborn Care Centre',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (!compact)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: AppTheme.space16),
            Text(userName, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: AppTheme.space8),
            _RoleLabel(role: role, isDemo: isDemo),
          ],
          if (isDemo) ...[
            const SizedBox(width: AppTheme.space8),
            IconButton(
              tooltip: 'Switch role',
              onPressed: onSwitchRole,
              icon: const Icon(Icons.swap_horiz),
            ),
          ],
          const SizedBox(width: AppTheme.space8),
          IconButton(
            tooltip: isDemo ? 'Exit demo' : 'Log out',
            onPressed: onLogout,
            icon: Icon(isDemo ? Icons.exit_to_app : Icons.logout),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceNavigation extends StatelessWidget {
  final String path;
  final bool canWrite;
  final bool compact;

  const _WorkspaceNavigation({
    required this.path,
    required this.canWrite,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData)>[
      ('/dashboard', 'Dashboard', Icons.dashboard_outlined),
      ('/patients', 'Patients', Icons.child_friendly_outlined),
      ('/reports', 'Present / Report', Icons.table_view_outlined),
      if (canWrite) ...[
        ('/admission/new', 'New Admission', Icons.person_add_alt_1_outlined),
        ('/discharge', 'Discharge', Icons.exit_to_app_outlined),
      ],
    ];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.hairline)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppTheme.space8 : AppTheme.space24,
            vertical: AppTheme.space8,
          ),
          child: Row(
            children: items.map((item) {
              final active =
                  path == item.$1 ||
                  (item.$1 == '/patients' && path.startsWith('/patients/'));
              return Padding(
                padding: const EdgeInsets.only(right: AppTheme.space8),
                child: TextButton.icon(
                  onPressed: () => context.go(item.$1),
                  icon: Icon(item.$3, size: 18),
                  label: Text(item.$2),
                  style: TextButton.styleFrom(
                    foregroundColor: active
                        ? AppTheme.inkTeal
                        : AppTheme.textSecondary,
                    backgroundColor: active
                        ? AppTheme.inkTeal.withValues(alpha: 0.09)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space16,
                      vertical: AppTheme.space12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RoleLabel extends StatelessWidget {
  final UserRole? role;
  final bool isDemo;

  const _RoleLabel({required this.role, this.isDemo = false});

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      UserRole.admin => 'Data Entry',
      UserRole.dataEntry => 'Data Entry',
      UserRole.doctor => 'Doctor',
      null => 'Guest',
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space8,
            vertical: AppTheme.space4,
          ),
          decoration: BoxDecoration(
            color: AppTheme.softMint,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.inkTeal,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (isDemo) ...[
          const SizedBox(width: 6),
          const DemoChip(),
        ],
      ],
    );
  }
}
