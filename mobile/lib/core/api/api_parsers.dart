import 'package:conference_check_mobile/core/api/api_exception.dart';

Map<String, dynamic> envelope(Object? value) {
  if (value is Map<String, dynamic>) return value;
  throw const ApiException('Unexpected API response.');
}

Map<String, dynamic> dataMap(Object? value) {
  final json = envelope(value);
  if (json['success'] != true) {
    throw ApiException(
      json['message']?.toString() ?? 'Request failed.',
      errors: json['errors'],
    );
  }
  final data = json['data'];
  if (data is Map<String, dynamic>) return data;
  throw const ApiException('Expected an object response.');
}

List<dynamic> dataList(Object? value) {
  final json = envelope(value);
  if (json['success'] != true) {
    throw ApiException(
      json['message']?.toString() ?? 'Request failed.',
      errors: json['errors'],
    );
  }
  final data = json['data'];
  if (data is List) return data;
  throw const ApiException('Expected a list response.');
}

String messageFromEnvelope(Object? value) {
  final json = envelope(value);
  if (json['success'] != true) {
    throw ApiException(
      json['message']?.toString() ?? 'Request failed.',
      errors: json['errors'],
    );
  }
  return json['message']?.toString() ?? 'Success';
}
