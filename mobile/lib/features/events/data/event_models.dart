import 'package:conference_check_mobile/core/utils/date_formatters.dart';

class Event {
  const Event({
    required this.id,
    required this.name,
    required this.venue,
    required this.status,
    this.theme,
    this.description,
    this.startsAt,
    this.endsAt,
  });

  final int id;
  final String name;
  final String venue;
  final String status;
  final String? theme;
  final String? description;
  final DateTime? startsAt;
  final DateTime? endsAt;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      theme: json['theme']?.toString(),
      description: json['description']?.toString(),
      startsAt: parseDate(json['starts_at']),
      endsAt: parseDate(json['ends_at']),
    );
  }
}
