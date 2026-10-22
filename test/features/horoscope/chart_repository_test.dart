import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/horoscope/data/chart_repository.dart';
import 'package:tuvicuatoi/features/horoscope/domain/chart_request.dart';

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
              'mainStars': [
                {'name': 'Vũ Khúc', 'tag': '(V)'},
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
    expect(result.palaces.single.mainStars.single.name, 'Vũ Khúc');
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
}
