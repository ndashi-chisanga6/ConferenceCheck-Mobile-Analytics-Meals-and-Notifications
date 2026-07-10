import 'dart:convert';

import 'package:conference_check_mobile/core/offline/queued_scan.dart';
import 'package:conference_check_mobile/core/offline/scan_queue.dart';
import 'package:conference_check_mobile/features/sync/presentation/pending_scans_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app() => const ProviderScope(
  child: MaterialApp(home: Scaffold(body: PendingScansBar())),
);

void main() {
  testWidgets('renders nothing when the queue is empty', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNothing);
    expect(find.text('Sync now'), findsNothing);
  });

  testWidgets('shows the pending count and a sync action', (tester) async {
    final scans = [
      QueuedScan(
        type: QueuedScan.meal,
        eventId: 1,
        qrToken: 'MEAL-a',
        queuedAt: DateTime.now(),
      ),
      QueuedScan(
        type: QueuedScan.session,
        eventId: 1,
        sessionId: 2,
        qrToken: 'ATT-b',
        queuedAt: DateTime.now(),
      ),
    ];
    SharedPreferences.setMockInitialValues({
      ScanQueue.storageKey: scans
          .map((scan) => jsonEncode(scan.toJson()))
          .toList(),
    });

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('2 offline scans waiting to sync'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
  });
}
