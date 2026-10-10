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

/// Whether a failed replay got a final business answer from the server, so
/// the queued scan can be dropped: invalid token (404), already redeemed or
/// duplicate (409), or not redeemable right now (422). Anything else, like
/// no connection, an expired login (401/403), rate limiting or a server
/// fault, could succeed later, so the scan is kept.
bool replayIsSettled(int? statusCode) =>
    statusCode == 404 || statusCode == 409 || statusCode == 422;

/// Replays queued offline scans against the API in order. A definitive
/// server answer removes the entry; a recoverable failure keeps it and
/// everything after it, and stops the run.
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
    var stopped = false;

    for (final item in items) {
      if (stopped) {
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
        if (replayIsSettled(error.statusCode)) {
          resolved++;
        } else {
          stopped = true;
          remaining.add(item);
        }
      } catch (_) {
        stopped = true;
        remaining.add(item);
      }
    }

    await queue.settle(items.length, remaining);
    ref.invalidate(pendingScanCountProvider);

    final parts = <String>[
      if (synced > 0) '$synced synced',
      if (resolved > 0) '$resolved refused by the server',
      if (remaining.isNotEmpty) '${remaining.length} still pending',
    ];
    state = ScanSyncState(
      message: parts.isEmpty ? null : 'Offline scans: ${parts.join(', ')}.',
    );
  }
}

final scanSyncControllerProvider =
    NotifierProvider<ScanSyncController, ScanSyncState>(ScanSyncController.new);
