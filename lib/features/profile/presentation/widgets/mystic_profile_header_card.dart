import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../../../core/theme/mystic_colors.dart';

class MysticProfileHeaderCard extends StatelessWidget {
  const MysticProfileHeaderCard({
    required this.userName,
    required this.avatarUrl,
    required this.isPremium,
    required this.packageName,
    required this.coinBalance,
    required this.savedChartsCount,
    required this.aiQuestionsLeft,
    super.key,
  });

  final String userName;
  final String? avatarUrl;
  final bool isPremium;
  final String? packageName;
  final int coinBalance;
  final int savedChartsCount;
  final int aiQuestionsLeft;

  static const _gold = Color(0xFFD6A94D);
  static const _ivory = Color(0xFFF6F0DF);
  static const _muted = Color(0xFFA9AFB9);

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFF061321),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x59000000),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
        BoxShadow(color: Color(0x1FD6A94D), blurRadius: 7),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          left: -7,
          top: -6,
          right: -7,
          bottom: -6,
          child: Image.asset(
            MysticAssets.profileCardBackground,
            fit: BoxFit.fill,
            cacheWidth: 725,
            cacheHeight: 275,
            filterQuality: FilterQuality.medium,
          ),
        ),
        Positioned(
          right: 10,
          top: 7,
          width: 82,
          height: 76,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0, .68, 1],
            ).createShader(bounds),
            child: Image.asset(
              MysticAssets.profileMaster,
              fit: BoxFit.cover,
              alignment: const Alignment(.22, -.9),
              cacheWidth: 164,
              cacheHeight: 152,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIdentitySection(context),
            Divider(
              height: 1,
              thickness: .7,
              color: _gold.withValues(alpha: .35),
            ),
            _buildStatsSection(context),
          ],
        ),
      ],
    ),
  );

  Widget _buildIdentitySection(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 88),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 102, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(context),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.trim().isEmpty ? 'Tài khoản Tử Vi' : userName.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ivory,
                    fontSize: 15,
                    height: 1.18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                _buildMembershipBadge(context),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAvatar(BuildContext context) {
    final url = avatarUrl?.trim();
    final canLoadNetwork =
        url != null &&
        url.isNotEmpty &&
        Uri.tryParse(url)?.hasAbsolutePath == true &&
        !url.toLowerCase().endsWith('.svg');
    final fallback = Container(
      color: const Color(0xFF13283A),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: const TextStyle(
          color: MysticColors.paleGold,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return SizedBox.square(
      dimension: 58,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: ClipOval(
              child: canLoadNetwork
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      cacheWidth: 144,
                      cacheHeight: 144,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (_, _, _) => fallback,
                    )
                  : fallback,
            ),
          ),
          IgnorePointer(
            child: Image.asset(
              MysticAssets.profileAvatarFrame,
              fit: BoxFit.contain,
              cacheWidth: 144,
              cacheHeight: 144,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipBadge(BuildContext context) {
    final fallbackName = isPremium ? 'Thành viên Premium' : 'Thành viên Free';
    final label = packageName?.trim().isNotEmpty == true
        ? packageName!.trim()
        : fallbackName;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 155),
        padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPremium
                ? const [Color(0xFF9B6815), Color(0xFF50350E)]
                : const [Color(0xFF3B4652), Color(0xFF222D38)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPremium
                ? const Color(0xFFE6BD62)
                : const Color(0xFF687581),
            width: .7,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPremium) ...[
              Image.asset(
                MysticAssets.profilePremiumCrown,
                width: 14,
                height: 14,
                cacheWidth: 36,
                cacheHeight: 36,
              ),
              const SizedBox(width: 3),
            ] else ...[
              const Icon(Icons.person_outline_rounded, size: 12, color: _muted),
              const SizedBox(width: 3),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPremium ? const Color(0xFFFFE3A0) : _ivory,
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStat(value: _formatNumber(coinBalance), label: 'Xu'),
        _buildVerticalDivider(),
        _buildStat(value: _formatNumber(savedChartsCount), label: 'Lá số'),
        _buildVerticalDivider(),
        _buildStat(value: _formatNumber(aiQuestionsLeft), label: 'Lượt hỏi AI'),
      ],
    ),
  );

  Widget _buildStat({required String value, required String label}) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: _ivory,
                fontSize: 18,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 11, height: 1.2),
          ),
        ],
      ),
    ),
  );

  Widget _buildVerticalDivider() => Container(
    width: .7,
    margin: const EdgeInsets.symmetric(vertical: 8),
    color: _gold.withValues(alpha: .24),
  );

  String get _initial {
    final value = userName.trim();
    return value.isEmpty ? 'T' : value.characters.first.toUpperCase();
  }

  String _formatNumber(int value) {
    final digits = value.clamp(0, 999999999).toString();
    return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }
}
