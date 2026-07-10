import 'package:conference_check_mobile/core/api/api_client.dart';
import 'package:conference_check_mobile/core/api/api_parsers.dart';
import 'package:conference_check_mobile/features/meals/data/meal_models.dart';

class MealsApi {
  const MealsApi(this._client);

  final ApiClient _client;

  Future<List<MealCategory>> categories(int eventId) {
    return _client.get('/events/$eventId/meal-categories', (data) {
      return dataList(data)
          .map((item) => MealCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<MealVoucher>> vouchers(int eventId) {
    return _client.get('/events/$eventId/meal-vouchers', (data) {
      return dataList(data)
          .map((item) => MealVoucher.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<MealRedemption>> redemptions(int eventId) {
    return _client.get('/events/$eventId/meal-redemptions', (data) {
      return dataList(data)
          .map((item) => MealRedemption.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Map<String, dynamic>> scan(
    int eventId,
    String qrToken, {
    String? deviceId,
  }) {
    final body = <String, dynamic>{'qr_token': qrToken};
    if (deviceId != null) {
      body['device_id'] = deviceId;
    }
    return _client.post('/events/$eventId/meal-vouchers/scan', body, dataMap);
  }

  Future<String> generate(int eventId, int mealCategoryId) {
    return _client.post('/events/$eventId/meal-vouchers/generate', {
      'meal_category_id': mealCategoryId,
    }, messageFromEnvelope);
  }
}
