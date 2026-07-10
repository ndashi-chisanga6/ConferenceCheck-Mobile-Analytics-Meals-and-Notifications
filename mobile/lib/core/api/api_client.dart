import 'package:conference_check_mobile/core/api/api_exception.dart';
import 'package:conference_check_mobile/core/config/env.dart';
import 'package:conference_check_mobile/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(tokenStorageProvider));
});

class ApiClient {
  ApiClient(this._tokenStorage)
    : dio = Dio(
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.clear();
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final Dio dio;

  Future<T> get<T>(String path, T Function(Object? data) parser) async {
    try {
      final response = await dio.get<Object?>(path);
      return parser(response.data);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> post<T>(
    String path,
    Object? body,
    T Function(Object? data) parser,
  ) async {
    try {
      final response = await dio.post<Object?>(path, data: body);
      return parser(response.data);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        data['message']?.toString() ?? 'Request failed.',
        statusCode: error.response?.statusCode,
        errors: data['errors'],
      );
    }

    return ApiException(
      error.message ?? 'Network request failed.',
      statusCode: error.response?.statusCode,
    );
  }
}
