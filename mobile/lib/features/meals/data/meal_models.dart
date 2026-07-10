import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/features/attendee/data/attendee_models.dart';

class MealCategory {
  const MealCategory({
    required this.id,
    required this.name,
    required this.status,
    this.startsAt,
    this.endsAt,
  });

  final int id;
  final String name;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startsAt: parseDate(json['starts_at']),
      endsAt: parseDate(json['ends_at']),
    );
  }
}

class MealVoucher {
  const MealVoucher({
    required this.id,
    required this.qrToken,
    required this.status,
    this.attendee,
    this.category,
  });

  final int id;
  final String qrToken;
  final String status;
  final Attendee? attendee;
  final MealCategory? category;

  factory MealVoucher.fromJson(Map<String, dynamic> json) {
    return MealVoucher(
      id: (json['id'] as num).toInt(),
      qrToken: json['qr_token']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      attendee: json['attendee'] is Map<String, dynamic>
          ? Attendee.fromJson(json['attendee'] as Map<String, dynamic>)
          : null,
      category: json['category'] is Map<String, dynamic>
          ? MealCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MealRedemption {
  const MealRedemption({
    required this.id,
    required this.redeemedAt,
    this.deviceId,
  });

  final int id;
  final DateTime? redeemedAt;
  final String? deviceId;

  factory MealRedemption.fromJson(Map<String, dynamic> json) {
    return MealRedemption(
      id: (json['id'] as num).toInt(),
      redeemedAt: parseDate(json['redeemed_at']),
      deviceId: json['device_id']?.toString(),
    );
  }
}
