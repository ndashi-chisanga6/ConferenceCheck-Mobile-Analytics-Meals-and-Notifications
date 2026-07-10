import 'package:conference_check_mobile/features/auth/application/auth_providers.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/notifications/application/notifications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendeeHomeScreen extends ConsumerWidget {
  const AttendeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final event = ref.watch(selectedEventProvider);
    final notifications = ref.watch(notificationsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_available),
            title: Text(event?.name ?? 'No event selected'),
            subtitle: Text(event?.venue ?? ''),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(user?.name ?? ''),
            subtitle: Text(user?.email ?? ''),
          ),
        ),
        Text(
          'Latest notifications',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        notifications.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(error.toString()),
          data: (items) => Column(
            children: [
              for (final item in items.take(3))
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: Text(item.title),
                    subtitle: Text(item.message),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
