import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../state/forgot_password_state.dart';

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<bool> sendCode(String email) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final expires = await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(email);
      state = state.copyWith(
        step: ForgotPasswordStep.otp,
        email: email.trim(),
        expiresInMinutes: expires,
        isSubmitting: false,
        clearError: true,
      );
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final token = await ref
          .read(authRepositoryProvider)
          .verifyPasswordResetCode(email: state.email, code: code);
      state = state.copyWith(
        step: ForgotPasswordStep.newPassword,
        resetToken: token,
        isSubmitting: false,
        clearError: true,
      );
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    final token = state.resetToken;
    if (state.isSubmitting || token == null) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(
            email: state.email,
            resetToken: token,
            newPassword: newPassword,
          );
      state = state.copyWith(isSubmitting: false, clearError: true);
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    }
  }

  void back() {
    if (state.isSubmitting) return;
    state = switch (state.step) {
      ForgotPasswordStep.email => state,
      ForgotPasswordStep.otp => ForgotPasswordState(email: state.email),
      ForgotPasswordStep.newPassword => state.copyWith(
        step: ForgotPasswordStep.otp,
        clearError: true,
      ),
    };
  }
}

final forgotPasswordControllerProvider =
    NotifierProvider.autoDispose<ForgotPasswordController, ForgotPasswordState>(
      ForgotPasswordController.new,
    );
