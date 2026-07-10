import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/notifications/application/notifications_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendNotificationState {
  const SendNotificationState({
    this.loading = false,
    this.message,
    this.success,
  });
  final bool loading;
  final String? message;
  final bool? success;
}

class SendNotificationController extends Notifier<SendNotificationState> {
  @override
  SendNotificationState build() => const SendNotificationState();

  Future<void> send({
    required String title,
    required String message,
    required String targetType,
    int? targetSessionId,
  }) async {
    final event = ref.read(selectedEventProvider);
    if (event == null) return;
    state = const SendNotificationState(loading: true);
    try {
      await ref
          .read(notificationsApiProvider)
          .send(
            eventId: event.id,
            title: title,
            message: message,
            targetType: targetType,
            targetSessionId: targetSessionId,
          );
      ref.invalidate(notificationsProvider);
      state = const SendNotificationState(
        message: 'Notification sent.',
        success: true,
      );
    } on ApiException catch (error) {
      state = SendNotificationState(message: error.message, success: false);
    } catch (error) {
      state = SendNotificationState(message: error.toString(), success: false);
    }
  }
}

final sendNotificationControllerProvider =
    NotifierProvider<SendNotificationController, SendNotificationState>(
      SendNotificationController.new,
    );
