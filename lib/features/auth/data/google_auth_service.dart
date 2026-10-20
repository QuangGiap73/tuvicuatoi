import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';
import 'auth_repository.dart';

class GoogleAuthService {
  GoogleAuthService();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _initialization;

  Future<String> getIdToken() async {
    if (kIsWeb) {
      throw const AuthException('Nút Google hiện chỉ được cấu hình cho Android và iOS.');
    }
    if (AppConfig.googleServerClientId.isEmpty) {
      throw const AuthException(
        'Thiếu GOOGLE_SERVER_CLIENT_ID. Hãy cấu hình OAuth Client ID trước khi đăng nhập Google.',
      );
    }

    await (_initialization ??= _googleSignIn.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS && AppConfig.googleIosClientId.isNotEmpty
          ? AppConfig.googleIosClientId
          : null,
      serverClientId: AppConfig.googleServerClientId,
    ));

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const AuthException('Thiết bị này không hỗ trợ luồng đăng nhập Google hiện tại.');
    }

    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Google không trả về ID Token để xác thực với máy chủ.');
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Bạn đã hủy đăng nhập Google.');
      }
      throw AuthException('Không thể đăng nhập Google: ${error.description ?? error.code.name}');
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();
}

final googleAuthServiceProvider = Provider<GoogleAuthService>((_) => GoogleAuthService());
