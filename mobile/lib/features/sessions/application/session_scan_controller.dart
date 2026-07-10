import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/sessions/application/sessions_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionScanState {
  const SessionScanState({
    this.loading = false,
    this.message,
    this.success,
    this.capacityStatus,
  });
  final bool loading;
  final String? message;
  final bool? success;
  final String? capacityStatus;
}

class SessionScanController extends Notifier<SessionScanState> {
  @override
  SessionScanState build() => const SessionScanState();

  Future<void> scan(String token) async {
    final event = ref.read(selectedEventProvider);
    final session = ref.read(selectedSessionProvider);
    if (event == null || session == null || token.trim().isEmpty) return;
    state = const SessionScanState(loading: true);
    try {
      final result = await ref
          .read(sessionsApiProvider)
          .scan(event.id, session.id, qrToken: token.trim());
      ref.invalidate(sessionsProvider);
      ref.invalidate(sessionAttendanceProvider(session.id));
      state = SessionScanState(
        message:
            result['warning']?.toString() ?? 'Attendee checked into session.',
        success: true,
        capacityStatus: result['capacity_status']?.toString(),
      );
    } on ApiException catch (error) {
      state = SessionScanState(message: error.message, success: false);
    } catch (error) {
      state = SessionScanState(message: error.toString(), success: false);
    }
  }
}

final sessionScanControllerProvider =
    NotifierProvider<SessionScanController, SessionScanState>(
      SessionScanController.new,
    );
