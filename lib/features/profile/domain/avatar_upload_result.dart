import '../../auth/domain/auth_user.dart';

class AvatarUploadResult {
  const AvatarUploadResult({required this.avatarUrl, this.user, this.message});

  final String avatarUrl;
  final AuthUser? user;
  final String? message;
}
