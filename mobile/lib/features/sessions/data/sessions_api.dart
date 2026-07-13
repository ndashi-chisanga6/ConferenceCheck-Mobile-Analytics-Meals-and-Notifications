import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_parsers.dart';
import 'package:conference_check_mobile/features/sessions/data/session_models.dart';

class SessionsApi {
  const SessionsApi(this._client);

  final ApiClient _client;

  Future<List<ConferenceSession>> sessions(int eventId) {
    return _client.get('/events/$eventId/sessions', (data) {
      return dataList(data)
          .map(
            (item) => ConferenceSession.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<List<SessionAttendance>> attendance(int eventId, int sessionId) {
    return _client.get('/events/$eventId/sessions/$sessionId/attendance', (
      data,
    ) {
      return dataList(data)
          .map(
            (item) => SessionAttendance.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<Map<String, dynamic>> scan(
    int eventId,
    int sessionId, {
    String? qrToken,
    int? attendeeId,
    String? deviceId,
  }) {
    final body = <String, dynamic>{};
    if (qrToken != null) {
      body['attendee_qr_token'] = qrToken;
    }
    if (attendeeId != null) {
      body['attendee_id'] = attendeeId;
    }
    if (deviceId != null) {
      body['device_id'] = deviceId;
    }
    return _client.post(
      '/events/$eventId/sessions/$sessionId/scan',
      body,
      dataMap,
    );
  }
}
