import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/storage/selected_event_storage.dart';
import 'package:conference_check_mobile/features/auth/application/auth_controller.dart';
import 'package:conference_check_mobile/features/auth/data/auth_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiClientProvider)),
);

final selectedEventStorageProvider = Provider<SelectedEventStorage>(
  (ref) => SelectedEventStorage(),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
