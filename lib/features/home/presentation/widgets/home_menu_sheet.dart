import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';

Future<void> showHomeMenuSheet(
  BuildContext context, {
  required bool isAuthenticated,
  required String userName,
  required int coinBalance,
  required VoidCallback onLogin,
  required VoidCallback onProfile,
  required VoidCallback onHoroscope,
  required VoidCallback onSavedCharts,
  required VoidCallback onInterpretation,
  required VoidCallback onDailyFortune,
  required VoidCallback onArticles,
  required VoidCallback onWallet,
  required VoidCallback onPremium,
  required VoidCallback onSettings,
  required VoidCallback onSupport,
  required VoidCallback onPolicy,
  required VoidCallback onLogout,
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Đóng menu',
  barrierColor: const Color(0xB800050C),
  transitionDuration: const Duration(milliseconds: 200),
  pageBuilder: (dialogContext, _, _) => HomeMenuSheet(
    isAuthenticated: isAuthenticated,
    userName: userName,
    coinBalance: coinBalance,
    onLogin: () => _closeThen(dialogContext, onLogin),
    onProfile: () => _closeThen(dialogContext, onProfile),
    onHoroscope: () => _closeThen(dialogContext, onHoroscope),
    onSavedCharts: () => _closeThen(dialogContext, onSavedCharts),
    onInterpretation: () => _closeThen(dialogContext, onInterpretation),
    onDailyFortune: () => _closeThen(dialogContext, onDailyFortune),
    onArticles: () => _closeThen(dialogContext, onArticles),
    onWallet: () => _closeThen(dialogContext, onWallet),
    onPremium: () => _closeThen(dialogContext, onPremium),
    onSettings: () => _closeThen(dialogContext, onSettings),
    onSupport: () => _closeThen(dialogContext, onSupport),
    onPolicy: () => _closeThen(dialogContext, onPolicy),
    onLogout: () => _closeThen(dialogContext, onLogout),
  ),
  transitionBuilder: (_, animation, secondaryAnimation, child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  },
);

void _closeThen(BuildContext dialogContext, VoidCallback action) {
  Navigator.of(dialogContext).pop();
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
}

class HomeMenuSheet extends StatelessWidget {
  const HomeMenuSheet({
    required this.isAuthenticated,
    required this.userName,
    required this.coinBalance,
    required this.onLogin,
    required this.onProfile,
    required this.onHoroscope,
    required this.onSavedCharts,
    required this.onInterpretation,
    required this.onDailyFortune,
    required this.onArticles,
    required this.onWallet,
    required this.onPremium,
    required this.onSettings,
    required this.onSupport,
    required this.onPolicy,
    required this.onLogout,
    super.key,
  });

  final bool isAuthenticated;
  final String userName;
  final int coinBalance;
  final VoidCallback onLogin;
  final VoidCallback onProfile;
  final VoidCallback onHoroscope;
  final VoidCallback onSavedCharts;
  final VoidCallback onInterpretation;
  final VoidCallback onDailyFortune;
  final VoidCallback onArticles;
  final VoidCallback onWallet;
  final VoidCallback onPremium;
  final VoidCallback onSettings;
  final VoidCallback onSupport;
  final VoidCallback onPolicy;
  final VoidCallback onLogout;

  static const _gold = Color(0xFFFFCF58);
  static const _ivory = Color(0xFFFFF0CF);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = (screenWidth * .70).clamp(272.0, 380.0);
    return SafeArea(
      right: false,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: panelWidth,
          height: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A1B2D),
                    Color(0xFF061421),
                    Color(0xFF030B13),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(color: const Color(0xFFC99735), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xAA000000),
                    blurRadius: 12,
                    offset: Offset(5, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(29),
                  bottomRight: Radius.circular(29),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(child: _MenuBackground()),
                    CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _AccountHeader(
                            isAuthenticated: isAuthenticated,
                            userName: userName,
                            coinBalance: coinBalance,
                            onClose: () => Navigator.pop(context),
                            onProfile: isAuthenticated ? onProfile : onLogin,
                            onWallet: onWallet,
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                          sliver: SliverList.list(
                            children: [
                              _MenuRow(
                                icon: Icons.home_rounded,
                                label: 'Trang chủ',
                                selected: true,
                                onTap: () => Navigator.pop(context),
                              ),
                              _MenuRow(
                                icon: Icons.auto_awesome_rounded,
                                label: 'Lập lá số',
                                onTap: onHoroscope,
                              ),
                              _MenuRow(
                                icon: Icons.style_outlined,
                                label: 'Lá số của tôi',
                                onTap: onSavedCharts,
                              ),
                              _MenuRow(
                                icon: Icons.auto_stories_outlined,
                                label: 'Luận giải',
                                onTap: onInterpretation,
                              ),
                              _MenuRow(
                                icon: Icons.calendar_month_outlined,
                                label: 'Vận hạn hôm nay',
                                onTap: onDailyFortune,
                              ),
                              _MenuRow(
                                icon: Icons.newspaper_rounded,
                                label: 'Tin tức',
                                onTap: onArticles,
                              ),
                              _MenuRow(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Ví Xu',
                                trailing: isAuthenticated
                                    ? '${_formatNumber(coinBalance)} Xu'
                                    : null,
                                onTap: onWallet,
                              ),
                              const SizedBox(height: 5),
                              _PremiumRow(onTap: onPremium),
                              const _OrnamentDivider(),
                              _MenuRow(
                                icon: Icons.settings_outlined,
                                label: 'Cài đặt',
                                onTap: onSettings,
                              ),
                              _MenuRow(
                                icon: Icons.support_agent_rounded,
                                label: 'Hỗ trợ',
                                onTap: onSupport,
                              ),
                              const SizedBox(height: 8),
                              _BottomPanel(
                                isAuthenticated: isAuthenticated,
                                onPolicy: onPolicy,
                                onSessionAction: isAuthenticated
                                    ? onLogout
                                    : onLogin,
                              ),
                            ],
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
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.isAuthenticated,
    required this.userName,
    required this.coinBalance,
    required this.onClose,
    required this.onProfile,
    required this.onWallet,
  });

  final bool isAuthenticated;
  final String userName;
  final int coinBalance;
  final VoidCallback onClose;
  final VoidCallback onProfile;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(15, 12, 12, 14),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0x665E4824))),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xB8142B43), Color(0x50101E30), Colors.transparent],
      ),
    ),
    child: Stack(
      children: [
        Row(
          children: [
            InkWell(
              onTap: onProfile,
              customBorder: const CircleBorder(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF1D3A55), Color(0xFF07131F)],
                  ),
                  border: Border.all(color: HomeMenuSheet._gold, width: 2),
                ),
                child: Icon(
                  isAuthenticated
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  color: const Color(0xFFFFDB77),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAuthenticated
                          ? (userName.trim().isEmpty ? 'Thành viên' : userName)
                          : 'Khách hữu duyên',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HomeMenuSheet._ivory,
                        fontFamily: 'serif',
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAuthenticated
                          ? 'Chào mừng trở lại'
                          : 'Khám phá Tử Vi AI',
                      style: const TextStyle(
                        color: Color(0xFFD3B980),
                        fontFamily: 'serif',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 7),
                    InkWell(
                      onTap: isAuthenticated ? onWallet : onProfile,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 112),
                        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                        decoration: BoxDecoration(
                          color: const Color(0xB207111D),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFB98528)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFD99B20),
                              ),
                              child: const Icon(
                                Icons.monetization_on_rounded,
                                size: 17,
                                color: Color(0xFFFFE99D),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                isAuthenticated
                                    ? '${_formatNumber(coinBalance)} Xu'
                                    : 'Đăng nhập',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: HomeMenuSheet._ivory,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFD260),
                              ),
                              child: Icon(
                                isAuthenticated
                                    ? Icons.add_rounded
                                    : Icons.login_rounded,
                                color: const Color(0xFF432C08),
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: onClose,
            customBorder: const CircleBorder(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xB207131F),
                border: Border.all(color: HomeMenuSheet._gold),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: HomeMenuSheet._gold,
                size: 21,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0x995D471B), Color(0x334A3817)],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            border: selected
                ? Border.all(color: const Color(0xFFFFD461), width: 1.1)
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Icon(icon, color: HomeMenuSheet._gold, size: 22),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: HomeMenuSheet._ivory,
                    fontFamily: 'serif',
                    fontSize: selected ? 16.5 : 15.5,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 62),
                  child: Text(
                    trailing!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFD7B35E),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFFFE5A4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PremiumRow extends StatelessWidget {
  const _PremiumRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Ink(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0x99664A14), Color(0x66422E0E), Color(0x152D210E)],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFC18B28), width: .8),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFFD45B),
              size: 26,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Nâng cấp Premium',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFFFFD978),
                  fontFamily: 'serif',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(0xFFFFE5A4)),
          ],
        ),
      ),
    ),
  );
}

