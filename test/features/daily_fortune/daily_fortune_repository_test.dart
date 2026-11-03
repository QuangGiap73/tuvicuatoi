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

  test('GET loads the documented public daily calendar', () async {
    adapter.onGet(
      '/tuvi/daily-fortune',
      (server) => server.reply(200, _response()),
      queryParameters: {'date': '2026-10-29'},
    );
    final result = await repository.getCalendar(date: DateTime(2026, 10, 29));
    expect(result.canChiDay, 'Bính Tý');
    expect(result.dayOfficer, 'Mãn');
    expect(result.hours, hasLength(2));
    expect(result.personal, isNull);
  });

  test('POST parses personal fortune and prefers the data envelope', () async {
    final envelope = Map<String, dynamic>.from(_response()['data'] as Map);
    envelope['personalFortune'] = {
      'chartName': 'Nguyễn Văn A',
      'birthYearCanChi': 'Ất Hợi',
      'birthBranch': 'Hợi',
      'destinyNayin': 'Sơn Đầu Hỏa',
      'destinyElement': 'Hỏa',
      'palaceName': 'Phụ Mẫu',
      'palaceBranch': 'Ngọ',
      'majorStars': ['Tử Vi'],
      'dailyStars': ['Lưu Văn Khúc'],
      'branchRelationType': 'Bình Hòa',
      'branchRelationDesc': 'Vận trình ổn định.',
      'elementRelationType': 'Khắc Nhập',
      'elementRelationDesc': 'Nên thận trọng.',
      'mutagenStars': {
        'loc': {'star': 'Thiên Đồng', 'palace': 'Tài Bạch'},
      },
      'overallScore': 62,
      'overallRating': 'Bình Hòa An Ổn',
      'careerAdvice': 'Công việc thuận lợi.',
      'wealthAdvice': 'Tài chính ổn định.',
      'loveAdvice': 'Gia đình hòa thuận.',
      'healthAdvice': 'Nên nghỉ ngơi.',
      'luckyColor': 'Xanh lá',
      'luckyColorReason': 'Bồi đắp sinh khí.',
      'luckyDirection': 'Tây Nam',
      'personalizedHours': [
        {
          'branch': 'Dần',
          'time': '03:00 - 04:59',
          'isAuspicious': false,
          'starName': 'Hắc Đạo',
          'affinityType': 'Lục Hợp',
          'affinityBadge': 'Quý nhân tuổi Hợi',
        },
      ],
    };
    envelope['aiSuggestedPrompt'] = 'Phân tích ngày hôm nay.';
    adapter.onPost(
      '/tuvi/daily-fortune',
      (server) => server.reply(200, {'success': true, 'data': envelope}),
      data: {
        'date': '2026-10-29',
        'chartData': {'id': 'chart-1'},
      },
    );

    final result = await repository.getPersonalized(
      date: DateTime(2026, 10, 29),
      chartData: const {'id': 'chart-1'},
    );
    expect(result.personal?.overallScore, 62);
    expect(result.career, 'Công việc thuận lợi.');
    expect(result.wealth, 'Tài chính ổn định.');
    expect(result.love, 'Gia đình hòa thuận.');
    expect(result.health, 'Nên nghỉ ngơi.');
    expect(result.personal?.luckyColor, 'Xanh lá');
    expect(result.personal?.luckyDirection, 'Tây Nam');
    expect(result.personal?.mutagenStars['loc']?.star, 'Thiên Đồng');
    expect(result.hours.single.affinityType, 'Lục Hợp');
    expect(result.aiSuggestedPrompt, 'Phân tích ngày hôm nay.');
  });

  test('POST rejects a calendar-only response for a selected chart', () async {
    adapter.onPost(
      '/tuvi/daily-fortune',
      (server) => server.reply(200, _response()),
      data: {
        'date': '2026-10-29',
        'chartData': {'id': 'chart-1'},
      },
    );

    expect(
      () => repository.getPersonalized(
        date: DateTime(2026, 10, 29),
        chartData: const {'id': 'chart-1'},
      ),
      throwsA(isA<DailyFortuneException>()),
    );
  });
}

Map<String, dynamic> _response() => {
  'success': true,
  'data': {
    'date': '2026-10-29',
    'dailyCalendar': {
      'solarDateStr': '2026-10-29',
      'dayOfWeek': 'Thứ Năm',
      'lunarDay': 20,
      'lunarMonth': 9,
      'lunarYear': 2026,
      'isLeapMonth': false,
      'canChiDay': 'Bính Tý',
      'canChiMonth': 'Mậu Tuất',
      'canChiYear': 'Bính Ngọ',
      'canChiHour': 'Mậu Tý',
      'dayNayin': 'Giản Hạ Thủy',
      'dayElement': 'Thủy',
      'solarTerm': 'Sương Giáng',
      'trucInfo': {
        'name': 'Mãn',
        'type': 'Hoàng Đạo',
        'quality': 'Đại Cát',
        'summary': 'Đầy đủ viên mãn.',
        'goodFor': ['Khai trương'],
        'badFor': ['Tranh chấp'],
      },
      'tuInfo': {
        'name': 'Cang',
        'element': 'Kim',
        'animal': 'Long',
        'nature': 'Hung',
        'desc': 'Cẩn trọng.',
      },
      'hours': [
        {
          'branch': 'Tý',
          'time': '23:00 - 00:59',
          'isAuspicious': true,
          'starName': 'Hoàng Đạo',
        },
        {
          'branch': 'Dần',
          'time': '03:00 - 04:59',
          'isAuspicious': false,
          'starName': 'Hắc Đạo',
        },
      ],
      'hyThan': 'Tây Nam',
      'taiThan': 'Chính Đông',
      'hacThan': 'Chính Đông',
      'recommendedActivities': ['Khai trương'],
      'restrictedActivities': ['Tranh chấp'],
    },
    'personalFortune': null,
    'aiSuggestedPrompt': null,
  },
};
