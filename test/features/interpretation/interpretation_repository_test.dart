import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/interpretation/data/interpretation_repository.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late InterpretationRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    repository = InterpretationRepository(dio);
  });

  test('loads and orders reading sections from server configuration', () async {
    adapter.onGet(
      '/charts/reading-sections/',
      (server) => server.reply(200, {
        'success': true,
        'readingSections': [
          {
            'id': '2',
            'groupSlug': 'cung_chuc',
            'groupTitle': '12 cung',
            'sectionSlug': 'cung_tai_bach',
            'title': 'Cung Tài Bạch',
            'subtitle': 'Tài vận',
            'summary': 'Tóm tắt',
            'iconName': 'Coins',
            'coinCost': 100,
            'order': 2,
          },
          {
            'id': '1',
            'groupSlug': 'ban_menh',
            'groupTitle': 'Bản mệnh',
            'sectionSlug': 'tong_quan',
            'title': 'Tổng quan',
            'subtitle': '',
            'summary': 'Miễn phí',
            'iconName': 'User',
            'coinCost': 0,
            'order': 1,
          },
        ],
      }),
    );

    final result = await repository.getSections();

    expect(result.map((item) => item.id), ['1', '2']);
    expect(result.first.isFree, isTrue);
    expect(result.last.coinCost, 100);
  });

  test('generates interpretation using selected reading mode', () async {
    adapter.onPost(
      '/tuvi/read',
      (server) => server.reply(200, {
        'success': true,
        'data': {
          'overview': {
            'personality': 'Tính cách rõ ràng',
            'career': 'Sự nghiệp ổn định',
          },
          'aiShortSummary': 'Tổng quan lá số',
        },
      }),
      data: {
        'type': 'full',
        'mode': 'doi-thuong',
        'chart': {'id': 'generated-chart'},
      },
    );

    final result = await repository.generate(
      chartData: const {'id': 'generated-chart'},
      mode: InterpretationMode.everyday,
    );

    expect(result.personalityCore, 'Tính cách rõ ràng');
    expect(result.careerFame, 'Sự nghiệp ổn định');
    expect(result.aiShortSummary, 'Tổng quan lá số');
  });

  test('loads unlock keys scoped by chart id', () async {
    adapter.onGet(
      '/charts/reading-unlocks/',
      (server) => server.reply(200, {
        'success': true,
        'unlockedReadingKeys': ['chart-1:cung_chuc:cung_menh:chuyen-sau'],
      }),
      queryParameters: {'chartId': 'chart-1'},
    );

    final result = await repository.getUnlocks(chartId: 'chart-1');

    expect(result, contains('chart-1:cung_chuc:cung_menh:chuyen-sau'));
  });

  test('unlocks through server without mutating balance locally', () async {
    const section = ReadingSection(
      id: 'section-1',
      groupSlug: 'cung_chuc',
      groupTitle: '12 cung',
      sectionSlug: 'cung_menh',
      title: 'Cung Mệnh',
      subtitle: '',
      summary: '',
      iconName: 'User',
      coinCost: 100,
      order: 1,
    );
    adapter.onPost(
      '/charts/reading-unlocks/',
      (server) => server.reply(200, {
        'success': true,
        'wasAlreadyUnlocked': false,
        'balance': 250,
        'cost': 100,
        'saveCost': 0,
        'unlockedReadingKeys': ['chart-1:cung_chuc:cung_menh:chuyen-sau'],
      }),
      data: {
        'chartId': 'chart-1',
        'interpretationMode': 'chuyen-sau',
        'groupSlug': 'cung_chuc',
        'sectionSlug': 'cung_menh',
      },
    );

    final result = await repository.unlock(
      chartId: 'chart-1',
      mode: InterpretationMode.deep,
      section: section,
    );

    expect(result.balance, 250);
    expect(result.cost, 100);
    expect(result.wasAlreadyUnlocked, isFalse);
  });
}
