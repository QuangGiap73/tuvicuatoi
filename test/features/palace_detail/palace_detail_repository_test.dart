import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/palace_detail/data/palace_detail_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late PalaceDetailRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    repository = PalaceDetailRepository(dio);
  });

  test('posts palace and main stars to documented palace endpoint', () async {
    adapter.onPost(
      '/luan/cung',
      (server) => server.reply(200, {
        'success': true,
        'data': [
          {
            'id': 'rule-1',
            'name': 'Phá Quân cư Quan Lộc',
            'palace': 'QUAN LỘC',
            'stars': ['Phá Quân'],
            'summary': 'Tinh chủ biến động và đổi mới.',
            'content': 'Nội dung dài từ backend.',
          },
        ],
      }),
      data: {
        'palaceName': 'QUAN LỘC',
        'stars': ['Phá Quân'],
      },
    );

    final result = await repository.getPalaceRules(
      palaceName: 'QUAN LỘC',
      stars: const ['Phá Quân'],
    );

    expect(result, hasLength(1));
    expect(result.single.stars, ['Phá Quân']);
    expect(result.single.summary, 'Tinh chủ biến động và đổi mới.');
  });

  test('posts actual related stars to tam phuong endpoint', () async {
    adapter.onPost(
      '/luan/tam-phuong',
      (server) => server.reply(200, {
        'success': true,
        'data': [
          {
            'title': 'Tam phương hội chiếu',
            'nature': 'Cát hung đan xen',
            'meaning': 'Ý nghĩa do backend trả về.',
          },
        ],
      }),
      data: {
        'palaceName': 'QUAN LỘC',
        'triadStars': ['Phá Quân', 'Tham Lang', 'Thiên Phủ'],
      },
    );

    final result = await repository.getTriadRules(
      palaceName: 'QUAN LỘC',
      triadStars: const ['Phá Quân', 'Tham Lang', 'Thiên Phủ'],
    );

    expect(result.single.title, 'Tam phương hội chiếu');
    expect(result.single.meaning, 'Ý nghĩa do backend trả về.');
  });
}
