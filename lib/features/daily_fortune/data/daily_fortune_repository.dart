import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/daily_fortune.dart';
import '../domain/daily_fortune_reading.dart';

/// Ranh giới dữ liệu cho lịch dùng chung và Nhật vận cá nhân.
/// Presentation chỉ phụ thuộc domain model, không phụ thuộc JSON của backend.
abstract interface class DailyFortuneRepository {
  Future<DailyFortune> getForDate({
    required DateTime date,
    CancelToken? cancelToken,
  });

  Future<DailyFortuneReading> getReading({
    required DateTime date,
    required Map<String, dynamic> chartData,
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
        canChiHour: text(info['can_chi_hour'] ?? info['canChiHour']),
        lunarDate: text(info['lunar_date'] ?? info['lunarDate']),
        napAm: text(info['menh_element'] ?? info['menhElement']),
        dayElement: text(info['day_element'] ?? info['dayElement']),
        solarTerm: text(
          info['solar_term'] ?? info['solarTerm'] ?? info['tiet_khi'],
        ),
        dayOfficer: text(info['day_officer'] ?? info['dayOfficer']),
        dayRating: text(info['day_rating'] ?? info['dayRating']),
        lunarMansion: text(info['lunar_mansion'] ?? info['lunarMansion']),
        rawData: Map<String, dynamic>.from(info),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      final body = error.response?.data;
      throw DailyFortuneException(_errorMessage(body, error.userMessage));
    }
  }

  @override
  Future<DailyFortuneReading> getReading({
    required DateTime date,
    required Map<String, dynamic> chartData,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/tuvi/read',
        data: {
          'type': 'full',
          'mode': 'doi-thuong',
          'year': date.year,
          'month': date.month,
          'day': date.day,
          'chart': chartData,
        },
        cancelToken: cancelToken,
      );
      final body = response.data;
      final raw = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || raw is! Map) {
        throw const DailyFortuneException('Dữ liệu Nhật vận không hợp lệ.');
      }
      final data = Map<String, dynamic>.from(raw);
      final daily = _nested(data, const [
        'dailyFortune',
        'daily_fortune',
        'nhatVan',
        'nhat_van',
        'daily',
      ]);
      final overview = data['overview'] is Map
          ? Map<String, dynamic>.from(data['overview'] as Map)
          : const <String, dynamic>{};
      String? text(Object? value) {
        final result = value?.toString().trim();
        return result == null || result.isEmpty ? null : result;
      }

      List<String> texts(Object? value) => value is List
          ? value
                .map(
                  (item) => item is Map
                      ? item['label'] ?? item['name'] ?? item['text']
                      : item,
                )
                .whereType<Object>()
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .toList(growable: false)
          : const [];
      double? number(Object? value) => value is num
          ? value.toDouble()
          : double.tryParse(value?.toString() ?? '');
      final directions = _nested(daily, const [
        'directions',
        'travelDirections',
        'travel_directions',
      ]);
      final officer = _nested(daily, const ['dayOfficer', 'day_officer']);
      final palace = _nested(daily, const ['dailyPalace', 'daily_palace']);

      return DailyFortuneReading(
        summary: text(
          daily['summary'] ??
              data['summary'] ??
              data['dailySummary'] ??
              overview['personality'],
        ),
        career: text(daily['career'] ?? data['career'] ?? overview['career']),
        wealth: text(daily['wealth'] ?? data['wealth'] ?? overview['wealth']),
        love: text(
          daily['love'] ??
              data['love'] ??
              data['relationships'] ??
              overview['relationships'],
        ),
        health: text(daily['health'] ?? data['health'] ?? overview['health']),
        advice: text(daily['advice'] ?? data['advice'] ?? data['dailyAdvice']),
        dayOfficer: text(
          officer['name'] ?? daily['dayOfficer'] ?? daily['day_officer'],
        ),
        dayRating: text(
          officer['rating'] ?? daily['dayRating'] ?? daily['day_rating'],
        ),
        dayOfficerDescription: text(
          officer['description'] ?? daily['dayOfficerDescription'],
        ),
        solarTerm: text(
          daily['solarTerm'] ?? daily['solar_term'] ?? daily['tietKhi'],
        ),
        lunarMansion: text(
          daily['lunarMansionName'] ??
              daily['lunar_mansion_name'] ??
              _nested(daily, const ['lunarMansion', 'lunar_mansion'])['name'],
        ),
        lunarMansionRating: text(
          daily['lunarMansionRating'] ??
              _nested(daily, const ['lunarMansion', 'lunar_mansion'])['rating'],
        ),
        lunarMansionDescription: text(
          daily['lunarMansionDescription'] ??
              _nested(daily, const [
                'lunarMansion',
                'lunar_mansion',
              ])['description'],
        ),
        joyDirection: text(
          directions['hyThan'] ?? directions['joyGod'] ?? daily['joyDirection'],
        ),
        wealthDirection: text(
          directions['taiThan'] ??
              directions['wealthGod'] ??
              daily['wealthDirection'],
        ),
        dailyPalace: text(
          palace['name'] ?? palace['palaceName'] ?? daily['dailyPalaceName'],
        ),
        fortuneScore: number(
          daily['fortuneScore'] ?? daily['fortune_score'] ?? daily['score'],
        ),
        auspiciousHours: texts(
          daily['auspiciousHours'] ?? daily['auspicious_hours'],
        ),
        inauspiciousHours: texts(
          daily['inauspiciousHours'] ?? daily['inauspicious_hours'],
        ),
        shouldDo: texts(daily['shouldDo'] ?? daily['should_do']),
        shouldAvoid: texts(daily['shouldAvoid'] ?? daily['should_avoid']),
        rawData: Map.unmodifiable(data),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      final body = error.response?.data;
      throw DailyFortuneException(_errorMessage(body, error.userMessage));
    }
  }

  static Map<String, dynamic> _nested(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return source;
  }

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
