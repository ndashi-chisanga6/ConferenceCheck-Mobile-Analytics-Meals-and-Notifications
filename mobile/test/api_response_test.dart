import 'package:conference_check_mobile/core/api/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiResponse parses backend envelope', () {
    final response = ApiResponse<String>.fromJson({
      'success': true,
      'message': 'OK',
      'data': 'ready',
    }, (value) => value.toString());

    expect(response.success, true);
    expect(response.message, 'OK');
    expect(response.data, 'ready');
  });
}
