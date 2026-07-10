import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/core/utils/percentage.dart';
import 'package:conference_check_mobile/features/attendee/data/attendee_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('percentage helpers', () {
    test('whole percentages drop the decimal', () {
      expect(percentageLabel(50), '50%');
      expect(percentageLabel(66.7), '66.7%');
    });

    test('percentageOf guards against a zero total', () {
      expect(percentageOf(5, 0), 0);
      expect(percentageOf(1, 4), 25);
    });
  });

  group('date helpers', () {
    test('null dates render placeholders instead of crashing', () {
      expect(formatDateTime(null), 'Not set');
      expect(formatTimeRange(null, DateTime.now()), 'Time not set');
    });

    test('parseDate tolerates junk input', () {
      expect(parseDate(null), isNull);
      expect(parseDate('not-a-date'), isNull);
      expect(parseDate('2026-07-10T08:00:00'), isA<DateTime>());
    });
  });

  group('attendee model', () {
    test('parses a full payload', () {
      final attendee = Attendee.fromJson(const {
        'id': 11,
        'full_name': 'Demo Attendee',
        'ticket_code': 'TICKET-XYZ',
        'qr_token': 'ATT-token',
        'email': 'demo@example.com',
        'user_id': 4,
      });

      expect(attendee.id, 11);
      expect(attendee.fullName, 'Demo Attendee');
      expect(attendee.qrToken, 'ATT-token');
      expect(attendee.userId, 4);
    });

    test('missing optional fields default safely', () {
      final attendee = Attendee.fromJson(const {'id': 1});

      expect(attendee.fullName, '');
      expect(attendee.email, isNull);
      expect(attendee.userId, isNull);
    });
  });
}
