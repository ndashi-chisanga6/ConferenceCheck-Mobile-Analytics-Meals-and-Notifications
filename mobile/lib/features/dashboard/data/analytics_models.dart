class AnalyticsSummary {
  const AnalyticsSummary({
    required this.totalAttendees,
    required this.checkedInAttendees,
    required this.checkInPercentage,
    required this.totalMealVouchers,
    required this.redeemedMealVouchers,
    required this.mealRedemptionPercentage,
    required this.totalSessions,
    required this.totalSessionAttendance,
    required this.overcrowdedSessionsCount,
    required this.notificationsSent,
  });

  final int totalAttendees;
  final int checkedInAttendees;
  final double checkInPercentage;
  final int totalMealVouchers;
  final int redeemedMealVouchers;
  final double mealRedemptionPercentage;
  final int totalSessions;
  final int totalSessionAttendance;
  final int overcrowdedSessionsCount;
  final int notificationsSent;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    int i(String key) => (json[key] as num? ?? 0).toInt();
    double d(String key) => (json[key] as num? ?? 0).toDouble();
    return AnalyticsSummary(
      totalAttendees: i('total_attendees'),
      checkedInAttendees: i('checked_in_attendees'),
      checkInPercentage: d('check_in_percentage'),
      totalMealVouchers: i('total_meal_vouchers'),
      redeemedMealVouchers: i('redeemed_meal_vouchers'),
      mealRedemptionPercentage: d('meal_redemption_percentage'),
      totalSessions: i('total_sessions'),
      totalSessionAttendance: i('total_session_attendance'),
      overcrowdedSessionsCount: i('overcrowded_sessions_count'),
      notificationsSent: i('notifications_sent'),
    );
  }
}

class CountPoint {
  const CountPoint(this.label, this.count);
  final String label;
  final int count;

  factory CountPoint.fromJson(Map<String, dynamic> json) {
    final value =
        json['count'] ??
        json['redeemed_count'] ??
        json['attendance_total'] ??
        0;
    return CountPoint(
      (json['period'] ?? json['name'] ?? json['title'] ?? '').toString(),
      (value as num).toInt(),
    );
  }
}

class SessionAnalytics {
  const SessionAnalytics({
    required this.sessionId,
    required this.title,
    required this.capacity,
    required this.attendanceTotal,
    required this.percentageFull,
    required this.capacityStatus,
  });

  final int sessionId;
  final String title;
  final int capacity;
  final int attendanceTotal;
  final double percentageFull;
  final String capacityStatus;

  factory SessionAnalytics.fromJson(Map<String, dynamic> json) {
    return SessionAnalytics(
      sessionId: (json['session_id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      capacity: (json['capacity'] as num? ?? 0).toInt(),
      attendanceTotal: (json['attendance_total'] as num? ?? 0).toInt(),
      percentageFull: (json['percentage_full'] as num? ?? 0).toDouble(),
      capacityStatus: json['capacity_status']?.toString() ?? '',
    );
  }
}
