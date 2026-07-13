import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/core/offline/queued_scan.dart';
import 'package:conference_check_mobile/core/offline/scan_queue.dart';
import 'package:conference_check_mobile/features/meals/application/meals_providers.dart';
import 'package:conference_check_mobile/features/sessions/application/sessions_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scanQueueProvider = Provider<ScanQueue>((ref) => ScanQueue());

final pendingScanCountProvider = FutureProvider<int>(
  (ref) => ref.watch(scanQueueProvider).count(),
);

class ScanSyncState {
  const ScanSyncState({this.syncing = false, this.message});
  final bool syncing;
  final String? message;
}

/// Replays queued offline scans against the API in order. A definitive
/// server answer (success, already redeemed, duplicate, invalid token)
/// removes the entry; a connectivity failure keeps it and stops the run.
class ScanSyncController extends Notifier<ScanSyncState> {
  @override
  ScanSyncState build() => const ScanSyncState();

  Future<void> flush() async {
    final queue = ref.read(scanQueueProvider);
    final items = await queue.pending();
    if (items.isEmpty || state.syncing) return;

    state = const ScanSyncState(syncing: true);
    final remaining = <QueuedScan>[];
    var synced = 0;
    var resolved = 0;
    var offline = false;

    for (final item in items) {
      if (offline) {
        remaining.add(item);
        continue;
      }
      try {
        if (item.type == QueuedScan.session && item.sessionId != null) {
          await ref
              .read(sessionsApiProvider)
              .scan(
                item.eventId,
                item.sessionId!,
                qrToken: item.qrToken,
                deviceId: item.deviceId,
              );
        } else {
          await ref
              .read(mealsApiProvider)
              .scan(item.eventId, item.qrToken, deviceId: item.deviceId);
        }
        synced++;
      } on ApiException catch (error) {
        if (error.statusCode == null) {
          // Still offline: keep this and everything after it.
          offline = true;
          remaining.add(item);
        } else {
          // The server answered definitively (e.g. already redeemed while
          // we were offline) — the entry is settled either way.
          resolved++;
        }
      } catch (_) {
        offline = true;
        remaining.add(item);
      }
    }

    await queue.replaceAll(remaining);
    ref.invalidate(pendingScanCountProvider);

    final parts = <String>[
      if (synced > 0) '$synced synced',
      if (resolved > 0) '$resolved already processed',
      if (remaining.isNotEmpty) '${remaining.length} still pending',
    ];
    state = ScanSyncState(
      message: parts.isEmpty ? null : 'Offline scans: ${parts.join(', ')}.',
    );
  }
}

final scanSyncControllerProvider =
    NotifierProvider<ScanSyncController, ScanSyncState>(
      ScanSyncController.new,
    );
