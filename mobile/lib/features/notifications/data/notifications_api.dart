import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_parsers.dart';
import 'package:conference_check_mobile/features/notifications/data/notification_models.dart';

class NotificationsApi {
  const NotificationsApi(this._client);

  final ApiClient _client;

  Future<List<EventNotification>> notifications(int eventId) {
    return _client.get('/events/$eventId/notifications', (data) {
      return dataList(data)
          .map(
            (item) => EventNotification.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<EventNotification> notification(int eventId, int notificationId) {
    return _client.get('/events/$eventId/notifications/$notificationId', (
      data,
    ) {
      return EventNotification.fromJson(dataMap(data));
    });
  }

  Future<Map<String, dynamic>> send({
    required int eventId,
    required String title,
    required String message,
    required String targetType,
    int? targetSessionId,
  }) {
    final body = <String, dynamic>{
      'title': title,
      'message': message,
      'target_type': targetType,
    };
    if (targetSessionId != null) {
      body['target_session_id'] = targetSessionId;
    }
    return _client.post('/events/$eventId/notifications/send', body, dataMap);
  }
}
