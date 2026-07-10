import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/features/sessions/application/sessions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SessionDetailsScreen extends ConsumerWidget {
  const SessionDetailsScreen({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(selectedSessionProvider);
    final attendance = ref.watch(sessionAttendanceProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: Text(session?.title ?? 'Session details')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (session != null) {
            ref.read(selectedSessionProvider.notifier).select(session);
          }
          context.push('/session-scan');
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (session != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_seat),
                title: Text(session.title),
                subtitle: Text(
                  '${session.venue}\n${formatTimeRange(session.startsAt, session.endsAt)}\n${session.attendanceCount}/${session.capacity} attendees',
                ),
                isThreeLine: true,
              ),
            ),
          Text(
            'Attendance',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          attendance.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(message: error.toString()),
            data: (items) => items.isEmpty
                ? const EmptyView(
                    message: 'No attendees checked into this session yet.',
                  )
                : Column(
                    children: [
                      for (final row in items)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(
                              row.attendee?.fullName ?? 'Attendee #${row.id}',
                            ),
                            subtitle: Text(formatDateTime(row.checkedInAt)),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
