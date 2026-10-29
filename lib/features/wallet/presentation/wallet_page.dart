import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../domain/wallet_models.dart';
import 'wallet_controller.dart';

const _gold = Color(0xFFE3B84F);
const _darkGold = Color(0xFF8A5709);
const _ink = Color(0xFF432811);
const _paper = Color(0xFFF7E7BC);

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);
    final info = state.info;
    return MysticScaffold(
      constrainBody: false,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.homeBackground,
            fit: BoxFit.cover,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
          ),
          const ColoredBox(color: Color(0xA8040D19)),
        ],
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: ref.read(walletControllerProvider.notifier).refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(balance: info?.balance)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 105),
              sliver: SliverList.list(
                children: [
                  RepaintBoundary(child: _BalancePanel(balance: info?.balance)),
                  const SizedBox(height: 17),
                  const _SectionTitle(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Bạn có thể dùng Xu để làm gì?',
                  ),
                  const SizedBox(height: 9),
                  const RepaintBoundary(child: _CoinUses()),
                  const SizedBox(height: 15),
                  if (state.isLoading && info == null)
                    const Padding(
                      padding: EdgeInsets.all(60),
                      child: Center(
                        child: CircularProgressIndicator(color: _gold),
                      ),
                    )
                  else if (state.error != null && info == null)
                    _MysticPanel(
                      child: Column(
                        children: [
                          Text(
                            state.error!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: ref
                                .read(walletControllerProvider.notifier)
                                .refresh,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  else if (info != null) ...[
                    RepaintBoundary(
                      child: _CheckInPanel(info: info, state: state),
                    ),
                    const SizedBox(height: 14),
                    RepaintBoundary(
                      child: _MissionPanel(info: info, state: state),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.balance});
  final int? balance;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(15, 8, 15, 5),
    child: Row(
      children: [
        _RoundIcon(
          icon: Icons.chevron_left_rounded,
          onTap: Navigator.of(context).canPop()
              ? () => Navigator.of(context).pop()
              : null,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            children: [
              Text(
                'Ví Xu & Phúc Lộc',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE291),
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                ),
              ),
              Text(
                'Tích lũy Xu để mở khóa luận giải và nhiều tiện ích tâm linh khác',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 10.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xD4283035),
            border: Border.all(color: _gold),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on, color: _gold, size: 16),
              const SizedBox(width: 4),
              Text(
                balance == null ? '—' : _number(balance!),
                style: const TextStyle(
                  color: Color(0xFFFFE3A0),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BalancePanel extends StatelessWidget {
  const _BalancePanel({required this.balance});
  final int? balance;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 210),
    decoration: BoxDecoration(
      color: const Color(0xFFF6E6BC),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black54, blurRadius: 9, offset: Offset(0, 4)),
        BoxShadow(color: Color(0x66F5C657), blurRadius: 6),
      ],
    ),
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              MysticAssets.walletFrame,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              cacheWidth: 1000,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(29, 29, 29, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SỐ DƯ HIỆN TẠI',
                style: TextStyle(
                  color: Color(0xFF806239),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFF1B62F),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      balance == null
                          ? 'Đang tải...'
                          : '${_number(balance!)} Xu',
                      style: const TextStyle(
                        color: Color(0xFFB87313),
                        fontFamily: 'serif',
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.push(AppRoute.paymentOrders),
                  icon: const Icon(Icons.receipt_long_rounded, size: 15),
                  label: const Text('LỊCH SỬ ĐƠN THANH TOÁN'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8A5A12),
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Tài khoản: Thành viên Tử Vi AI',
                style: TextStyle(color: Color(0xFF735B3C), fontSize: 11),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _GoldButton(
                      icon: Icons.monetization_on_outlined,
                      label: 'NẠP THÊM XU',
                      onTap: () => context.push(AppRoute.coinPackages),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GoldButton(
                      dark: true,
                      icon: Icons.history_rounded,
                      label: 'NHẬT KÝ XU',
                      onTap: () => context.push(AppRoute.coinTransactions),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CoinUses extends StatelessWidget {
  const _CoinUses();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 7.0;
      final width = (constraints.maxWidth - gap * 2) / 3;
      return SizedBox(
        height: 145,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _UseCard(
              width: width,
              icon: Icons.menu_book_rounded,
              title: 'Mở luận giải',
              description: 'Mở khóa chi tiết từng cung và đại vận.',
            ),
            const SizedBox(width: gap),
            _UseCard(
              width: width,
              icon: Icons.chat_bubble_rounded,
              title: 'Hỏi đáp AI',
              description: 'Đàm đạo chuyên sâu cùng Trợ lý Tử Vi.',
            ),
            const SizedBox(width: gap),
            _UseCard(
              width: width,
              icon: Icons.inventory_2_rounded,
              title: 'Lưu lá số',
              description: 'Lưu trữ lá số của bạn và người thân.',
            ),
          ],
        ),
      );
    },
  );
}

class _UseCard extends StatelessWidget {
  const _UseCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
  });
  final double width;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6E6BC),
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.asset(
              MysticAssets.walletFrame,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
              cacheWidth: 320,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2B654),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x55A56A08), blurRadius: 4),
                    ],
                  ),
                  child: Icon(icon, color: const Color(0xFF5E3B08), size: 17),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: 'serif',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6D573D),
                    fontSize: 9,
                    height: 1.25,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8C36B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Theo giá hệ thống',
                    maxLines: 1,
                    style: TextStyle(
                      color: Color(0xFF704309),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CheckInPanel extends ConsumerWidget {
  const _CheckInPanel({required this.info, required this.state});
  final EarnCoinsInfo info;
  final WalletState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = state.activeActions.contains('checkin');
    return _MysticPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _GlowIcon(icon: Icons.calendar_month_rounded),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điểm danh hằng ngày nhận Xu',
                      style: TextStyle(
                        color: Color(0xFFFFE6A6),
                        fontFamily: 'serif',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Chuỗi ${info.streakDays} ngày · Phần thưởng do hệ thống cung cấp',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.info_outline, color: Colors.white60, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: info.checkInDays
                  .map(
                    (day) => _CheckInDayTile(
                      day: day,
                      completed: day.day <= info.streakDays,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: _GoldButton(
              icon: info.hasCheckedInToday
                  ? Icons.check_circle
                  : Icons.touch_app_rounded,
              label: info.hasCheckedInToday
                  ? 'ĐÃ ĐIỂM DANH HÔM NAY'
                  : busy
                  ? 'ĐANG ĐIỂM DANH...'
                  : 'ĐIỂM DANH HÔM NAY',
              onTap: info.hasCheckedInToday || busy
                  ? null
                  : () => _checkIn(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInDayTile extends StatelessWidget {
  const _CheckInDayTile({required this.day, required this.completed});
  final CheckInDay day;
  final bool completed;

  @override
  Widget build(BuildContext context) => Container(
    width: 55,
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: completed ? const Color(0xFF0D5A58) : const Color(0xFFF8E8BE),
      border: Border.all(color: _gold),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
    ),
    child: Column(
      children: [
        Text(
          'Ngày ${day.day}',
          style: TextStyle(
            color: completed ? Colors.white : _ink,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Icon(
          completed
              ? Icons.check_circle
              : day.day == 7
              ? Icons.card_giftcard_rounded
              : Icons.monetization_on,
          color: completed ? const Color(0xFF45E1C3) : const Color(0xFFE6A71D),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          '+${day.rewardCoins} Xu',
          style: TextStyle(
            color: completed ? const Color(0xFF48F0D3) : _darkGold,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _MissionPanel extends StatelessWidget {
  const _MissionPanel({required this.info, required this.state});
  final EarnCoinsInfo info;
  final WalletState state;

  @override
  Widget build(BuildContext context) => _MysticPanel(
    child: Column(
      children: [
        const Row(
          children: [
            _GlowIcon(icon: Icons.track_changes_rounded),
            SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhiệm vụ kiếm Xu',
                    style: TextStyle(
                      color: Color(0xFFFFE6A6),
                      fontFamily: 'serif',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Hoàn thành nhiệm vụ để tích lũy thêm Xu miễn phí',
                    style: TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (info.missions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Backend chưa cung cấp nhiệm vụ.',
              style: TextStyle(color: Colors.white60),
            ),
          )
        else
          ...info.missions.map(
            (mission) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MissionTile(mission: mission, state: state),
            ),
          ),
      ],
    ),
  );
}

class _MissionTile extends ConsumerWidget {
  const _MissionTile({required this.mission, required this.state});
  final CoinMission mission;
  final WalletState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionKey = mission.canVerify
        ? 'claim:${mission.code}'
        : 'start:${mission.code}';
    final busy = state.activeActions.contains(actionKey);
    final disabled =
        mission.isCompleted ||
        (mission.isVerifying && !mission.canVerify) ||
        busy;
    final label = mission.isCompleted
        ? 'Đã hoàn thành'
        : mission.canVerify
        ? 'Nhận thưởng'
        : mission.isVerifying
        ? 'Đang xác minh'
        : 'Tham gia ngay';
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
      decoration: _paperDecoration(radius: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF261B08),
              borderRadius: BorderRadius.circular(9),
              boxShadow: const [BoxShadow(color: _gold, blurRadius: 3)],
            ),
            child: Icon(
              _missionIcon(mission.actionType),
              color: const Color(0xFFFFDF7E),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: 'serif',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mission.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF725A3B),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3C861),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  '+${mission.rewardCoins} Xu',
                  style: const TextStyle(
                    color: _darkGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 28,
                child: FilledButton(
                  onPressed: disabled
                      ? null
                      : () => _missionAction(context, ref, mission),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4B2E12),
                    foregroundColor: const Color(0xFFFFE8AD),
                    disabledBackgroundColor: const Color(0xFF9A8C72),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    busy ? 'Đang xử lý...' : label,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MysticPanel extends StatelessWidget {
  const _MysticPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xE50A1726),
      border: Border.all(color: _gold, width: 1.2),
      borderRadius: BorderRadius.circular(13),
      boxShadow: const [
        BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFFFFD96D), size: 18),
      const SizedBox(width: 7),
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFFE6A6),
          fontFamily: 'serif',
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(width: 9),
      const Expanded(child: Divider(color: Color(0x998E691F))),
    ],
  );
}

class _GlowIcon extends StatelessWidget {
  const _GlowIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: const Color(0xFF112437),
      border: Border.all(color: _gold),
      borderRadius: BorderRadius.circular(9),
      boxShadow: const [BoxShadow(color: _gold, blurRadius: 7)],
    ),
    child: Icon(icon, color: const Color(0xFFFFD86C), size: 20),
  );
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dark = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool dark;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 16),
    label: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'serif',
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    style: FilledButton.styleFrom(
      backgroundColor: dark ? const Color(0xFF4B2E12) : const Color(0xFFB4780B),
      foregroundColor: const Color(0xFFFFE9AD),
      disabledBackgroundColor: const Color(0xFF9A8C72),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
  );
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        color: const Color(0xB20A1623),
        shape: BoxShape.circle,
        border: Border.all(color: _gold),
      ),
      child: Icon(icon, color: const Color(0xFFFFDA74)),
    ),
  );
}

Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
  final message = await ref.read(walletControllerProvider.notifier).checkIn();
  if (!context.mounted) return;
  _showMessage(context, message ?? ref.read(walletControllerProvider).error);
}

Future<void> _missionAction(
  BuildContext context,
  WidgetRef ref,
  CoinMission mission,
) async {
  final controller = ref.read(walletControllerProvider.notifier);
  if (mission.canVerify) {
    final message = await controller.claimMission(mission);
    if (!context.mounted) return;
    _showMessage(context, message ?? ref.read(walletControllerProvider).error);
    return;
  }
  final message = await controller.startMission(mission);
  if (!context.mounted) return;
  if (message == null) {
    _showMessage(context, ref.read(walletControllerProvider).error);
    return;
  }
  if (mission.actionType == 'NAVIGATE_CREATE') {
    context.go(AppRoute.horoscope);
    return;
  }
  if (mission.actionType == 'NAVIGATE_PROFILE') {
    context.go(AppRoute.profile);
    return;
  }
  final uri = Uri.tryParse(mission.targetUrl);
  if (uri == null ||
      !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      _showMessage(context, 'Không thể mở liên kết nhiệm vụ.');
    }
    return;
  }
  await controller.recordMissionAction(mission);
}

void _showMessage(BuildContext context, String? message) {
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

IconData _missionIcon(String type) => switch (type) {
  'NAVIGATE_CREATE' => Icons.auto_awesome,
  'NAVIGATE_PROFILE' => Icons.person_outline,
  'READ_NEWS' => Icons.menu_book_outlined,
  'SHARE_REFERRAL' => Icons.group_add_outlined,
  'FOLLOW_TIKTOK' => Icons.play_circle_outline,
  _ => Icons.groups_rounded,
};

BoxDecoration _paperDecoration({required double radius}) => BoxDecoration(
  color: _paper,
  border: Border.all(color: const Color(0xFFCB9130), width: 1.3),
  borderRadius: BorderRadius.circular(radius),
  boxShadow: const [
    BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x55F5C657), blurRadius: 5),
  ],
);

String _number(int value) {
  final text = value.abs().toString();
  final output = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) output.write('.');
    output.write(text[index]);
  }
  return '${value < 0 ? '-' : ''}$output';
}
