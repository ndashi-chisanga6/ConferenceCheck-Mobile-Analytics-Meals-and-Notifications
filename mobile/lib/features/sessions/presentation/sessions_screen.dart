import 'package:conference_check_mobile/core/utils/capacity_status.dart';
import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/core/widgets/status_badge.dart';
import 'package:conference_check_mobile/features/sessions/application/sessions_providers.dart';
import 'package:conference_check_mobile/features/sessions/data/session_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    return sessions.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(sessionsProvider),
      ),
      data: (items) => items.isEmpty
          ? const EmptyView(message: 'No sessions yet.')
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(sessionsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _SessionCard(session: items[index]),
              ),
            ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session});
  final ConferenceSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = capacityStatusFor(
      attendance: session.attendanceCount,
      capacity: session.capacity,
    );
    return Card(
      child: ListTile(
        leading: const Icon(Icons.meeting_room_outlined),
        title: Text(session.title),
        subtitle: Text(
          '${session.venue}\n${formatTimeRange(session.startsAt, session.endsAt)}\n${session.attendanceCount}/${session.capacity} attendees',
        ),
        isThreeLine: true,
        trailing: StatusBadge(capacityStatusLabel(status)),
        onTap: () {
          ref.read(selectedSessionProvider.notifier).select(session);
          context.push('/sessions/${session.id}');
        },
      ),
    );
  }
}
