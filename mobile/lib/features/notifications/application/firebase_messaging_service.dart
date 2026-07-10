import 'package:conference_check_mobile/features/notifications/application/notifications_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((
  ref,
) {
  return FirebaseMessagingService(ref);
});

class FirebaseMessagingService {
  const FirebaseMessagingService(this._ref);

  final Ref _ref;

  Future<void> registerDeviceToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null) {
        await _ref
            .read(deviceTokenApiProvider)
            .save(token, defaultTargetPlatform.name);
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Firebase messaging skipped: $error');
      }
    }
  }
}
