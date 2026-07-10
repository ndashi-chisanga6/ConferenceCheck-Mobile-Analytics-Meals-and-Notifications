import 'package:conference_check_mobile/core/offline/queued_scan.dart';
import 'package:conference_check_mobile/core/offline/scan_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('queued scan survives a JSON round trip', () {
    final original = QueuedScan(
      type: QueuedScan.session,
      eventId: 7,
      sessionId: 3,
      qrToken: 'ATT-abc123',
      deviceId: 'flutter-mobile',
      queuedAt: DateTime.parse('2026-07-10T12:30:00'),
    );

    final restored = QueuedScan.fromJson(original.toJson());

    expect(restored.type, QueuedScan.session);
    expect(restored.eventId, 7);
    expect(restored.sessionId, 3);
    expect(restored.qrToken, 'ATT-abc123');
    expect(restored.deviceId, 'flutter-mobile');
    expect(restored.queuedAt, DateTime.parse('2026-07-10T12:30:00'));
  });

  test('enqueue persists scans in FIFO order across queue instances', () async {
    final queue = ScanQueue();
    await queue.enqueue(
      QueuedScan(
        type: QueuedScan.meal,
        eventId: 1,
        qrToken: 'MEAL-first',
        queuedAt: DateTime.now(),
      ),
    );
    await queue.enqueue(
      QueuedScan(
        type: QueuedScan.meal,
        eventId: 1,
        qrToken: 'MEAL-second',
        queuedAt: DateTime.now(),
      ),
    );

    // A fresh instance reads the same persisted state.
    final pending = await ScanQueue().pending();

    expect(pending, hasLength(2));
    expect(pending.first.qrToken, 'MEAL-first');
    expect(pending.last.qrToken, 'MEAL-second');
    expect(await queue.count(), 2);
  });

  test('replaceAll keeps only the scans that are still pending', () async {
    final queue = ScanQueue();
    final first = QueuedScan(
      type: QueuedScan.meal,
      eventId: 1,
      qrToken: 'MEAL-synced',
      queuedAt: DateTime.now(),
    );
    final second = QueuedScan(
      type: QueuedScan.meal,
      eventId: 1,
      qrToken: 'MEAL-still-pending',
      queuedAt: DateTime.now(),
    );
    await queue.enqueue(first);
    await queue.enqueue(second);

    await queue.replaceAll([second]);

    final pending = await queue.pending();
    expect(pending, hasLength(1));
    expect(pending.single.qrToken, 'MEAL-still-pending');
  });

  test('empty queue reports zero pending scans', () async {
    expect(await ScanQueue().count(), 0);
    expect(await ScanQueue().pending(), isEmpty);
  });
}
