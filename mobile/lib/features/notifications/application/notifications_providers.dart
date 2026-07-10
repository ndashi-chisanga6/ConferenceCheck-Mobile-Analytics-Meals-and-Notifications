import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/notifications/data/device_token_api.dart';
import 'package:conference_check_mobile/features/notifications/data/notification_models.dart';
import 'package:conference_check_mobile/features/notifications/data/notifications_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(ref.watch(apiClientProvider)),
);
final deviceTokenApiProvider = Provider<DeviceTokenApi>(
  (ref) => DeviceTokenApi(ref.watch(apiClientProvider)),
);

final notificationsProvider = FutureProvider<List<EventNotification>>((
  ref,
) async {
  final event = ref.watch(selectedEventProvider);
  if (event == null) return [];
  return ref.watch(notificationsApiProvider).notifications(event.id);
});
