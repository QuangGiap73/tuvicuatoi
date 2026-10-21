import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/auth_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_edit_controller.dart';
import '../state/profile_edit_state.dart';

/// The current server-backed profile. Widgets depending on this provider only
/// rebuild when the AuthUser instance changes, not for unrelated auth state.
final currentProfileProvider = Provider<AuthUser?>((ref) {
  return ref.watch(
    authControllerProvider.select((state) => state.asData?.value?.user),
  );
});

/// Stale-while-revalidate: keep showing the cached session immediately, then
/// refresh once from /auth/me/ whenever the personal-profile route is opened.
final profileRefreshProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.read(authControllerProvider.notifier).refreshProfile();
});

/// Auto-disposed after leaving the edit flow, so error/success state never
/// leaks into a later edit session.
final profileEditControllerProvider =
    NotifierProvider.autoDispose<ProfileEditController, ProfileEditState>(
      ProfileEditController.new,
    );

/// Small selectors prevent the entire form from rebuilding for state fields it
/// does not use.
final profileSubmittingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(
    profileEditControllerProvider.select((state) => state.isSubmitting),
  );
});

final profileEditErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(
    profileEditControllerProvider.select((state) => state.errorMessage),
  );
});
