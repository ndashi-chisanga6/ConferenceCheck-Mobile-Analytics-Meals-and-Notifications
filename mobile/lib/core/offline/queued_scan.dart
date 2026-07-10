/// A scan captured while the device had no connectivity, waiting to be
/// replayed against the API. Replaying is safe because the backend is
/// idempotent: a scan that already reached the server answers with a
/// definitive duplicate/already-redeemed response instead of a second effect.
class QueuedScan {
  const QueuedScan({
    required this.type,
    required this.eventId,
    required this.qrToken,
    required this.queuedAt,
    this.sessionId,
    this.deviceId,
  });

  static const meal = 'meal';
  static const session = 'session';

  final String type;
  final int eventId;
  final String qrToken;
  final DateTime queuedAt;
  final int? sessionId;
  final String? deviceId;

  Map<String, dynamic> toJson() => {
    'type': type,
    'event_id': eventId,
    'qr_token': qrToken,
    'queued_at': queuedAt.toIso8601String(),
    'session_id': sessionId,
    'device_id': deviceId,
  };

  factory QueuedScan.fromJson(Map<String, dynamic> json) {
    return QueuedScan(
      type: json['type']?.toString() ?? meal,
      eventId: (json['event_id'] as num).toInt(),
      qrToken: json['qr_token']?.toString() ?? '',
      queuedAt:
          DateTime.tryParse(json['queued_at']?.toString() ?? '') ??
          DateTime.now(),
      sessionId: (json['session_id'] as num?)?.toInt(),
      deviceId: json['device_id']?.toString(),
    );
  }
}
