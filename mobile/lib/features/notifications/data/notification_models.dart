import 'package:conference_check_mobile/core/utils/date_formatters.dart';

class EventNotification {
  const EventNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.targetType,
    required this.status,
    this.sentAt,
    this.recipientsCount,
  });

  final int id;
  final String title;
  final String message;
  final String targetType;
  final String status;
  final DateTime? sentAt;
  final int? recipientsCount;

  factory EventNotification.fromJson(Map<String, dynamic> json) {
    return EventNotification(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      targetType: json['target_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      sentAt: parseDate(json['sent_at']),
      recipientsCount: (json['recipients_count'] as num?)?.toInt(),
    );
  }
}
