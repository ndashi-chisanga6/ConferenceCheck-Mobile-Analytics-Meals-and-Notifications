import 'package:conference_check_mobile/features/dashboard/data/analytics_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CheckinsChart extends StatelessWidget {
  const CheckinsChart({required this.points, super.key});

  final List<CountPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Text('No check-in data yet.');
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].count.toDouble()),
    ];
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Theme.of(context).colorScheme.primary,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
