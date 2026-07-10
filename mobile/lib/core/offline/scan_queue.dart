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

  Future<void> replaceAll(List<QueuedScan> scans) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storageKey,
      scans.map((scan) => jsonEncode(scan.toJson())).toList(),
    );
  }
}
