import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/aggregation.dart';
import '../../data/providers/demo_providers.dart';
import '../../features/admissions/models/patient_stay.dart';
import '../../features/auth/auth_controller.dart';
import '../../widgets/clinical_workspace.dart';
import 'widgets/count_chart_card.dart';
import 'widgets/kpi_tile.dart';
import 'widgets/patient_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  ChartPeriod _chartPeriod = ChartPeriod.yearly;
  final int _selectedYear = DateTime.now().year;
  final int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authControllerProvider);
      final alreadyShown = ref.read(demoWelcomeShownProvider);
      if (auth.isDemo && !alreadyShown && mounted) {
        ref.read(demoWelcomeShownProvider.notifier).state = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Welcome to the demo. You're viewing sample patient data. Try Dashboard → Patients → New Admission to explore the full workflow.",
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncPatients = ref.watch(admissionsListProvider);

    return ClinicalWorkspace(
      title: 'Dashboard',
      child: asyncPatients.when(
        data: (patients) => _buildDashboardContent(patients),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error loading data: $error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.space16),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(admissionsListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(List<PatientStay> patients) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final admittedCount = patients.where((p) => p.dod == null).length;
    final twinCount = patients
        .where((p) => p.birthType == BirthType.twin)
        .length;
    final tripletCount = patients
        .where((p) => p.birthType == BirthType.triplet)
        .length;
    final admissionsToday = patients
        .where((p) => p.doa.isAfter(todayStart) && p.doa.isBefore(todayEnd))
        .length;
    final dischargesToday = patients
        .where(
          (p) =>
              p.dod != null &&
              p.dod!.isAfter(todayStart) &&
              p.dod!.isBefore(todayEnd),
        )
        .length;

    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final dischargedInRange = patients
        .where(
          (p) =>
              p.dod != null &&
              p.dod!.isAfter(thirtyDaysAgo) &&
              p.dod!.isBefore(now),
        )
        .toList();
    final avgDaysStayed = dischargedInRange.isEmpty
        ? 0.0
        : dischargedInRange.fold<int>(0, (sum, p) => sum + p.daysStayed) /
              dischargedInRange.length;

    final recentAdmissions = patients.where((p) => p.dod == null).toList()
      ..sort((a, b) => b.doa.compareTo(a.doa));
    final recentAdmissionsList = recentAdmissions.take(10).toList();

    final recentDischarges = patients.where((p) => p.dod != null).toList()
      ..sort((a, b) => b.dod!.compareTo(a.dod!));
    final recentDischargesList = recentDischarges.take(10).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppTheme.space16,
            runSpacing: AppTheme.space16,
            children: [
              KPITile(
                label: 'Total Admitted Now',
                value: admittedCount.toString(),
                icon: Icons.bed,
                iconColor: AppTheme.inkTeal,
              ),
              KPITile(
                label: 'Admissions Today',
                value: admissionsToday.toString(),
                icon: Icons.add_circle_outline,
                iconColor: AppTheme.inkTeal,
              ),
              KPITile(
                label: 'Discharges Today',
                value: dischargesToday.toString(),
                icon: Icons.remove_circle_outline,
                iconColor: AppTheme.success,
              ),
              KPITile(
                label: 'Avg Days Stayed (30 days)',
                value: avgDaysStayed.toStringAsFixed(1),
                icon: Icons.schedule,
                iconColor: AppTheme.textSecondary,
              ),
              KPITile(
                label: 'Twin Admissions',
                value: twinCount.toString(),
                icon: Icons.people_outline,
                iconColor: AppTheme.inkTeal,
              ),
              KPITile(
                label: 'Triplet Admissions',
                value: tripletCount.toString(),
                icon: Icons.groups_outlined,
                iconColor: AppTheme.success,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space24),
          CountChartCard(
            data: _getChartData(patients),
            period: _chartPeriod,
            onPeriodChanged: (period) {
              setState(() {
                _chartPeriod = period;
              });
            },
          ),
          const SizedBox(height: AppTheme.space24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnWidth = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - AppTheme.space24) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: AppTheme.space24,
                runSpacing: AppTheme.space24,
                children: [
                  SizedBox(
                    width: columnWidth,
                    child: _Section(
                      title: 'Recent Admissions',
                      child: _buildRecentPatients(
                        recentAdmissionsList,
                        emptyText: 'No recent admissions',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _Section(
                      title: 'Recent Discharges',
                      child: _buildRecentPatients(
                        recentDischargesList,
                        emptyText: 'No recent discharges',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPatients(
    List<PatientStay> patients, {
    required String emptyText,
  }) {
    if (patients.isEmpty) {
      return Text(
        emptyText,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppTheme.textSecondary),
      );
    }
    return Column(
      children: patients
          .map(
            (patient) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space12),
              child: PatientCard(
                patient: patient,
                onTap: () => context.go('/patients/${patient.id}'),
              ),
            ),
          )
          .toList(),
    );
  }

  List<AggregationData> _getChartData(List<PatientStay> patients) {
    switch (_chartPeriod) {
      case ChartPeriod.yearly:
        final financialYears = getLast5FinancialYears();
        return aggregateByYear(patients, financialYears);
      case ChartPeriod.monthly:
        final fy = getFinancialYear(DateTime(_selectedYear, _selectedMonth));
        return aggregateByMonth(patients, fy);
      case ChartPeriod.daily:
        return aggregateByDay(patients, _selectedYear, _selectedMonth);
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppTheme.space16),
        child,
      ],
    );
  }
}
