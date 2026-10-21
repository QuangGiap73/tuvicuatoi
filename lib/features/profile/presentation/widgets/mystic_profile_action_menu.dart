import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../../../core/theme/mystic_colors.dart';

class MysticProfileActionMenu extends StatelessWidget {
  const MysticProfileActionMenu({
    required this.isPremium,
    required this.onUpgradePressed,
    required this.onPersonalProfilePressed,
    required this.onChartHistoryPressed,
    required this.onAiHistoryPressed,
    required this.onTopUpPressed,
    required this.onMembershipPressed,
    required this.onSettingsPressed,
    required this.onHelpPressed,
    super.key,
  });

  final bool isPremium;
  final VoidCallback onUpgradePressed;
  final VoidCallback onPersonalProfilePressed;
  final VoidCallback onChartHistoryPressed;
  final VoidCallback onAiHistoryPressed;
  final VoidCallback onTopUpPressed;
  final VoidCallback onMembershipPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onHelpPressed;

  static const _gold = Color(0xFFD8AC52);
  static const _text = Color(0xFFD9DDE3);
  static const _divider = Color(0xFF1D2B3A);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (!isPremium) ...[
        _buildPremiumBanner(context),
        const SizedBox(height: 9),
      ],
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xD907111D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1B2B3A), width: .8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              icon: Icons.person_rounded,
              label: 'Hồ sơ bản mệnh',
              onPressed: onPersonalProfilePressed,
            ),
            _buildMenuItem(
              icon: Icons.article_outlined,
              label: 'Lịch sử lá số',
              onPressed: onChartHistoryPressed,
            ),
            _buildMenuItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Lịch sử trò chuyện AI',
              onPressed: onAiHistoryPressed,
            ),
            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Nạp Xu',
              onPressed: onTopUpPressed,
            ),
            _buildMenuItem(
              icon: Icons.workspace_premium_outlined,
              label: 'Gói thành viên',
              onPressed: onMembershipPressed,
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              label: 'Cài đặt',
              onPressed: onSettingsPressed,
            ),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              label: 'Trợ giúp & Hỗ trợ',
              onPressed: onHelpPressed,
              showDivider: false,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildPremiumBanner(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(13),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onUpgradePressed,
      child: SizedBox(
        width: double.infinity,
        height: 72,
        child: Image.asset(
          MysticAssets.profilePremiumUpgradeBanner,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          cacheWidth: 900,
          filterQuality: FilterQuality.medium,
        ),
      ),
    ),
  );

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool showDivider = true,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Icon(icon, size: 18, color: _gold),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: MysticColors.paleGold.withValues(alpha: .62),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (showDivider)
        const Padding(
          padding: EdgeInsets.only(left: 45),
          child: Divider(height: 1, thickness: .7, color: _divider),
        ),
    ],
  );
}
