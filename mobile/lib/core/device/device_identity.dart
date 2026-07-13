import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stable per-install identifier reported with every scan, so redemption
/// and attendance audit records can tell scanning devices apart.
class DeviceIdentity {
  static const _key = 'conference_check_device_id';
  String? _cached;

  Future<String> id() async {
    final cached = _cached;
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null) {
      final rand = Random.secure();
      final hex = List.generate(
        8,
        (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      id = 'device-$hex';
      await prefs.setString(_key, id);
    }
    return _cached = id;
  }
}

final deviceIdentityProvider = Provider<DeviceIdentity>(
  (ref) => DeviceIdentity(),
);
