import 'package:flutter/material.dart';

import '../../../app/theme.dart';

enum BannerType { error, success }

class InlineBanner extends StatelessWidget {
  final String message;
  final BannerType type;
  final VoidCallback? onDismiss;

  const InlineBanner({
    super.key,
    required this.message,
    required this.type,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isError = type == BannerType.error;
    final backgroundColor = isError
        ? AppTheme.error.withValues(alpha: 0.1)
        : AppTheme.success.withValues(alpha: 0.1);
    final iconColor = isError ? AppTheme.error : AppTheme.success;
    final textColor = isError ? AppTheme.error : AppTheme.success;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(
          color: isError ? AppTheme.error : AppTheme.success,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppTheme.space12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: textColor),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: textColor,
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppTheme.tapTarget,
                  minHeight: AppTheme.tapTarget,
                ),
                tooltip: 'Dismiss',
              ),
          ],
        ),
      ),
    );
  }
}
