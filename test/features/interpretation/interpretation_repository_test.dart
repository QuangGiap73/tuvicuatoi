import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/interpretation/data/interpretation_repository.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';

void main() {
  test(
    'loads topic content from data array using the requested topic',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
      final adapter = DioAdapter(
        dio: dio,
        matcher: const FullHttpRequestMatcher(),
      );
      final repository = InterpretationRepository(dio);

      adapter.onPost(
        '/luan/chuyen-de',
        (server) => server.reply(200, {
          'success': true,
          'data': [
            {
              'topic_id': 'CD06_DUONG_CON_CAI',
              'name': 'Chuyên đề đường con cái',
              'content': 'Đoạn một.\n\nĐoạn hai.',
              'route': {
                'primary_palaces': ['Tử Tức'],
              },
              'meta': {'source_tier': 'M'},
            },
          ],
        }),
        data: {'topic': 'con cái'},
      );

      final result = await repository.getTopicInterpretation(topic: 'con cái');

      expect(result.topicId, 'CD06_DUONG_CON_CAI');
      expect(result.name, 'Chuyên đề đường con cái');
      expect(result.content, contains('Đoạn hai'));
      expect(result.route['primary_palaces'], ['Tử Tức']);
    },
  );

  test('empty topic data is treated as unsupported', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    final adapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
    final repository = InterpretationRepository(dio);

    adapter.onPost(
      '/luan/chuyen-de',
      (server) => server.reply(200, {'success': true, 'data': []}),
      data: {'topic': 'không hỗ trợ'},
    );

    expect(
      () => repository.getTopicInterpretation(topic: 'không hỗ trợ'),
      throwsA(isA<InterpretationException>()),
    );
  });

  late Dio dio;
  late DioAdapter adapter;
  late InterpretationRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    repository = InterpretationRepository(dio);
  });

  test('merges saved and generated interpretation using richer content', () {
    const saved = InterpretationData(
      personalityCore: 'Nội dung ngắn.',
      wealthAccumulation: 'Tài lộc từ bản đã lưu.',
      rawData: {'saved': true},
    );
    const generated = InterpretationData(
      personalityCore:
          'Nội dung bản mệnh chi tiết hơn được sinh lại sau khi mở khóa.',
      careerFame: 'Nội dung sự nghiệp.',
      rawData: {'generated': true},
    );

    final result = saved.mergeDetailed(generated);

    expect(result.personalityCore, generated.personalityCore);
    expect(result.wealthAccumulation, saved.wealthAccumulation);
    expect(result.careerFame, generated.careerFame);
    expect(result.rawData, containsPair('saved', true));
    expect(result.rawData, containsPair('generated', true));
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
            'isPublicOverview': true,
          },
        ],
      }),
    );

    final result = await repository.getSections();

    expect(result.map((item) => item.id), ['1', '2']);
    expect(result.first.isFree, isTrue);
    expect(result.first.isPublicOverview, isTrue);
    expect(result.last.isPublicOverview, isFalse);
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
        'year': 2026,
        'month': 8,
        'day': 15,
        'chart': {'id': 'generated-chart'},
      },
    );

    final result = await repository.generate(
      chartData: const {'id': 'generated-chart'},
      mode: InterpretationMode.everyday,
      readingDate: DateTime(2026, 8, 15),
    );

    expect(result.personalityCore, 'Tính cách rõ ràng');
    expect(result.careerFame, 'Sự nghiệp ổn định');
    expect(result.aiShortSummary, 'Tổng quan lá số');
  });

  test('parses full tuvi read response without dropping nested content', () {
    final result = InterpretationData.fromJson({
      'chartId': 'chart-engine',
      'overview': [
        {
          'id': 'CD01_TINH_CACH_BAN_THAN',
          'title': 'TÃ­nh cÃ¡ch báº£n thÃ¢n',
          'items': [
            {
              'title': 'ThiÃªn CÆ¡ táº¡i Má»‡nh',
              'content': 'Ná»™i dung tÃ­nh cÃ¡ch',
            },
          ],
        },
        {
          'id': 'CD02_CONG_DANH',
          'title': 'CÃ´ng danh',
          'items': [
            {'title': 'Quan Lá»™c', 'content': 'Ná»™i dung sá»± nghiá»‡p'},
          ],
        },
      ],
      'palaceReadings': [
        {
          'palaceId': 'Dan',
          'palaceName': 'Tá»¬ Tá»¨C',
          'summary': 'Tá»•ng quan cung con cÃ¡i',
          'items': [
            {'title': 'VÅ© KhÃºc', 'content': 'Chi tiáº¿t cung con cÃ¡i'},
          ],
        },
      ],
      'timing': {
        'daiVan': {
          'title': 'Äáº¡i Váº­n',
          'items': [
            {'title': '24-33 tuá»•i', 'content': 'Ná»™i dung Ä‘áº¡i váº­n'},
          ],
        },
        'tieuVan': {
          'title': 'Tiá»ƒu Háº¡n',
          'items': [
            {'title': 'NÄƒm 2026', 'content': 'Ná»™i dung tiá»ƒu háº¡n'},
          ],
        },
      },
      'guidance': [
        {
          'id': 'phong-thuy-nen-tang',
          'title': 'Ná»n táº£ng phong thá»§y',
          'items': [
            {'title': 'Má»‡nh quÃ¡i', 'content': 'Ná»™i dung phong thá»§y'},
          ],
        },
      ],
    });

    expect(result.overviewSections, hasLength(2));
    expect(result.personalityCore, contains('Ná»™i dung tÃ­nh cÃ¡ch'));
    expect(result.careerFame, contains('Ná»™i dung sá»± nghiá»‡p'));
    expect(
      result.palaceReadingSections.single.fullText,
      contains('Chi tiáº¿t'),
    );
    expect(result.palaces.single.summary, contains('Chi tiáº¿t cung con cÃ¡i'));
    expect(result.decennialFortune, contains('Ná»™i dung Ä‘áº¡i váº­n'));
    expect(result.yearlyFortune, contains('Ná»™i dung tiá»ƒu háº¡n'));
    expect(result.fengshuiAdvice, contains('Ná»™i dung phong thá»§y'));
  });

  test('keeps server unlock state and locked teaser from tuvi read', () {
    final result = InterpretationData.fromJson({
      'overview': [
        {
          'id': 'CD06_DUONG_CON_CAI',
          'title': 'Children',
          'summary': 'Server teaser.',
          'isUnlocked': false,
          'items': [],
        },
        {
          'id': 'CD15_THI_CU',
          'title': 'Education',
          'summary': 'Education teaser.',
          'isUnlocked': true,
          'items': [
            {'title': 'Exam', 'content': 'Full server content.'},
          ],
        },
      ],
    });

    expect(result.isEmpty, isFalse);
    expect(result.overviewSections.first.isUnlocked, isFalse);
    expect(result.overviewSections.first.items, isEmpty);
    expect(result.overviewSections.first.fullText, contains('Server teaser'));
    expect(result.overviewSections.last.isUnlocked, isTrue);
    expect(
      result.overviewSections.last.fullText,
      contains('Full server content'),
    );
  });

  test('keeps detailed content from nested saved payload and palace map', () {
    final result = InterpretationData.fromJson({
      'interpretation': {
        'general_reading': {'personality_core': 'Detailed destiny content.'},
        'palaces': {
          'QUAN_LOC': {
            'stars': 'Pha Quan',
            'content': 'Detailed career palace content.',
          },
        },
      },
    });

    expect(result.personalityCore, 'Detailed destiny content.');
    expect(result.palaces, hasLength(1));
    expect(result.palaces.single.palace, 'QUAN_LOC');
    expect(result.palaces.single.summary, 'Detailed career palace content.');
  });

  test('finds interpretation fields inside unknown backend envelopes', () {
    final result = InterpretationData.fromJson({
      'payload': {
        'fullReading': {
          'personality_core': 'Nested personality content.',
          'career_reading': 'Nested career content.',
          'palace_readings': {
            'Dan': {
              'name': 'Cung Menh',
              'interpretation': 'Nested palace content.',
            },
          },
        },
      },
    });

    expect(result.personalityCore, 'Nested personality content.');
    expect(result.careerFame, 'Nested career content.');
    expect(result.palaces.single.palace, 'Cung Menh');
    expect(result.palaces.single.summary, 'Nested palace content.');
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

  test('unlocks a bundle atomically with optional voucher', () async {
    const sections = [
      ReadingSection(
        id: 'wealth',
        groupSlug: 'tong_quan',
        groupTitle: 'Tổng quan',
        sectionSlug: 'tai_loc',
        title: 'Tài lộc',
        subtitle: '',
        summary: '',
        iconName: 'Coins',
        coinCost: 100,
        order: 1,
      ),
      ReadingSection(
        id: 'health',
        groupSlug: 'tong_quan',
        groupTitle: 'Tổng quan',
        sectionSlug: 'suc_khoe',
        title: 'Sức khỏe',
        subtitle: '',
        summary: '',
        iconName: 'Health',
        coinCost: 100,
        order: 2,
      ),
    ];
    adapter.onPost(
      '/charts/reading-unlocks/',
      (server) => server.reply(200, {
        'success': true,
        'wasAlreadyUnlocked': false,
        'balance': 800,
        'cost': 160,
        'saveCost': 40,
        'unlockedReadingKeys': [
          'chart-1:tong_quan:tai_loc:chuyen-sau',
          'chart-1:tong_quan:suc_khoe:chuyen-sau',
        ],
      }),
      data: {
        'chartId': 'chart-1',
        'interpretationMode': 'chuyen-sau',
        'sections': [
          {'groupSlug': 'tong_quan', 'sectionSlug': 'tai_loc'},
          {'groupSlug': 'tong_quan', 'sectionSlug': 'suc_khoe'},
        ],
        'voucherCode': 'TUVI2026',
      },
    );

    final result = await repository.unlockBundle(
      chartId: 'chart-1',
      mode: InterpretationMode.deep,
      sections: sections,
      voucherCode: 'TUVI2026',
    );

    expect(result.cost, 160);
    expect(result.saveCost, 40);
    expect(result.unlockedKeys, hasLength(2));
  });
}
