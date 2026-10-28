class AccountSettingsState {
  const AccountSettingsState({
    this.isChangingPassword = false,
    this.passwordError,
  });

  final bool isChangingPassword;
  final String? passwordError;

  AccountSettingsState copyWith({
    bool? isChangingPassword,
    String? passwordError,
    bool clearPasswordError = false,
  }) => AccountSettingsState(
    isChangingPassword: isChangingPassword ?? this.isChangingPassword,
    passwordError: clearPasswordError
        ? null
        : passwordError ?? this.passwordError,
  );
}
