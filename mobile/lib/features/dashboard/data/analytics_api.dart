import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_parsers.dart';
import 'package:conference_check_mobile/features/dashboard/data/analytics_models.dart';

class AnalyticsBundle {
  const AnalyticsBundle({
    required this.summary,
    required this.checkIns,
    required this.meals,
    required this.sessions,
  });

  final AnalyticsSummary summary;
  final List<CountPoint> checkIns;
  final List<CountPoint> meals;
  final List<SessionAnalytics> sessions;
}

class AnalyticsApi {
  const AnalyticsApi(this._client);

  final ApiClient _client;

  Future<AnalyticsSummary> summary(int eventId) {
    return _client.get('/events/$eventId/analytics/summary', (data) {
      return AnalyticsSummary.fromJson(dataMap(data));
    });
  }

  Future<List<CountPoint>> checkIns(int eventId) {
    return _client.get('/events/$eventId/analytics/check-ins', (data) {
      return dataList(data)
          .map((item) => CountPoint.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<CountPoint>> meals(int eventId) {
    return _client.get('/events/$eventId/analytics/meals', (data) {
      return dataList(data)
          .map((item) => CountPoint.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<SessionAnalytics>> sessions(int eventId) {
    return _client.get('/events/$eventId/analytics/sessions', (data) {
      return dataList(data)
          .map(
            (item) => SessionAnalytics.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<AnalyticsBundle> bundle(int eventId) async {
    final results = await Future.wait([
      summary(eventId),
      checkIns(eventId),
      meals(eventId),
      sessions(eventId),
    ]);

    return AnalyticsBundle(
      summary: results[0] as AnalyticsSummary,
      checkIns: results[1] as List<CountPoint>,
      meals: results[2] as List<CountPoint>,
      sessions: results[3] as List<SessionAnalytics>,
    );
  }
}
