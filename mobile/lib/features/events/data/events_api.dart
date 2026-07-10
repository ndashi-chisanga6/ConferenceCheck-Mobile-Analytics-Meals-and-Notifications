import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_parsers.dart';
import 'package:conference_check_mobile/features/events/data/event_models.dart';

class EventsApi {
  const EventsApi(this._client);

  final ApiClient _client;

  Future<List<Event>> fetchEvents() {
    return _client.get('/events', (data) {
      return dataList(
        data,
      ).map((item) => Event.fromJson(item as Map<String, dynamic>)).toList();
    });
  }
}
