import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/features/dashboard/data/analytics_api.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsApiProvider = Provider<AnalyticsApi>(
  (ref) => AnalyticsApi(ref.watch(apiClientProvider)),
);

final analyticsBundleProvider = FutureProvider<AnalyticsBundle>((ref) async {
  final event = ref.watch(selectedEventProvider);
  if (event == null) throw StateError('Select an event first.');
  return ref.watch(analyticsApiProvider).bundle(event.id);
});
