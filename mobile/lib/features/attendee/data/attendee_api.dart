import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_parsers.dart';
import 'package:conference_check_mobile/features/attendee/data/attendee_models.dart';

class AttendeeApi {
  const AttendeeApi(this._client);

  final ApiClient _client;

  Future<Attendee> fetchMyAttendee(int eventId) {
    return _client.get('/events/$eventId/attendees/me', (data) {
      return Attendee.fromJson(dataMap(data));
    });
  }
}
