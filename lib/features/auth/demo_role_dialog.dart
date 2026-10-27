import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../data/providers/demo_providers.dart';
import '../../models/user_role.dart';
import 'auth_controller.dart';

class DemoRoleDialog extends ConsumerWidget {
  const DemoRoleDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const DemoRoleDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Demo Role',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                'Choose a role to explore the demo mode with sample data.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: AppTheme.space24),
              // Data Entry tile (filled teal style + badge "Full access")
              _DataEntryRoleTile(
                title: 'Data Entry',
                description: 'Full access including admissions and discharge',
                badgeText: 'Full access',
                onTap: () async {
                  final session = await ref
                      .read(mockAuthApiProvider)
                      .demoLogin(UserRole.dataEntry);
                  ref.read(authControllerProvider.notifier).startDemo(
                        role: session.role,
                        userName: session.userName,
                      );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    context.go('/dashboard');
                  }
                },
              ),
              const SizedBox(height: AppTheme.space16),
              // Doctor tile (outlined style + badge "Read only")
              _DoctorRoleTile(
                title: 'Doctor',
                description: 'View patients and dashboard in read-only mode',
                badgeText: 'Read only',
                onTap: () async {
                  final session = await ref
                      .read(mockAuthApiProvider)
                      .demoLogin(UserRole.doctor);
                  ref.read(authControllerProvider.notifier).startDemo(
                        role: session.role,
                        userName: session.userName,
                      );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    context.go('/dashboard');
                  }
                },
              ),
              const SizedBox(height: AppTheme.space24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataEntryRoleTile extends StatelessWidget {
  final String title;
  final String description;
  final String badgeText;
  final VoidCallback onTap;

  const _DataEntryRoleTile({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius12),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: AppTheme.inkTeal,
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.space8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorRoleTile extends StatelessWidget {
  final String title;
  final String description;
  final String badgeText;
  final VoidCallback onTap;

  const _DoctorRoleTile({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius12),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppTheme.inkTeal.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: AppTheme.inkTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
              child: const Icon(
                Icons.medical_services,
                color: AppTheme.inkTeal,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.softMint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Read only',
                          style: TextStyle(
                            color: AppTheme.inkTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.space8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
