import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/core/widgets/empty_view.dart';
import 'package:conference_check_mobile/core/widgets/error_view.dart';
import 'package:conference_check_mobile/core/widgets/loading_view.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventSelectionScreen extends ConsumerWidget {
  const EventSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select event')),
      body: events.when(
        loading: () => const LoadingView(message: 'Loading events...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(eventsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              message: 'No events are assigned to this account.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final event = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(event.name),
                  subtitle: Text(
                    '${event.venue}\n${formatDateTime(event.startsAt)}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await ref
                        .read(selectedEventProvider.notifier)
                        .select(event);
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
