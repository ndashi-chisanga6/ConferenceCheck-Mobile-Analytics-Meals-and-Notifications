import 'package:conference_check_mobile/features/dashboard/data/analytics_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MealsChart extends StatelessWidget {
  const MealsChart({required this.points, super.key});

  final List<CountPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Text('No meal redemption data yet.');
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].count.toDouble(),
                    color: Theme.of(context).colorScheme.secondary,
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