class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 11),
    child: Row(
      children: [
        Expanded(child: Divider(color: Color(0xFF765A25), height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: Icon(Icons.auto_awesome, color: Color(0xFFD8A83D), size: 12),
        ),
        Expanded(child: Divider(color: Color(0xFF765A25), height: 1)),
      ],
    ),
  );
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.isAuthenticated,
    required this.onPolicy,
    required this.onSessionAction,
  });

  final bool isAuthenticated;
  final VoidCallback onPolicy;
  final VoidCallback onSessionAction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0x99101F31),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFF8D6725)),
    ),
    child: Column(
      children: [
        _BottomItem(
          icon: Icons.policy_outlined,
          label: 'Chính sách',
          onTap: onPolicy,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 49),
          child: Divider(height: 1, color: Color(0xFF354254)),
        ),
        _BottomItem(
          icon: isAuthenticated ? Icons.logout_rounded : Icons.login_rounded,
          label: isAuthenticated ? 'Đăng xuất' : 'Đăng nhập',
          onTap: onSessionAction,
        ),
      ],
    ),
  );
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Icon(icon, color: HomeMenuSheet._gold, size: 21),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: HomeMenuSheet._ivory,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: HomeMenuSheet._ivory,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MenuBackground extends StatelessWidget {
  const _MenuBackground();

  @override
  Widget build(BuildContext context) {
    // Match HomePage's cache key so the already decoded background is reused
    // instead of keeping a second resized copy in the image cache.
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(1, 854);
    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              MysticAssets.homeBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              cacheWidth: cacheWidth,
              filterQuality: FilterQuality.medium,
            ),
            const ColoredBox(color: Color(0x8F020A13)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, .28, .72, 1],
                  colors: [
                    Color(0x3313293D),
                    Color(0xA305111D),
                    Color(0xBA020A12),
                    Color(0x72071420),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return '${value < 0 ? '-' : ''}$buffer';
}
