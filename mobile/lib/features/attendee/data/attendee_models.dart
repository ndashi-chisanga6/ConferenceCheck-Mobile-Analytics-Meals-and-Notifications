import 'package:conference_check_mobile/features/meals/data/meal_models.dart';

class Attendee {
  const Attendee({
    required this.id,
    required this.fullName,
    required this.ticketCode,
    required this.qrToken,
    this.email,
    this.phone,
    this.userId,
    this.mealVouchers = const [],
  });

  final int id;
  final String fullName;
  final String ticketCode;
  final String qrToken;
  final String? email;
  final String? phone;
  final int? userId;

  /// The attendee's own meal vouchers, one per meal category. Only present
  /// when the API loads them (GET /events/{event}/attendees/me does).
  final List<MealVoucher> mealVouchers;

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name']?.toString() ?? '',
      ticketCode: json['ticket_code']?.toString() ?? '',
      qrToken: json['qr_token']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      userId: (json['user_id'] as num?)?.toInt(),
      mealVouchers: [
        for (final item in json['meal_vouchers'] as List? ?? const [])
          if (item is Map<String, dynamic>) MealVoucher.fromJson(item),
      ],
    );
  }
}
