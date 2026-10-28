import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'controllers/account_settings_controller.dart';
import 'providers/profile_providers.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentProfileProvider);
    final canChangePassword = user?.hasPassword == true;
    final media = MediaQuery.of(context);
    return MysticScaffold(
      extendBodyBehindAppBar: true,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.profilePageBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            cacheWidth: (media.size.width * media.devicePixelRatio).round(),
            filterQuality: FilterQuality.medium,
          ),
          const ColoredBox(color: Color(0xA8021019)),
        ],
      ),
      appBar: _SettingsAppBar(onBack: context.pop),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SettingsSection(
            title: 'Bảo mật',
            icon: Icons.shield_outlined,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.lock_rounded,
                  watermarkIcon: Icons.shield_rounded,
                  title: 'Thay đổi mật khẩu',
                  subtitle: canChangePassword
                      ? 'Cập nhật mật khẩu để bảo vệ tài khoản'
                      : 'Tài khoản Google chưa thiết lập mật khẩu',
                  enabled: canChangePassword,
                  onTap: () => _showChangePassword(context),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(height: 1, color: Color(0x557B6330)),
                ),
                _SettingsTile(
                  icon: Icons.lock_reset_rounded,
                  watermarkIcon: Icons.mark_email_read_outlined,
                  title: 'Quên mật khẩu',
                  subtitle: canChangePassword
                      ? 'Nhận mã OTP qua email để đặt lại mật khẩu'
                      : 'Không áp dụng cho tài khoản đăng nhập bằng Google',
                  enabled: canChangePassword,
                  onTap: () => context.push(
                    '${AppRoute.forgotPassword}?email='
                    '${Uri.encodeQueryComponent(user?.email ?? '')}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Khu vực nguy hiểm',
            icon: Icons.delete_outline_rounded,
            danger: true,
            child: _SettingsTile(
              icon: Icons.delete_rounded,
              watermarkIcon: Icons.delete_forever_rounded,
              title: 'Xóa tài khoản',
              subtitle:
                  'Xóa vĩnh viễn tài khoản và dữ liệu liên quan trên máy chủ',
              danger: true,
              onTap: () => _showDeleteUnavailable(context),
            ),
          ),
          const SizedBox(height: 9),
          const _DangerNotice(),
        ],
      ),
    );
  }

  Future<void> _showChangePassword(BuildContext context) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ChangePasswordDialog(),
  );

  Future<void> _showDeleteUnavailable(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFFF3DFB2),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Color(0xFF9D332C),
        size: 38,
      ),
      title: const Text('Chưa thể xóa tài khoản'),
      content: const Text(
        'Backend chưa cung cấp API xóa tài khoản. Chức năng này sẽ được '
        'kích hoạt sau khi máy chủ hỗ trợ xóa vĩnh viễn và xác nhận lại '
        'mật khẩu.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Đã hiểu'),
        ),
      ],
    ),
  );
}

