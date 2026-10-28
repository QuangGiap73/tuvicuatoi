import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_user.dart';
import '../domain/avatar_upload_result.dart';

class ProfileRepository {
  const ProfileRepository(this._dio);

  final Dio _dio;

  Future<AvatarUploadResult> uploadAvatar(String filePath) async {
    final normalizedPath = filePath.trim();
    if (normalizedPath.isEmpty) {
      throw const AuthException('Không tìm thấy ảnh cần tải lên.');
    }

    final filename = normalizedPath.split(RegExp(r'[/\\]')).last;
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          normalizedPath,
          filename: filename.isEmpty ? 'avatar.jpg' : filename,
        ),
      });
      final response = await _dio.post<Object?>(
        '/auth/profile/avatar/',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: const {'Accept': 'application/json'},
        ),
      );
      final body = response.data;
      if (body is! Map) {
        throw const AuthException('Máy chủ trả về dữ liệu ảnh không hợp lệ.');
      }
      if (body['success'] == false) {
        throw AuthException(
          _apiMessage(body) ?? 'Không thể cập nhật ảnh đại diện.',
        );
      }

      final userJson = body['user'];
      final avatarUrl =
          (body['avatarUrl'] ??
                  (userJson is Map ? userJson['avatarUrl'] : null))
              ?.toString()
              .trim();
      if (avatarUrl == null || avatarUrl.isEmpty) {
        throw const AuthException(
          'Máy chủ chưa trả về đường dẫn ảnh đại diện.',
        );
      }
      return AvatarUploadResult(
        avatarUrl: avatarUrl,
        user: userJson is Map
            ? AuthUser.fromJson(Map<String, dynamic>.from(userJson))
            : null,
        message: body['message']?.toString(),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map) {
        final message = _apiMessage(data);
        if (message != null) throw AuthException(message);
      }
      if (error.response?.statusCode == 413) {
        throw const AuthException('Ảnh vượt quá dung lượng máy chủ cho phép.');
      }
      throw AuthException(error.userMessage);
    }
  }

  static String? _apiMessage(Map<dynamic, dynamic> data) {
    final value = data['message'] ?? data['error'] ?? data['detail'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/auth/change-password/',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message = body['message'] ?? body['error'] ?? body['detail'];
        throw AuthException(message?.toString() ?? 'Không thể đổi mật khẩu.');
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['error'] ?? data['detail'];
        if (message is String && message.trim().isNotEmpty) {
          throw AuthException(message);
        }
      }
      throw AuthException(error.userMessage);
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String birthDate,
    required String birthTime,
    required String gender,
  }) async {
    try {
      await _dio.post<Object?>(
        '/auth/profile/update/',
        data: {
          'fullName': fullName.trim(),
          'phone': phone.trim(),
          'birthDate': birthDate,
          'birthTime': birthTime,
          'gender': gender,
        },
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['error'] ?? data['detail'];
        if (message is String && message.trim().isNotEmpty) {
          throw AuthException(message);
        }
      }
      throw AuthException(error.userMessage);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioProvider)),
);
