import 'package:conference_check_mobile/features/auth/application/auth_providers.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final event = ref.watch(selectedEventProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(user?.name ?? 'Unknown user'),
            subtitle: Text('${user?.email ?? ''}\n${user?.role ?? ''}'),
            isThreeLine: true,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Selected event'),
            subtitle: Text(event?.name ?? 'No event selected'),
            trailing: TextButton(
              onPressed: () async {
                await ref.read(selectedEventProvider.notifier).clear();
                if (context.mounted) context.go('/events');
              },
              child: const Text('Change'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}
