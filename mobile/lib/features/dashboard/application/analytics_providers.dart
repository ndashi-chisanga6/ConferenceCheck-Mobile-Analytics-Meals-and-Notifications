import 'dart:async';

import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/features/dashboard/data/analytics_api.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Freshness target for the near-real-time dashboard: data shown to the
/// organiser is never more than this far behind the database.
const dashboardRefreshInterval = Duration(seconds: 30);

final analyticsApiProvider = Provider<AnalyticsApi>(
  (ref) => AnalyticsApi(ref.watch(apiClientProvider)),
);

final analyticsBundleProvider = FutureProvider<AnalyticsBundle>((ref) async {
  final timer = Timer(dashboardRefreshInterval, ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  final event = ref.watch(selectedEventProvider);
  if (event == null) throw StateError('Select an event first.');
  return ref.watch(analyticsApiProvider).bundle(event.id);
});
