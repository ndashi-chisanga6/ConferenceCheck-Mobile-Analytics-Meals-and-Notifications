import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_parsers.dart';

class DeviceTokenApi {
  const DeviceTokenApi(this._client);

  final ApiClient _client;

  Future<void> save(String token, String platform) async {
    await _client.post('/device-tokens', {
      'token': token,
      'platform': platform,
    }, messageFromEnvelope);
  }
}
