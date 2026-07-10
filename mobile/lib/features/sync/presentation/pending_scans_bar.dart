import 'package:conference_check_mobile/features/sync/application/scan_sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows how many offline scans are waiting and offers a manual sync.
/// Renders nothing when the queue is empty.
class PendingScansBar extends ConsumerWidget {
  const PendingScansBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingScanCountProvider).value ?? 0;
    final sync = ref.watch(scanSyncControllerProvider);

    if (pending == 0 && sync.message == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      child: ListTile(
        leading: sync.syncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(Icons.cloud_off, color: Colors.orange),
        title: Text(
          pending > 0
              ? '$pending offline scan${pending == 1 ? '' : 's'} waiting to sync'
              : (sync.message ?? ''),
        ),
        subtitle: pending > 0 && sync.message != null
            ? Text(sync.message!)
            : null,
        trailing: pending > 0
            ? TextButton.icon(
                onPressed: sync.syncing
                    ? null
                    : () =>
                          ref.read(scanSyncControllerProvider.notifier).flush(),
                icon: const Icon(Icons.sync),
                label: const Text('Sync now'),
              )
            : null,
      ),
    );
  }
}
