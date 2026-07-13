import 'dart:math' as math;

import 'package:conference_check_mobile/app/theme.dart';
import 'package:conference_check_mobile/features/dashboard/data/analytics_models.dart';
import 'package:flutter/material.dart';

/// Gradient hero header for the organiser dashboard: event name, an
/// animated check-in gauge, and the day's headline numbers.
class DashboardHero extends StatelessWidget {
  const DashboardHero({required this.summary, this.eventName, super.key});

  final AnalyticsSummary summary;
  final String? eventName;

  @override
  Widget build(BuildContext context) {
    final pct = summary.checkInPercentage.toDouble().clamp(0, 100).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: AppBrand.heroGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIVE OVERVIEW',
                      style: TextStyle(
                        color: AppBrand.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      eventName ?? 'Your event',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${summary.checkedInAttendees} of ${summary.totalAttendees} attendees checked in',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _CheckInGauge(percentage: pct),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                icon: Icons.restaurant,
                label:
                    '${summary.redeemedMealVouchers}/${summary.totalMealVouchers} meals',
              ),
              _HeroChip(
                icon: Icons.meeting_room_outlined,
                label: '${summary.totalSessions} sessions',
              ),
              if (summary.overcrowdedSessionsCount > 0)
                _HeroChip(
                  icon: Icons.warning_amber,
                  label: '${summary.overcrowdedSessionsCount} over capacity',
                  emphasis: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    this.emphasis = false,
  });

  final IconData icon;
  final String label;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final color = emphasis ? AppBrand.amber : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: emphasis ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInGauge extends StatelessWidget {
  const _CheckInGauge({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: 92,
        height: 92,
        child: CustomPaint(
          painter: _GaugePainter(value / 100),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${value.round()}%',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'checked in',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;
    const start = -math.pi / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawCircle(center, radius, track);

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: start,
        endAngle: start + 2 * math.pi,
        colors: [AppBrand.amber, Colors.white],
        transform: GradientRotation(start),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
