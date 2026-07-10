import 'package:flutter_test/flutter_test.dart';

String normalizeManualToken(String value) => value.trim();

void main() {
  test('manual QR token parser trims presentation input', () {
    expect(normalizeManualToken('  MEAL-DEMO-11-1  '), 'MEAL-DEMO-11-1');
  });
}
