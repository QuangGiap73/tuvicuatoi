import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/golden_button.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'controllers/avatar_update_controller.dart';
import 'providers/profile_providers.dart';
import 'widgets/avatar_picker_sheet.dart';
import 'widgets/mystic_profile_action_menu.dart';
import 'widgets/mystic_profile_header_card.dart';
import 'widgets/profile_mystic_app_bar.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentProfileProvider);
    final avatarState = ref.watch(avatarUpdateControllerProvider);
    final mediaQuery = MediaQuery.of(context);
    final backgroundCacheWidth =
        (mediaQuery.size.width * mediaQuery.devicePixelRatio).round();
    return MysticScaffold(
      extendBodyBehindAppBar: true,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.profilePageBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            cacheWidth: backgroundCacheWidth,
            filterQuality: FilterQuality.medium,
          ),
          const ColoredBox(color: Color(0x7A020812)),
        ],
      ),
      appBar: ProfileMysticAppBar(
        onBackPressed: () => context.go(AppRoute.home),
        onSettingsPressed: () => context.push(AppRoute.accountSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          MysticSpacing.md,
          4,
          MysticSpacing.md,
          MysticSpacing.md,
        ),
        children: [
          MysticProfileHeaderCard(
            userName: user?.fullName ?? '',
            avatarUrl: user?.avatarUrl,
            isPremium: user?.isPremium ?? false,
            packageName: user?.packageName,
            coinBalance: user?.coinBalance ?? 0,
            savedChartsCount: user?.savedChartsCount ?? 0,
            aiQuestionsLeft: user?.dailyAiQuestionsLeft ?? 0,
            avatarPreviewPath: avatarState.previewPath,
            isUpdatingAvatar: avatarState.isBusy,
            onAvatarPressed: () => _changeAvatar(context, ref),
          ),
          const SizedBox(height: MysticSpacing.md),
          MysticProfileActionMenu(
            isPremium: user?.isPremium ?? false,
            onUpgradePressed: () =>
                _showComingSoon(context, 'Nâng cấp Premium'),
            onPersonalProfilePressed: () =>
                context.push(AppRoute.personalProfile),
            onChartHistoryPressed: () => context.push(AppRoute.myCharts),
            onAiHistoryPressed: () =>
                _showComingSoon(context, 'Lịch sử trò chuyện AI'),
            onTopUpPressed: () => context.go(AppRoute.wallet),
            onMembershipPressed: () =>
                _showComingSoon(context, 'Gói thành viên'),
            onSettingsPressed: () => context.push(AppRoute.accountSettings),
            onHelpPressed: () => _showComingSoon(context, 'Trợ giúp & Hỗ trợ'),
          ),
          const SizedBox(height: MysticSpacing.lg),
          GoldenButton(
            label: 'Đăng xuất',
            icon: Icons.logout,
            expanded: true,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$feature sẽ được hoàn thiện sau.')),
      );

  Future<void> _changeAvatar(BuildContext context, WidgetRef ref) async {
    final source = await showAvatarPickerSheet(context);
    if (source == null || !context.mounted) return;
    final success = await ref
        .read(avatarUpdateControllerProvider.notifier)
        .selectAndUpload(source);
    if (!context.mounted) return;
    final state = ref.read(avatarUpdateControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Cập nhật ảnh đại diện thành công.'
              : state.errorMessage ?? 'Không thể cập nhật ảnh đại diện.',
        ),
      ),
    );
  }
}
