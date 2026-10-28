enum AvatarUpdateStatus { idle, picking, cropping, uploading, success, failure }

class AvatarUpdateState {
  const AvatarUpdateState({
    this.status = AvatarUpdateStatus.idle,
    this.previewPath,
    this.errorMessage,
  });

  final AvatarUpdateStatus status;
  final String? previewPath;
  final String? errorMessage;

  bool get isBusy =>
      status == AvatarUpdateStatus.picking ||
      status == AvatarUpdateStatus.cropping ||
      status == AvatarUpdateStatus.uploading;

  AvatarUpdateState copyWith({
    AvatarUpdateStatus? status,
    String? previewPath,
    bool clearPreview = false,
    String? errorMessage,
    bool clearError = false,
  }) => AvatarUpdateState(
    status: status ?? this.status,
    previewPath: clearPreview ? null : previewPath ?? this.previewPath,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
