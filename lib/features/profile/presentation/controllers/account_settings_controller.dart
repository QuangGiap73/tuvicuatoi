import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/auth_repository.dart';
import '../../data/profile_repository.dart';
import '../state/account_settings_state.dart';

class AccountSettingsController extends Notifier<AccountSettingsState> {
  @override
  AccountSettingsState build() => const AccountSettingsState();

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.isChangingPassword) return false;
    state = state.copyWith(isChangingPassword: true, clearPasswordError: true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      state = state.copyWith(
        isChangingPassword: false,
        clearPasswordError: true,
      );
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(
        isChangingPassword: false,
        passwordError: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isChangingPassword: false,
        passwordError: 'Không thể đổi mật khẩu. Vui lòng thử lại.',
      );
      return false;
    }
  }

  void clearPasswordError() => state = state.copyWith(clearPasswordError: true);
}

final accountSettingsControllerProvider =
    NotifierProvider<AccountSettingsController, AccountSettingsState>(
      AccountSettingsController.new,
    );
