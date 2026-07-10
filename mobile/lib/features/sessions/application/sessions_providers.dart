import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/sessions/data/session_models.dart';
import 'package:conference_check_mobile/features/sessions/data/sessions_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionsApiProvider = Provider<SessionsApi>(
  (ref) => SessionsApi(ref.watch(apiClientProvider)),
);

final sessionsProvider = FutureProvider<List<ConferenceSession>>((ref) async {
  final event = ref.watch(selectedEventProvider);
  if (event == null) return [];
  return ref.watch(sessionsApiProvider).sessions(event.id);
});

class SelectedSessionController extends Notifier<ConferenceSession?> {
  @override
  ConferenceSession? build() => null;

  void select(ConferenceSession? session) => state = session;
}

final selectedSessionProvider =
    NotifierProvider<SelectedSessionController, ConferenceSession?>(
      SelectedSessionController.new,
    );

final sessionAttendanceProvider =
    FutureProvider.family<List<SessionAttendance>, int>((ref, sessionId) async {
      final event = ref.watch(selectedEventProvider);
      if (event == null) return [];
      return ref.watch(sessionsApiProvider).attendance(event.id, sessionId);
    });
