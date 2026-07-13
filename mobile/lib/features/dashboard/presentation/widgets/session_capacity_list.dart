import 'package:conference_check_mobile/app/theme.dart';
import 'package:conference_check_mobile/core/widgets/status_badge.dart';
import 'package:conference_check_mobile/features/dashboard/data/analytics_models.dart';
import 'package:flutter/material.dart';

class SessionCapacityList extends StatelessWidget {
  const SessionCapacityList({required this.sessions, super.key});

  final List<SessionAnalytics> sessions;

  Color _statusColor(SessionAnalytics session) {
    if (session.attendanceTotal > session.capacity) return AppBrand.danger;
    if (session.percentageFull >= 80) return AppBrand.warn;
    return AppBrand.ok;
  }

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const Text('No session analytics yet.');
    return Column(
      children: [
        for (final session in sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      '${session.percentageFull.toStringAsFixed(0)}%',
                      color: _statusColor(session),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (session.percentageFull / 100).clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 7,
                      color: _statusColor(session),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${session.attendanceTotal} of ${session.capacity} seats',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
