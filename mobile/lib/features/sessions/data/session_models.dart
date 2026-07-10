import 'package:conference_check_mobile/core/utils/date_formatters.dart';
import 'package:conference_check_mobile/features/attendee/data/attendee_models.dart';

class ConferenceSession {
  const ConferenceSession({
    required this.id,
    required this.title,
    required this.venue,
    required this.capacity,
    required this.status,
    required this.attendanceCount,
    this.description,
    this.startsAt,
    this.endsAt,
  });

  final int id;
  final String title;
  final String venue;
  final int capacity;
  final String status;
  final int attendanceCount;
  final String? description;
  final DateTime? startsAt;
  final DateTime? endsAt;

  factory ConferenceSession.fromJson(Map<String, dynamic> json) {
    return ConferenceSession(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      capacity: (json['capacity'] as num? ?? 0).toInt(),
      status: json['status']?.toString() ?? '',
      attendanceCount: (json['attendance_count'] as num? ?? 0).toInt(),
      description: json['description']?.toString(),
      startsAt: parseDate(json['starts_at']),
      endsAt: parseDate(json['ends_at']),
    );
  }
}

class SessionAttendance {
  const SessionAttendance({
    required this.id,
    required this.checkedInAt,
    this.attendee,
  });

  final int id;
  final DateTime? checkedInAt;
  final Attendee? attendee;

  factory SessionAttendance.fromJson(Map<String, dynamic> json) {
    return SessionAttendance(
      id: (json['id'] as num).toInt(),
      checkedInAt: parseDate(json['checked_in_at']),
      attendee: json['attendee'] is Map<String, dynamic>
          ? Attendee.fromJson(json['attendee'] as Map<String, dynamic>)
          : null,
    );
  }
}
