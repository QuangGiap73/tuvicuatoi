import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/daily_fortune.dart';
import 'daily_fortune_mapper.dart';

abstract interface class DailyFortuneRepository {
  Future<DailyFortune> getCalendar({
    required DateTime date,
    CancelToken? cancelToken,
  });
  Future<DailyFortune> getPersonalized({
    required DateTime date,
    required Map<String, dynamic> chartData,
    CancelToken? cancelToken,
  });
}

class ApiDailyFortuneRepository implements DailyFortuneRepository {
  const ApiDailyFortuneRepository(this._dio);
  final Dio _dio;

  @override
  Future<DailyFortune> getCalendar({
    required DateTime date,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get<Object?>(
      '/tuvi/daily-fortune',
      queryParameters: {'date': _date(date)},
      cancelToken: cancelToken,
    ),
    date,
  );

  @override
  Future<DailyFortune> getPersonalized({
    required DateTime date,
    required Map<String, dynamic> chartData,
    CancelToken? cancelToken,
  }) async {
    final result = await _request(
      () => _dio.post<Object?>(
        '/tuvi/daily-fortune',
        data: {'date': _date(date), 'chartData': chartData},
        cancelToken: cancelToken,
      ),
      date,
    );
    if (!result.isPersonalized) {
      throw const DailyFortuneException(
        'Máy chủ chưa tạo được vận hạn cá nhân từ lá số đã chọn.',
      );
    }
    return result;
  }

  Future<DailyFortune> _request(
    Future<Response<Object?>> Function() send,
    DateTime date,
  ) async {
    try {
      final response = await send();
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        throw const DailyFortuneException(
          'Máy chủ chưa trả về dữ liệu vận hạn hợp lệ.',
        );
      }
      try {
        return DailyFortuneMapper.fromResponse(body, date);
      } on FormatException {
        throw const DailyFortuneException('Dữ liệu vận hạn chưa đầy đủ.');
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw DailyFortuneException(
        _errorMessage(error.response?.data, error.userMessage),
      );
    }
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static String _errorMessage(Object? body, String fallback) {
    if (body is! Map) return fallback;
    final error = body['error'];
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }
    return (body['message'] ?? error ?? body['detail'] ?? fallback).toString();
  }
}

class DailyFortuneException implements Exception {
  const DailyFortuneException(this.message);
  final String message;
  @override
  String toString() => message;
}

final dailyFortuneRepositoryProvider = Provider<DailyFortuneRepository>(
  (ref) => ApiDailyFortuneRepository(ref.watch(dioProvider)),
);
