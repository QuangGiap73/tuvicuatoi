import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/daily_fortune.dart';

/// Ranh giới dữ liệu cho Vận hạn hôm nay.
///
/// Chưa có implementation HTTP cho đến khi endpoint và JSON response thực tế
/// được xác nhận; nhờ vậy presentation không phụ thuộc vào payload giả định.
abstract interface class DailyFortuneRepository {
  Future<DailyFortune> getForDate({
    required DateTime date,
    CancelToken? cancelToken,
  });
}

class ApiDailyFortuneRepository implements DailyFortuneRepository {
  const ApiDailyFortuneRepository(this._dio);
  final Dio _dio;

  @override
  Future<DailyFortune> getForDate({
    required DateTime date,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/charts/calculate/',
        data: {
          'name': 'Lịch ngày',
          'gender': 'Nam',
          'day': date.day,
          'month': date.month,
          'year': date.year,
          'hour': 12,
        },
        cancelToken: cancelToken,
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final info = data is Map ? data['info'] : null;
      if (body is! Map || body['success'] != true || info is! Map) {
        throw const DailyFortuneException('Dữ liệu lịch Can Chi không hợp lệ.');
      }
      String? text(Object? value) {
        final result = value?.toString().trim();
        return result == null || result.isEmpty ? null : result;
      }

      final canChiDay = text(info['can_chi_day'] ?? info['canChiDay']);
      final canChiMonth = text(info['can_chi_month'] ?? info['canChiMonth']);
      final canChiYear = text(info['can_chi_year'] ?? info['canChiYear']);
      return DailyFortune(
        date: date,
        summary: '',
        canChi: [
          canChiDay,
          canChiMonth,
          canChiYear,
        ].whereType<String>().join(' • '),
        canChiDay: canChiDay,
        canChiMonth: canChiMonth,
        canChiYear: canChiYear,
        lunarDate: text(info['lunar_date'] ?? info['lunarDate']),
        rawData: Map<String, dynamic>.from(info),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      final body = error.response?.data;
      final message = body is Map
          ? body['message'] ?? body['error'] ?? body['detail']
          : null;
      throw DailyFortuneException(message?.toString() ?? error.userMessage);
    }
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
