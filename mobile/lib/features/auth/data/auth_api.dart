import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_parsers.dart';
import 'package:conference_check_mobile/features/auth/data/auth_models.dart';

class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<AuthSession> login(String email, String password) {
    return _client.post('/auth/login', {'email': email, 'password': password}, (
      data,
    ) {
      return AuthSession.fromJson(dataMap(data));
    });
  }

  Future<AppUser> me() {
    return _client.get('/auth/me', (data) => AppUser.fromJson(dataMap(data)));
  }

  Future<void> logout() async {
    await _client.post('/auth/logout', null, messageFromEnvelope);
  }
}
