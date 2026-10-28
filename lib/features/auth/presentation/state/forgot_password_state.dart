enum ForgotPasswordStep { email, otp, newPassword }

class ForgotPasswordState {
  const ForgotPasswordState({
    this.step = ForgotPasswordStep.email,
    this.email = '',
    this.resetToken,
    this.expiresInMinutes,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final ForgotPasswordStep step;
  final String email;
  final String? resetToken;
  final int? expiresInMinutes;
  final bool isSubmitting;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    String? email,
    String? resetToken,
    int? expiresInMinutes,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) => ForgotPasswordState(
    step: step ?? this.step,
    email: email ?? this.email,
    resetToken: resetToken ?? this.resetToken,
    expiresInMinutes: expiresInMinutes ?? this.expiresInMinutes,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
