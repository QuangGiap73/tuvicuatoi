import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';

const _timeout = Duration(seconds: 15);
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(tokenStorageProvider).read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

extension DioErrorMessage on DioException {
  String get userMessage => switch (type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => 'Kết nối quá thời gian. Vui lòng thử lại.',
    DioExceptionType.cancel => 'Yêu cầu đã được hủy.',
    DioExceptionType.connectionError => 'Không thể kết nối máy chủ.',
    _ => 'Đã xảy ra lỗi. Vui lòng thử lại.',
  };
}
