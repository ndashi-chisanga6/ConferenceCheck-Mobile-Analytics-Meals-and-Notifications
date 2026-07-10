import 'package:conference_check_mobile/core/widgets/status_badge.dart';
import 'package:conference_check_mobile/features/dashboard/data/analytics_models.dart';
import 'package:flutter/material.dart';

class SessionCapacityList extends StatelessWidget {
  const SessionCapacityList({required this.sessions, super.key});

  final List<SessionAnalytics> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const Text('No session analytics yet.');
    return Column(
      children: [
        for (final session in sessions)
          Card(
            child: ListTile(
              title: Text(session.title),
              subtitle: Text(
                '${session.attendanceTotal}/${session.capacity} attendees',
              ),
              trailing: StatusBadge(
                '${session.percentageFull.toStringAsFixed(0)}%',
              ),
            ),
          ),
      ],
    );
  }
}
