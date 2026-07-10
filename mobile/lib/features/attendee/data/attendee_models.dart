class Attendee {
  const Attendee({
    required this.id,
    required this.fullName,
    required this.ticketCode,
    required this.qrToken,
    this.email,
    this.phone,
    this.userId,
  });

  final int id;
  final String fullName;
  final String ticketCode;
  final String qrToken;
  final String? email;
  final String? phone;
  final int? userId;

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name']?.toString() ?? '',
      ticketCode: json['ticket_code']?.toString() ?? '',
      qrToken: json['qr_token']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      userId: (json['user_id'] as num?)?.toInt(),
    );
  }
}
