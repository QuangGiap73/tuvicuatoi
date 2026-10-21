enum ProfileEditStatus { idle, submitting, success, failure }

class ProfileEditState {
  const ProfileEditState({
    this.status = ProfileEditStatus.idle,
    this.errorMessage,
  });

  final ProfileEditStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == ProfileEditStatus.submitting;
  bool get hasError => status == ProfileEditStatus.failure;

  static const idle = ProfileEditState();
  static const submitting = ProfileEditState(
    status: ProfileEditStatus.submitting,
  );
  static const success = ProfileEditState(status: ProfileEditStatus.success);

  factory ProfileEditState.failure(Object error) => ProfileEditState(
    status: ProfileEditStatus.failure,
    errorMessage: error.toString(),
  );
}
