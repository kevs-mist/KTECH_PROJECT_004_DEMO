import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class BackLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const BackLink({
    super.key,
    this.label = 'Back',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_back),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space8,
          vertical: AppTheme.space8,
        ),
      ),
    );
  }
}
