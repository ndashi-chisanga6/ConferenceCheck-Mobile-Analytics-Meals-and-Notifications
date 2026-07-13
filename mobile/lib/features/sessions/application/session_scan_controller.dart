import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/core/device/device_identity.dart';
import 'package:conference_check_mobile/core/offline/queued_scan.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/sessions/application/sessions_providers.dart';
import 'package:conference_check_mobile/features/sync/application/scan_sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionScanState {
  const SessionScanState({
    this.loading = false,
    this.message,
    this.success,
    this.capacityStatus,
    this.queued = false,
  });
  final bool loading;
  final String? message;
  final bool? success;
  final String? capacityStatus;
  final bool queued;
}

class SessionScanController extends Notifier<SessionScanState> {
  @override
  SessionScanState build() => const SessionScanState();

  Future<void> scan(String token) async {
    final event = ref.read(selectedEventProvider);
    final session = ref.read(selectedSessionProvider);
    if (event == null || session == null || token.trim().isEmpty) return;
    state = const SessionScanState(loading: true);
    final deviceId = await ref.read(deviceIdentityProvider).id();
    try {
      final result = await ref
          .read(sessionsApiProvider)
          .scan(event.id, session.id, qrToken: token.trim(), deviceId: deviceId);
      ref.invalidate(sessionsProvider);
      ref.invalidate(sessionAttendanceProvider(session.id));
      state = SessionScanState(
        message:
            result['warning']?.toString() ?? 'Attendee checked into session.',
        success: true,
        capacityStatus: result['capacity_status']?.toString(),
      );
      // Connectivity is clearly back: drain any offline backlog.
      await ref.read(scanSyncControllerProvider.notifier).flush();
    } on ApiException catch (error) {
      if (error.statusCode == null) {
        await ref
            .read(scanQueueProvider)
            .enqueue(
              QueuedScan(
                type: QueuedScan.session,
                eventId: event.id,
                sessionId: session.id,
                qrToken: token.trim(),
                deviceId: deviceId,
                queuedAt: DateTime.now(),
              ),
            );
        ref.invalidate(pendingScanCountProvider);
        state = const SessionScanState(
          message: 'No connection — scan saved and will sync when back online.',
          success: false,
          queued: true,
        );
      } else {
        state = SessionScanState(message: error.message, success: false);
      }
    } catch (error) {
      state = SessionScanState(message: error.toString(), success: false);
    }
  }
}

final sessionScanControllerProvider =
    NotifierProvider<SessionScanController, SessionScanState>(
      SessionScanController.new,
    );
