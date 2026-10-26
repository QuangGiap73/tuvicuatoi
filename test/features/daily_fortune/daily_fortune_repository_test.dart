import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/daily_fortune/data/daily_fortune_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ApiDailyFortuneRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    repository = ApiDailyFortuneRepository(dio);
  });

  test(
    'loads the documented calendar fields without client calculations',
    () async {
      adapter.onPost(
        '/charts/calculate/',
        (server) => server.reply(200, {
          'success': true,
          'data': {
            'info': {
              'lunar_date': '14/9 (Âm lịch)',
              'can_chi_year': 'Bính Ngọ',
              'can_chi_month': 'Mậu Tuất',
              'can_chi_day': 'Canh Ngọ',
              'can_chi_hour': 'Bính Tý',
              'menh_element': 'Lộ Bàng Thổ',
            },
          },
        }),
        data: {
          'name': 'Lịch ngày',
          'gender': 'Nam',
          'day': 23,
          'month': 10,
          'year': 2026,
          'hour': 12,
        },
      );

      final result = await repository.getForDate(date: DateTime(2026, 10, 23));

      expect(result.canChiHour, 'Bính Tý');
      expect(result.dayOfficer, isNull);
      expect(result.joyDirection, isNull);
    },
  );

  test('requests a personalized day reading with the selected chart', () async {
    adapter.onPost(
      '/tuvi/read',
      (server) => server.reply(200, {
        'success': true,
        'data': {
          'dailyFortune': {
            'dayOfficer': {'name': 'Thành', 'rating': 'Hoàng Đạo'},
            'travelDirections': {'hyThan': 'Tây Bắc', 'taiThan': 'Tây Nam'},
            'dailyPalace': {'name': 'Huynh Đệ'},
            'fortuneScore': 4.6,
            'auspiciousHours': ['Tý 23:00–00:59'],
            'inauspiciousHours': ['Dần 03:00–04:59'],
            'shouldDo': ['Khai trương'],
            'shouldAvoid': ['Kiện tụng'],
          },
          'overview': {
            'personality': 'Ngày thuận lợi.',
            'career': 'Công việc hanh thông.',
            'wealth': 'Tài lộc ổn định.',
            'relationships': 'Tình cảm hài hòa.',
            'health': 'Sức khỏe tốt.',
          },
          'advice': 'Giữ nhịp độ ổn định.',
        },
      }),
      data: {
        'type': 'full',
        'mode': 'doi-thuong',
        'year': 2026,
        'month': 10,
        'day': 23,
        'chart': {'id': 'chart-1'},
      },
    );

    final result = await repository.getReading(
      date: DateTime(2026, 10, 23),
      chartData: const {'id': 'chart-1'},
    );

    expect(result.summary, 'Ngày thuận lợi.');
    expect(result.career, 'Công việc hanh thông.');
    expect(result.advice, 'Giữ nhịp độ ổn định.');
    expect(result.dayOfficer, 'Thành');
    expect(result.joyDirection, 'Tây Bắc');
    expect(result.dailyPalace, 'Huynh Đệ');
    expect(result.fortuneScore, 4.6);
    expect(result.shouldDo, ['Khai trương']);
  });
}
