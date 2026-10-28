import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/avatar_image_service.dart';
import '../../data/profile_repository.dart';
import '../state/avatar_update_state.dart';

class AvatarUpdateController extends Notifier<AvatarUpdateState> {
  static const _maxUploadBytes = 10 * 1024 * 1024;

  @override
  AvatarUpdateState build() => const AvatarUpdateState();

  Future<bool> selectAndUpload(ImageSource source) async {
    if (state.isBusy) return false;
    state = const AvatarUpdateState(status: AvatarUpdateStatus.picking);
    try {
      final service = ref.read(avatarImageServiceProvider);
      final picked = await service.pick(source);
      if (picked == null) {
        state = const AvatarUpdateState();
        return false;
      }

      state = const AvatarUpdateState(status: AvatarUpdateStatus.cropping);
      final cropped = await service.crop(picked.path);
      if (cropped == null) {
        state = const AvatarUpdateState();
        return false;
      }
      final length = await service.fileLength(cropped.path);
      if (length <= 0) {
        throw const AvatarUpdateException('Ảnh đã chọn bị rỗng.');
      }
      if (length > _maxUploadBytes) {
        throw const AvatarUpdateException('Ảnh phải nhỏ hơn hoặc bằng 10 MB.');
      }

      state = AvatarUpdateState(
        status: AvatarUpdateStatus.uploading,
        previewPath: cropped.path,
      );
      final result = await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(cropped.path);
      ref
          .read(authControllerProvider.notifier)
          .applyAvatarUrl(result.avatarUrl);
      state = AvatarUpdateState(
        status: AvatarUpdateStatus.success,
        previewPath: cropped.path,
      );
      return true;
    } catch (error) {
      state = AvatarUpdateState(
        status: AvatarUpdateStatus.failure,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void clearMessage() {
    state = state.copyWith(status: AvatarUpdateStatus.idle, clearError: true);
  }
}

class AvatarUpdateException implements Exception {
  const AvatarUpdateException(this.message);
  final String message;

  @override
  String toString() => message;
}

final avatarUpdateControllerProvider =
    NotifierProvider.autoDispose<AvatarUpdateController, AvatarUpdateState>(
      AvatarUpdateController.new,
    );
