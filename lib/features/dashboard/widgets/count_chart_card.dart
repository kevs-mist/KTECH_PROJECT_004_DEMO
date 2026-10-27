import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme.dart';
import '../../../core/aggregation.dart';

class CountChartCard extends StatefulWidget {
  final List<AggregationData> data;
  final ChartPeriod period;
  final ValueChanged<ChartPeriod> onPeriodChanged;

  const CountChartCard({
    super.key,
    required this.data,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  State<CountChartCard> createState() => _CountChartCardState();
}

class _CountChartCardState extends State<CountChartCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppTheme.space8,
            runSpacing: AppTheme.space8,
            children: [
              Text(
                'Admissions & Discharges',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _PeriodToggle(
                currentPeriod: widget.period,
                onPeriodChanged: widget.onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppTheme.inkTeal,
                    tooltipPadding: const EdgeInsets.all(AppTheme.space8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = widget.data[group.x.toInt()].label;
                      final value = rod.toY.round();
                      final type = rodIndex == 0 ? 'Admissions' : 'Discharges';
                      return BarTooltipItem(
                        '$label\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '$type: $value',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= widget.data.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppTheme.space8),
                          child: Text(
                            widget.data[value.toInt()].label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.hairline,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: AppTheme.inkTeal,
                label: 'Admissions',
              ),
              const SizedBox(width: AppTheme.space24),
              _LegendItem(
                color: AppTheme.success,
                label: 'Discharges',
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    final maxAdmissions = widget.data
        .map((d) => d.admissions)
        .reduce((a, b) => a > b ? a : b);
    final maxDischarges = widget.data
        .map((d) => d.discharges)
        .reduce((a, b) => a > b ? a : b);
    final max = maxAdmissions > maxDischarges ? maxAdmissions : maxDischarges;
    return (max * 1.2).ceilToDouble();
  }

  double _getInterval() {
    final maxY = _getMaxY();
    return (maxY / 5).ceilToDouble();
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.admissions.toDouble(),
            color: AppTheme.inkTeal,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: data.discharges.toDouble(),
            color: AppTheme.success,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
}

class _PeriodToggle extends StatelessWidget {
  final ChartPeriod currentPeriod;
  final ValueChanged<ChartPeriod> onPeriodChanged;

  const _PeriodToggle({
    required this.currentPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ChartPeriod>(
      segments: const [
        ButtonSegment(
          value: ChartPeriod.yearly,
          label: Text('Yearly'),
        ),
        ButtonSegment(
          value: ChartPeriod.monthly,
          label: Text('Monthly'),
        ),
        ButtonSegment(
          value: ChartPeriod.daily,
          label: Text('Daily'),
        ),
      ],
      selected: {currentPeriod},
      onSelectionChanged: (Set<ChartPeriod> selected) {
        onPeriodChanged(selected.first);
      },
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          Theme.of(context).textTheme.labelSmall,
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppTheme.space8),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.space8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}
