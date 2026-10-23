import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/horoscope/data/chart_repository.dart';
import 'package:tuvicuatoi/features/horoscope/domain/chart_request.dart';
import 'package:tuvicuatoi/features/horoscope/domain/saved_chart.dart';

void main() {
  const request = ChartRequest(
    name: 'Nguyễn Văn An',
    gender: 'Nam',
    day: 15,
    month: 8,
    year: 1995,
    hour: 7,
    calendarType: 'solar',
  );

  test('generate maps chart summary and palaces', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    final adapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
    final repository = ChartRepository(dio);

    adapter.onPost(
      '/chart/generate',
      (server) => server.reply(200, {
        'success': true,
        'data': {
          'id': 'chart-1',
          'fullName': 'Nguyễn Văn An',
          'gender': 'Nam',
          'solarDate': '15/08/1995',
          'solarTime': '07:00 - 08:59',
          'hourBranch': 'Giờ Thìn',
          'lunarDate': '20/07/1995 (Ất Hợi)',
          'lunarYearCanChi': 'Ất Hợi',
          'lunarMonthCanChi': 'Giáp Thân',
          'lunarDayCanChi': 'Mậu Dần',
          'lunarHourCanChi': 'Ất Mão',
          'namXem': '2026 (Bính Ngọ) • 32 tuổi',
          'amDuongThuanLy': 'Âm Dương thuận lý',
          'menhCucBinhHoa': 'Mệnh Hỏa - Cục Kim',
          'thanCu': 'Thân cư THIÊN DI',
          'menh': 'Sơn Đầu Hỏa',
          'cuc': 'Kim Tứ Cục',
          'amDuong': 'Âm Nam',
          'chuMenh': 'Vũ Khúc',
          'chuThan': 'Thiên Cơ',
          'palaces': {
            'Dan': {
              'id': 'Dan',
              'branch': 'Dần',
              'canChi': 'Mậu Dần',
              'name': 'PHU THÊ',
              'element': 'Mộc',
              'isThan': false,
              'thangHan': 'Tháng 10',
              'mainStars': [
                {
                  'name': 'Vũ Khúc',
                  'brightness': 'Vượng Địa',
                  'tag': '(V)',
                  'element': 'Kim',
                  'type': 'chinh-tinh',
                },
              ],
              'luckyStars': ['Thiên Giải'],
              'badStars': ['Đà La'],
              'vongTrangSinh': 'Lâm Quan',
              'daiHanAge': 24,
              'tieuHanAges': [2, 14, 26],
            },
          },
        },
      }),
      data: request.toJson(),
    );

    final result = await repository.generate(request);

    expect(result.fullName, 'Nguyễn Văn An');
    expect(result.palaces, hasLength(1));
    expect(result.lunarMonthCanChi, 'Giáp Thân');
    expect(result.lunarDayCanChi, 'Mậu Dần');
    expect(result.lunarHourCanChi, 'Ất Mão');
    final palace = result.palaces.single;
    expect(palace.thangHan, 'Tháng 10');
    expect(palace.mainStars.single.name, 'Vũ Khúc');
    expect(palace.mainStars.single.brightness, 'Vượng Địa');
    expect(palace.mainStars.single.element, 'Kim');
    expect(palace.mainStars.single.type, 'chinh-tinh');
  });

  test('getMyCharts maps saved chart list', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    final adapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
    final repository = ChartRepository(dio);

    adapter.onGet(
      '/charts/my-charts/',
      (server) => server.reply(200, {
        'success': true,
        'charts': [
          {
            'id': 'chart-id',
            'name': 'Lá Số Nguyễn Văn Giáp 1995',
            'gender': 'Nam',
            'solarDate': '15/08/1995',
            'lunarDate': '20/07/1995 (Ất Hợi)',
            'createdAt': '21/10/2026',
            'chart_data': {'hourBranch': 'Giờ Thìn', 'menh': 'Sơn Đầu Hỏa'},
          },
        ],
      }),
    );

    final charts = await repository.getMyCharts();

    expect(charts, hasLength(1));
    expect(charts.single.id, 'chart-id');
    expect(charts.single.hourBranch, 'Giờ Thìn');
    expect(charts.single.element, 'HỎA');
  });

  test('deleteChart uses documented delete endpoint', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    final adapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
    final repository = ChartRepository(dio);

    adapter.onDelete(
      '/charts/chart-id/delete/',
      (server) => server.reply(200, {'success': true}),
    );

    await repository.deleteChart('chart-id');
  });

  test('getChartDetail keeps complete chart data for AI context', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    final adapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
    final repository = ChartRepository(dio);
    const summary = SavedChart(
      id: 'chart-id',
      name: 'Giáp',
      gender: 'Nam',
      solarDate: '15/08/1995',
      lunarDate: '20/07/1995',
      createdAt: '21/10/2026',
    );

    adapter.onGet(
      '/charts/chart-id/',
      (server) => server.reply(200, {
        'success': true,
        'data': {
          'id': 'chart-id',
          'name': 'Giáp',
          'gender': 'Nam',
          'solarDate': '15/08/1995',
          'chart_data': {
            'menh': 'Sơn Đầu Hỏa',
            'palaces': {
              'Dan': {'name': 'MỆNH'},
            },
          },
        },
      }),
    );

    final detail = await repository.getChartDetail(summary);

    expect(detail.summary.id, 'chart-id');
    expect(detail.chartData['menh'], 'Sơn Đầu Hỏa');
    expect(detail.chartData['palaces'], isA<Map>());
  });

  test(
    'getChartDetail preserves list summary for nested partial response',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
      final adapter = DioAdapter(
        dio: dio,
        matcher: const FullHttpRequestMatcher(),
      );
      final repository = ChartRepository(dio);
      const summary = SavedChart(
        id: 'chart-id',
        name: 'Lá Số Nguyễn Văn Giáp 1995',
        gender: 'Nam',
        solarDate: '15/08/1995',
        lunarDate: '20/07/1995',
        createdAt: '21/10/2026',
        hourBranch: 'Giờ Thìn',
        menh: 'Sơn Đầu Hỏa',
      );

      adapter.onGet(
        '/charts/chart-id/',
        (server) => server.reply(200, {
          'success': true,
          'data': {
            'chart': {
              'id': 'chart-id',
              'chart_data': {
                'palaces': {
                  'Dan': {'name': 'MỆNH'},
                },
              },
            },
          },
        }),
      );

      final detail = await repository.getChartDetail(summary);

      expect(detail.summary.displayName, 'Nguyễn Văn Giáp 1995');
      expect(detail.summary.gender, 'Nam');
      expect(detail.summary.solarDate, '15/08/1995');
      expect(detail.summary.hourBranch, 'Giờ Thìn');
      expect(detail.summary.menh, 'Sơn Đầu Hỏa');
      expect(detail.chartData['palaces'], isA<Map>());
    },
  );
}
