import 'dart:convert';

import 'package:conference_check_mobile/core/offline/queued_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Durable FIFO store for scans captured offline, persisted so a queued
/// scan survives app restarts until it has been replayed successfully.
class ScanQueue {
  static const storageKey = 'conference_check_pending_scans_v1';

  Future<List<QueuedScan>> pending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? const [];
    return raw
        .map(
          (entry) =>
              QueuedScan.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<int> count() async => (await pending()).length;

  Future<void> enqueue(QueuedScan scan) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? const [];
    await prefs.setStringList(storageKey, [...raw, jsonEncode(scan.toJson())]);
  }

  /// Ends a replay run that started from the first [handled] scans: those are
  /// replaced by [keep], and anything enqueued while the run was going is
  /// left after them. The read and the write happen with no await in
  /// between, so an enqueue can't land in the middle.
  Future<void> settle(int handled, List<QueuedScan> keep) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? const [];
    await prefs.setStringList(storageKey, [
      ...keep.map((scan) => jsonEncode(scan.toJson())),
      ...raw.skip(handled),
    ]);
  }
}
