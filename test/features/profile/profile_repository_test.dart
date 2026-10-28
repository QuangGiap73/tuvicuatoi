import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/profile/data/profile_repository.dart';

void main() {
  test('uploadAvatar sends multipart and parses avatar URL', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    final adapter = DioAdapter(dio: dio);
    final repository = ProfileRepository(dio);
    final directory = await Directory.systemTemp.createTemp('avatar_test_');
    final image = File('${directory.path}/avatar.jpg');
    await image.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

    adapter.onPost(
      '/auth/profile/avatar/',
      (server) => server.reply(200, {
        'success': true,
        'avatarUrl': 'https://tuvicuatoi.com/media/avatars/new.jpg',
        'message': 'Cập nhật thành công',
      }),
      data: Matchers.any,
    );

    final result = await repository.uploadAvatar(image.path);

    expect(result.avatarUrl, 'https://tuvicuatoi.com/media/avatars/new.jpg');
    dio.close(force: true);
    try {
      await directory.delete(recursive: true);
    } on FileSystemException {
      // The mock adapter does not consume MultipartFile's stream on Windows,
      // so the temporary handle can remain open until this isolate exits.
    }
  });

  test('changePassword posts the documented password fields', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    final adapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
    final repository = ProfileRepository(dio);

    adapter.onPost(
      '/auth/change-password/',
      (server) => server.reply(200, {
        'success': true,
        'message': 'Đổi mật khẩu thành công',
      }),
      data: {
        'currentPassword': 'MatKhauCu@123',
        'newPassword': 'MatKhauMoi@2026',
      },
    );

    await repository.changePassword(
      currentPassword: 'MatKhauCu@123',
      newPassword: 'MatKhauMoi@2026',
    );
  });

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
