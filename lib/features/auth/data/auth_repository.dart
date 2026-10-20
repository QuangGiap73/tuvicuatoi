import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/auth_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  const AuthRepository(this._dio);
  final Dio _dio;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login/',
        data: {'email': email.trim(), 'password': password},
      );
      return _sessionFrom(response.data);
    } on DioException catch (error) {
      throw AuthException(_messageFrom(error));
    }
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register/',
        data: {
          'email': email.trim(),
          'password': password,
          'fullName': fullName.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (referralCode != null && referralCode.trim().isNotEmpty)
            'referralCode': referralCode.trim(),
        },
      );
      return _sessionFrom(response.data);
    } on DioException catch (error) {
      throw AuthException(_messageFrom(error));
    }
  }

  Future<AuthSession> loginWithGoogle(String credential) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google/',
        data: {'credential': credential},
      );
      return _sessionFrom(response.data);
    } on DioException catch (error) {
      throw AuthException(_messageFrom(error));
    }
  }

  Future<AuthUser> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me/');
      final data = response.data;
      final user = data?['user'];
      if (data?['success'] != true || user is! Map) {
        throw const AuthException('Phiên đăng nhập không hợp lệ.');
      }
      return AuthUser.fromJson(Map<String, dynamic>.from(user));
    } on DioException catch (error) {
      throw AuthException(_messageFrom(error));
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout/');
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;
    }
  }

  AuthSession _sessionFrom(Map<String, dynamic>? data) {
    final token = (data?['token'] ?? data?['session_id'])?.toString();
    final user = data?['user'];
    if (data?['success'] != true ||
        token == null ||
        token.isEmpty ||
        user is! Map) {
      throw const AuthException('Phản hồi đăng nhập không hợp lệ.');
    }
    return AuthSession(
      token: token,
      user: AuthUser.fromJson(Map<String, dynamic>.from(user)),
    );
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return error.userMessage;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);
