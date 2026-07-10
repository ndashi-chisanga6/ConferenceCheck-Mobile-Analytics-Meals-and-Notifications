import 'package:conference_check_mobile/core/api/api_exception.dart';

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? value) parser,
  ) {
    final success = json['success'] == true;
    if (!success) {
      throw ApiException(
        json['message']?.toString() ?? 'Request failed.',
        errors: json['errors'],
      );
    }

    return ApiResponse<T>(
      success: success,
      message: json['message']?.toString() ?? '',
      data: parser(json['data']),
    );
  }
}
