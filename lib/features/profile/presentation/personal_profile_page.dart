import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/theme/mystic_colors.dart';
import '../../../core/widgets/mystic_app_bar.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'providers/profile_providers.dart';
import 'widgets/mystic_profile_save_button.dart';

class PersonalProfilePage extends ConsumerWidget {
  const PersonalProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(profileRefreshProvider);
    final user = ref.watch(currentProfileProvider);
    return MysticScaffold(
      appBar: MysticAppBar(
        title: 'Hồ sơ bản mệnh',
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Chỉnh sửa',
            onPressed: () => context.push(AppRoute.editProfile),
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _IdentityCard(
            name: user?.fullName ?? '',
            email: user?.email ?? '',
            avatarUrl: user?.avatarUrl,
            memberSince: user?.memberSince,
          ),
          const SizedBox(height: 16),
          _DetailsCard(
            rows: [
              ('Số điện thoại', _value(user?.phone)),
              ('Ngày sinh', _value(user?.birthDate)),
              ('Giờ sinh', _value(user?.birthTime)),
              ('Giới tính', _genderLabel(user?.gender)),
              ('Gói thành viên', _value(user?.packageName)),
              ('Mã giới thiệu', _value(user?.referralCode)),
            ],
          ),
          const SizedBox(height: 22),
          MysticProfileSaveButton(
            label: 'Chỉnh sửa thông tin',
            isLoading: false,
            icon: Icons.edit_outlined,
            onPressed: () => context.push(AppRoute.editProfile),
          ),
        ],
      ),
    );
  }

  static String _value(String? value) =>
      value == null || value.trim().isEmpty ? 'Chưa cập nhật' : value.trim();

  static String _genderLabel(String? value) => switch (value?.toUpperCase()) {
    'MALE' || 'NAM' => 'Nam',
    'FEMALE' || 'NỮ' => 'Nữ',
    'OTHER' || 'KHÁC' => 'Khác',
    _ => 'Chưa cập nhật',
  };
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.memberSince,
  });
  final String name;
  final String email;
  final String? avatarUrl;
  final String? memberSince;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
      final cacheWidth = (constraints.maxWidth * pixelRatio).round();
      return Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF071421),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: MysticColors.gold.withValues(alpha: .78),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -6,
              top: -5,
              right: -6,
              bottom: -5,
              child: Image.asset(
                MysticAssets.profileCardBackground,
                fit: BoxFit.fill,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: MysticColors.gold, width: 1.2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x55D9AE5F), blurRadius: 7),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 29,
                      backgroundColor: const Color(0xFF173047),
                      foregroundImage: _rasterAvatar(avatarUrl),
                      child: Text(
                        name.trim().isEmpty
                            ? 'T'
                            : name.trim().characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: MysticColors.paleGold,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.trim().isEmpty ? 'Tài khoản Tử Vi' : name.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MysticColors.ivory,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFAEB7C2),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const _OrnamentalDivider(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: MysticColors.gold,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Thành viên từ: ${_formattedMemberSince()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF98A4B1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  ImageProvider<Object>? _rasterAvatar(String? value) {
    final url = value?.trim();
    if (url == null || url.isEmpty || url.toLowerCase().endsWith('.svg')) {
      return null;
    }
    return ResizeImage(NetworkImage(url), width: 160, height: 160);
  }

  String _formattedMemberSince() {
    final raw = memberSince?.trim();
    if (raw == null || raw.isEmpty) return 'Chưa cập nhật';

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return '${parsed.day.toString().padLeft(2, '0')}/'
          '${parsed.month.toString().padLeft(2, '0')}/'
          '${parsed.year.toString().padLeft(4, '0')}';
    }

    final vietnameseDate = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}').firstMatch(raw);
    return vietnameseDate?.group(0) ?? raw;
  }
}

class _OrnamentalDivider extends StatelessWidget {
  const _OrnamentalDivider();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 9,
    child: Row(
      children: [
        Expanded(child: _line(toCenter: true)),
        const SizedBox(width: 5),
        Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: .785398,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFF071421),
                  border: Border.all(color: const Color(0xFFDDB75F), width: 1),
                ),
              ),
            ),
            const SizedBox.square(
              dimension: 2,
              child: ColoredBox(color: Color(0xFFFFE69A)),
            ),
          ],
        ),
        const SizedBox(width: 5),
        Expanded(child: _line(toCenter: false)),
      ],
    ),
  );

  Widget _line({required bool toCenter}) => Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: toCenter
            ? const [Color(0x006F5423), Color(0xFFD0A34B)]
            : const [Color(0xFFD0A34B), Color(0x006F5423)],
      ),
    ),
  );
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.rows});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
      final cacheWidth = (constraints.maxWidth * pixelRatio).round();
      return SizedBox(
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(
                MysticAssets.largeFrameA,
                fit: BoxFit.fill,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Padding(
              // Keep content clear of the ornate top crest and corner flourishes.
              padding: const EdgeInsets.fromLTRB(19, 36, 19, 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: SizedBox.square(
                            dimension: 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFFD8A94B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Hồ Sơ Bản Mệnh',
                            style: TextStyle(
                              color: Color(0xFFF2D89D),
                              fontFamily: 'serif',
                              fontSize: 17,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Cập nhật thông tin để hệ thống Tử Vi tự động an sao và đối chiếu đại hạn.',
                      style: TextStyle(
                        color: Color(0xFFB8B2A5),
                        fontSize: 11.5,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Divider(
                      height: 1,
                      thickness: .7,
                      color: Color(0xFF69552C),
                    ),
                  ),
                  const SizedBox(height: 3),
                  for (var index = 0; index < rows.length; index++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              rows[index].$1,
                              style: const TextStyle(
                                color: Color(0xFFAEB7C2),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rows[index].$2,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: MysticColors.ivory,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != rows.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Divider(height: 1, color: Color(0xFF334354)),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
