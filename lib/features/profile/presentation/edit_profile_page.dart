import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/mystic_colors.dart';
import '../../../core/widgets/mystic_app_bar.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'providers/profile_providers.dart';
import 'widgets/mystic_profile_save_button.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  String _gender = 'OTHER';

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentProfileProvider);
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dateController = TextEditingController(text: user?.birthDate ?? '');
    _timeController = TextEditingController(text: user?.birthTime ?? '');
    final gender = user?.gender?.toUpperCase();
    if (gender == 'MALE' || gender == 'NAM') _gender = 'MALE';
    if (gender == 'FEMALE' || gender == 'NỮ') _gender = 'FEMALE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileSubmittingProvider);
    final errorMessage = ref.watch(profileEditErrorProvider);
    return MysticScaffold(
      appBar: MysticAppBar(
        title: 'Chỉnh sửa hồ sơ',
        leading: IconButton(
          onPressed: isLoading ? null : context.pop,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          children: [
            _field(
              controller: _nameController,
              label: 'Họ và tên',
              icon: Icons.person_outline_rounded,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập họ và tên'
                  : null,
            ),
            const SizedBox(height: 14),
            _field(
              controller: _phoneController,
              label: 'Số điện thoại',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.isEmpty) return null;
                return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone)
                    ? null
                    : 'Số điện thoại chưa hợp lệ';
              },
            ),
            const SizedBox(height: 14),
            _field(
              controller: _dateController,
              label: 'Ngày sinh',
              icon: Icons.calendar_month_outlined,
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 14),
            _field(
              controller: _timeController,
              label: 'Giờ sinh',
              icon: Icons.schedule_rounded,
              readOnly: true,
              onTap: _pickTime,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(
                labelText: 'Giới tính',
                prefixIcon: Icon(
                  Icons.wc_rounded,
                  color: MysticColors.paleGold,
                ),
              ),
              dropdownColor: const Color(0xFF0B2630),
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('Nam')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Nữ')),
                DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
              ],
              onChanged: isLoading
                  ? null
                  : (value) => setState(() => _gender = value ?? 'OTHER'),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MysticColors.error),
              ),
            ],
            const SizedBox(height: 24),
            MysticProfileSaveButton(
              label: 'Lưu thay đổi hồ sơ',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) => TextFormField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    keyboardType: keyboardType,
    validator: validator,
    textInputAction: TextInputAction.next,
    style: const TextStyle(color: MysticColors.ivory, fontSize: 15),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: MysticColors.paleGold),
    ),
  );

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_dateController.text) ?? DateTime(2000);
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;
    _dateController.text =
        '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime() async {
    final parts = _timeController.text.split(':');
    final initial = parts.length >= 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : const TimeOfDay(hour: 0, minute: 0);
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null) return;
    _timeController.text =
        '${selected.hour.toString().padLeft(2, '0')}:'
        '${selected.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(profileEditControllerProvider.notifier)
        .submit(
          fullName: _nameController.text,
          phone: _phoneController.text,
          birthDate: _dateController.text,
          birthTime: _timeController.text,
          gender: _gender,
        );
    if (!mounted || !success) return;
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Cập nhật hồ sơ thành công.')),
    );
  }
}
