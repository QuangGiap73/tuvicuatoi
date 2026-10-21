import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/profile/data/profile_repository.dart';

void main() {
  test('updateProfile posts the documented profile fields', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    final adapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
    final repository = ProfileRepository(dio);

    adapter.onPost(
      '/auth/profile/update/',
      (server) => server.reply(200, {'success': true}),
      data: {
        'fullName': 'Nguyễn Văn An',
        'phone': '0912345678',
        'birthDate': '1995-08-20',
        'birthTime': '07:30',
        'gender': 'MALE',
      },
    );

    await repository.updateProfile(
      fullName: ' Nguyễn Văn An ',
      phone: ' 0912345678 ',
      birthDate: '1995-08-20',
      birthTime: '07:30',
      gender: 'MALE',
    );
  });
}
