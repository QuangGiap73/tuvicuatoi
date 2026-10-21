import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../auth/data/auth_repository.dart';

class ProfileRepository {
  const ProfileRepository(this._dio);

  final Dio _dio;

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
