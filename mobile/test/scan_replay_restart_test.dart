import 'dart:convert';

import 'package:conference_check_mobile/core/offline/queued_scan.dart';
import 'package:conference_check_mobile/core/offline/scan_queue.dart';
import 'package:conference_check_mobile/features/meals/application/meals_providers.dart';
import 'package:conference_check_mobile/features/sessions/application/sessions_providers.dart';
import 'package:conference_check_mobile/features/sessions/data/sessions_api.dart';
import 'package:conference_check_mobile/features/sync/application/scan_sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scan_replay_test.dart' show FakeMealsApi, meal;

class FakeSessionsApi implements SessionsApi {
  final calls = <String>[];

  @override
  Future<Map<String, dynamic>> scan(
    int eventId,
    int sessionId, {
    String? qrToken,
    int? attendeeId,
    String? deviceId,
  }) async {
    calls.add('$sessionId:$qrToken');
    return {'attendance': qrToken};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

QueuedScan session(String token) => QueuedScan(
  type: QueuedScan.session,
  eventId: 1,
  sessionId: 4,
  qrToken: token,
  queuedAt: DateTime.parse('2026-10-09T10:05:00'),
);

/// Starts the app fresh on top of what an earlier run left in storage.
void restartWith(List<String> stored) {
  SharedPreferences.setMockInitialValues({ScanQueue.storageKey: stored});
}

Future<List<String>> stored() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(ScanQueue.storageKey) ?? const [];
}

ProviderContainer app({FakeMealsApi? meals, FakeSessionsApi? sessions}) {
  final container = ProviderContainer(
    overrides: [
      mealsApiProvider.overrideWithValue(meals ?? FakeMealsApi({})),
      sessionsApiProvider.overrideWithValue(sessions ?? FakeSessionsApi()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('scans queued before a restart are replayed after it', () async {
    restartWith([
      jsonEncode(meal('MEAL-1').toJson()),
      jsonEncode(session('ATT-1').toJson()),
    ]);
    final meals = FakeMealsApi({});
    final sessions = FakeSessionsApi();

    await app(
      meals: meals,
      sessions: sessions,
    ).read(scanSyncControllerProvider.notifier).flush();

    expect(meals.calls, ['MEAL-1']);
    expect(sessions.calls, ['4:ATT-1']);
    expect(await ScanQueue().pending(), isEmpty);
  });

  test(
    'a scan kept after an auth failure survives a restart and syncs later',
    () async {
      restartWith([]);
      await ScanQueue().enqueue(meal('MEAL-1'));
      await app(
        meals: FakeMealsApi({'MEAL-1': 401}),
      ).read(scanSyncControllerProvider.notifier).flush();
      final leftOver = await stored();
      expect(leftOver, hasLength(1));

      restartWith(leftOver);
      final meals = FakeMealsApi({});
      await app(meals: meals).read(scanSyncControllerProvider.notifier).flush();

      expect(meals.calls, ['MEAL-1']);
      expect(await ScanQueue().pending(), isEmpty);
    },
  );
}
