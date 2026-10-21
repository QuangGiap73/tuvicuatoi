import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/profile_repository.dart';
import '../state/profile_edit_state.dart';

class ProfileEditController extends Notifier<ProfileEditState> {
  @override
  ProfileEditState build() => ProfileEditState.idle;

  Future<bool> submit({
    required String fullName,
    required String phone,
    required String birthDate,
    required String birthTime,
    required String gender,
  }) async {
    if (state.isSubmitting) return false;
    state = ProfileEditState.submitting;
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            fullName: fullName,
            phone: phone,
            birthDate: birthDate,
            birthTime: birthTime,
            gender: gender,
          );
      await ref.read(authControllerProvider.notifier).refreshProfile();
      state = ProfileEditState.success;
      return true;
    } catch (error) {
      state = ProfileEditState.failure(error);
      return false;
    }
  }
}
