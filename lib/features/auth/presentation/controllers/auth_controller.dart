import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/token_storage.dart';
import '../../data/auth_repository.dart';
import '../../data/google_auth_service.dart';
import '../../domain/auth_user.dart';

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.read();
    if (token == null || token.isEmpty) return null;

    try {
      final user = await ref.read(authRepositoryProvider).me();
      return AuthSession(token: token, user: user);
    } catch (_) {
      await storage.clear();
      return null;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref.read(tokenStorageProvider).write(session.token);
      return session;
    });
    return !state.hasError;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? referralCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .register(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
            referralCode: referralCode,
          );
      await ref.read(tokenStorageProvider).write(session.token);
      return session;
    });
    return !state.hasError;
  }

  Future<bool> loginWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final credential = await ref.read(googleAuthServiceProvider).getIdToken();
      final session = await ref
          .read(authRepositoryProvider)
          .loginWithGoogle(credential);
      await ref.read(tokenStorageProvider).write(session.token);
      return session;
    });
    return !state.hasError;
  }

  Future<void> refreshProfile() async {
    final session = state.asData?.value;
    if (session == null) return;
    final user = await ref.read(authRepositoryProvider).me();
    state = AsyncData(AuthSession(token: session.token, user: user));
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).logout();
      await ref.read(googleAuthServiceProvider).signOut();
    } catch (_) {
      // Đăng xuất cục bộ vẫn phải hoàn tất nếu máy chủ không khả dụng.
    } finally {
      await ref.read(tokenStorageProvider).clear();
      state = const AsyncData(null);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);
