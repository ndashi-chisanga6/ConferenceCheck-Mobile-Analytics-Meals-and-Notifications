import 'package:conference_check_mobile/features/attendee/application/attendee_providers.dart';
import 'package:conference_check_mobile/features/attendee/data/attendee_models.dart';
import 'package:conference_check_mobile/features/attendee/presentation/my_meals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Shape of GET /events/{event}/attendees/me for the seeded attendee: the
// attendee with mealVouchers.category loaded.
final _payload = <String, dynamic>{
  'id': 1,
  'full_name': 'Demo Attendee',
  'ticket_code': 'TICKET-001',
  'qr_token': 'ATTENDEE-DEMO-001',
  'meal_vouchers': [
    {
      'id': 1,
      'qr_token': 'MEAL-DEMO-1-1',
      'status': 'redeemed',
      'redeemed_at': '2026-10-14T07:30:00Z',
      'category': {'id': 1, 'name': 'Breakfast', 'status': 'active'},
    },
    {
      'id': 3,
      'qr_token': 'MEAL-DEMO-1-3',
      'status': 'unused',
      'redeemed_at': null,
      'category': {'id': 3, 'name': 'Supper', 'status': 'active'},
    },
  ],
};

void main() {
  test('Attendee.fromJson keeps the meal vouchers and their categories', () {
    final attendee = Attendee.fromJson(_payload);

    expect(attendee.mealVouchers, hasLength(2));
    expect(attendee.mealVouchers.first.category?.name, 'Breakfast');
    expect(attendee.mealVouchers.first.isRedeemed, isTrue);
    expect(attendee.mealVouchers.first.redeemedAt, isNotNull);
    expect(attendee.mealVouchers.last.qrToken, 'MEAL-DEMO-1-3');
    expect(attendee.mealVouchers.last.isRedeemed, isFalse);
  });

  test('Attendee.fromJson without meal_vouchers gives an empty list', () {
    final attendee = Attendee.fromJson({'id': 2, 'full_name': 'No meals'});

    expect(attendee.mealVouchers, isEmpty);
  });

  testWidgets('My meals shows a QR only for the unused voucher', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myAttendeeProvider.overrideWith(
            (ref) async => Attendee.fromJson(_payload),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: MyMealsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Supper'), findsOneWidget);
    expect(find.text('Redeemed'), findsOneWidget);
    expect(find.text('Unused'), findsOneWidget);

    final qrs = tester.widgetList<QrImageView>(find.byType(QrImageView));
    expect(qrs, hasLength(1));
    expect(find.text('MEAL-DEMO-1-3'), findsOneWidget);
  });
}