class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SettingsAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 64,
    backgroundColor: const Color(0xC7041520),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    leadingWidth: 50,
    leading: IconButton(
      tooltip: 'Quay lại',
      onPressed: onBack,
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Color(0xFFFFD56C),
        size: 22,
      ),
    ),
    title: const Text(
      'Cài đặt tài khoản',
      style: TextStyle(
        color: Color(0xFFFFD98A),
        fontFamily: 'serif',
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: Color(0x889A752E)),
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
    this.danger = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool danger;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          children: [
            Icon(
              icon,
              color: danger ? const Color(0xFFFF5A57) : const Color(0xFFFFD36C),
              size: 18,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: danger
                      ? const Color(0xFFFF5A57)
                      : const Color(0xFFFFD98A),
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .55,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Transform.rotate(
              angle: .78,
              child: Container(
                width: 5,
                height: 5,
                color: danger
                    ? const Color(0xFFFF5A57)
                    : const Color(0xFFFFD36C),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 24,
              height: 1,
              color: danger ? const Color(0x775B292A) : const Color(0x777B6330),
            ),
          ],
        ),
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          color: danger ? const Color(0xD0121B24) : const Color(0xD00A1D27),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: danger ? const Color(0xFFFF4F4C) : const Color(0xFFD6A948),
            width: 1.25,
          ),
        ),
        child: child,
      ),
    ],
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.watermarkIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.danger = false,
  });

  final IconData icon;
  final IconData watermarkIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? const Color(0xFFFF4F4C) : const Color(0xFFFFD36C);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 74),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: 38,
                child: Icon(
                  watermarkIcon,
                  size: 58,
                  color: accent.withValues(alpha: .075),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 9, 9),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x33000000),
                        border: Border.all(color: accent, width: 1.25),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        color: enabled ? accent : const Color(0xFF776F61),
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: enabled
                                  ? const Color(0xFFF7E9CD)
                                  : const Color(0xFF8D8577),
                              fontFamily: 'serif',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFAAA7A0),
                              fontSize: 11.5,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (enabled)
                      Icon(
                        Icons.chevron_right_rounded,
                        color: accent,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerNotice extends StatelessWidget {
  const _DangerNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xB9161E24),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: const Color(0xFF9B7938)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.priority_high_rounded, color: Color(0xFFD4B466), size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Mọi dữ liệu cá nhân, lá số, lịch sử giao dịch và nội dung đã mở '
            'khóa sẽ bị xóa vĩnh viễn. Máy chủ hiện chưa kích hoạt thao tác này.',
            style: TextStyle(
              color: Color(0xFFBEB9AF),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountSettingsControllerProvider);
    return Dialog(
      elevation: 18,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFA071923),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD6A948), width: 1.2),
            boxShadow: const [
              BoxShadow(color: Color(0x99000000), blurRadius: 24),
              BoxShadow(color: Color(0x337E5A13), blurRadius: 12),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_reset_rounded,
                        color: Color(0xFFFFD36C),
                        size: 23,
                      ),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Text(
                          'Thay đổi mật khẩu',
                          style: TextStyle(
                            color: Color(0xFFFFD98A),
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        visualDensity: VisualDensity.compact,
                        onPressed: state.isChangingPassword
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 21),
                        color: const Color(0xFFC8B991),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0x667B6330), height: 14),
                  _passwordField(
                    controller: _currentController,
                    label: 'Mật khẩu hiện tại',
                    obscure: _obscureCurrent,
                    onToggle: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  const SizedBox(height: 10),
                  _passwordField(
                    controller: _newController,
                    label: 'Mật khẩu mới',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    validator: (value) => (value?.length ?? 0) < 8
                        ? 'Mật khẩu cần ít nhất 8 ký tự'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _passwordField(
                    controller: _confirmController,
                    label: 'Nhập lại mật khẩu mới',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    validator: (value) => value != _newController.text
                        ? 'Mật khẩu xác nhận chưa khớp'
                        : null,
                  ),
                  if (state.passwordError != null) ...[
                    const SizedBox(height: 9),
                    Text(
                      state.passwordError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFF7771),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isChangingPassword
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC8B991),
                            side: const BorderSide(color: Color(0xFF7B6330)),
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: state.isChangingPassword ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB77A13),
                            foregroundColor: const Color(0xFFFFF3CE),
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: state.isChangingPassword
                              ? const SizedBox.square(
                                  dimension: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFFF3CE),
                                  ),
                                )
                              : const Text(
                                  'Đổi mật khẩu',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    obscureText: obscure,
    enableSuggestions: false,
    autocorrect: false,
    autofillHints: const [AutofillHints.password],
    validator:
        validator ??
        (value) =>
            value == null || value.isEmpty ? 'Không được để trống' : null,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFBEB7A8), fontSize: 13),
      floatingLabelStyle: const TextStyle(color: Color(0xFFFFD36C)),
      filled: true,
      fillColor: const Color(0xFF102934),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      errorStyle: const TextStyle(color: Color(0xFFFF7771), fontSize: 10.5),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF52646A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD6A948), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF5A57)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF7771), width: 1.2),
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        visualDensity: VisualDensity.compact,
        color: const Color(0xFFE6D8B7),
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
      ),
    ),
    style: const TextStyle(color: Color(0xFFF3E8CF), fontSize: 14),
  );

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(accountSettingsControllerProvider.notifier)
        .changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );
    if (!mounted || !success) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Đổi mật khẩu thành công.')),
    );
  }
}
