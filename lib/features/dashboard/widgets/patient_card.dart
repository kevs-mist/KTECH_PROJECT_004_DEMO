import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../admissions/models/patient_stay.dart';

class PatientCard extends StatelessWidget {
  final PatientStay patient;
  final VoidCallback? onTap;

  const PatientCard({super.key, required this.patient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius12),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          border: Border.all(color: AppTheme.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row with title, prefix, and status
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          patient.displayName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space4),
                      _PrefixChip(prefix: patient.prefix),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                _StatusChip(status: patient.dischargeStatus),
              ],
            ),
            const SizedBox(height: AppTheme.space6),
            // Compact details row - all visible at once
            Row(
              children: [
                Expanded(
                  child: _CompactDetail(
                    icon: Icons.local_hospital,
                    value: patient.branch == null
                        ? patient.del
                        : patient.branch == Branch.arpanMother
                        ? 'Arpan Mother'
                        : 'Arpan Violet',
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                Expanded(
                  child: _CompactDetail(
                    icon: Icons.phone,
                    value: patient.contactNumber,
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                _CompactDetail(
                  icon: Icons.access_time,
                  value: patient.daysStayedText,
                  isHighlighted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactDetail extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isHighlighted;

  const _CompactDetail({
    required this.icon,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isHighlighted ? AppTheme.inkTeal : AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.space4),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isHighlighted
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PrefixChip extends StatelessWidget {
  final Prefix prefix;

  const _PrefixChip({required this.prefix});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (prefix) {
      case Prefix.so:
        label = 'S/O';
        break;
      case Prefix.do_:
        label = 'D/O';
        break;
      case Prefix.bo:
        label = 'B/O';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.inkTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppTheme.inkTeal, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DischargeStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isAdmitted = status == DischargeStatus.admitted;
    final label = isAdmitted ? 'Admitted' : 'Discharged';
    final color = isAdmitted ? AppTheme.success : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
