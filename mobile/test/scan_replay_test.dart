import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/core/offline/queued_scan.dart';
import 'package:conference_check_mobile/core/offline/scan_queue.dart';
import 'package:conference_check_mobile/features/meals/application/meals_providers.dart';
import 'package:conference_check_mobile/features/meals/data/meals_api.dart';
import 'package:conference_check_mobile/features/sync/application/scan_sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers each meal scan with the status queued for its token, or 200.
class FakeMealsApi implements MealsApi {
  FakeMealsApi(this.answers);

  final Map<String, int> answers;
  final calls = <String>[];

  @override
  Future<Map<String, dynamic>> scan(
    int eventId,
    String qrToken, {
    String? deviceId,
  }) async {
    calls.add(qrToken);
    final status = answers[qrToken] ?? 200;
    if (status != 200) {
      throw ApiException('HTTP $status', statusCode: status);
    }
    return {'voucher': qrToken};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

QueuedScan meal(String token) => QueuedScan(
  type: QueuedScan.meal,
  eventId: 1,
  qrToken: token,
  queuedAt: DateTime.parse('2026-10-09T10:00:00'),
);

Future<List<String>> replay(Map<String, int> answers, List<String> tokens) async {
  final queue = ScanQueue();
  for (final token in tokens) {
    await queue.enqueue(meal(token));
  }
  final container = ProviderContainer(
    overrides: [mealsApiProvider.overrideWithValue(FakeMealsApi(answers))],
  );
  addTearDown(container.dispose);

  await container.read(scanSyncControllerProvider.notifier).flush();

  return (await queue.pending()).map((scan) => scan.qrToken).toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('only business answers settle a replay', () {
    expect(replayIsSettled(404), isTrue);
    expect(replayIsSettled(409), isTrue);
    expect(replayIsSettled(422), isTrue);
    for (final status in [null, 401, 403, 408, 429, 500, 502, 503]) {
      expect(replayIsSettled(status), isFalse, reason: 'status $status');
    }
  });

  test('an expired login keeps the scan and everything after it', () async {
    final left = await replay({'B': 401}, ['A', 'B', 'C']);

    expect(left, ['B', 'C']);
  });

  test('a server fault keeps the scan for the next sync', () async {
    final left = await replay({'A': 500}, ['A', 'B']);

    expect(left, ['A', 'B']);
  });

  test('already redeemed and invalid tokens are dropped', () async {
    final left = await replay({'A': 409, 'B': 404, 'C': 422}, ['A', 'B', 'C']);

    expect(left, isEmpty);
  });
}
