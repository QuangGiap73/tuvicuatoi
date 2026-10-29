import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/wallet_models.dart';
import 'providers/top_up_providers.dart';
import 'providers/payment_order_providers.dart';
import 'state/top_up_state.dart';
import 'widgets/payment_checkout_dialog.dart';
import 'widgets/payment_status_dialog.dart';
import 'widgets/top_up_header.dart';
import 'widgets/top_up_tabs.dart';

const _gold = Color(0xFFE5BA50);
const _paper = Color(0xFFF7E8C2);
const _ink = Color(0xFF442911);

class CoinPackagesPage extends ConsumerWidget {
  const CoinPackagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(topUpTabProvider);
    final isLoading = ref.watch(topUpLoadingProvider);
    final error = ref.watch(topUpErrorProvider);
    final coinPackages = ref.watch(coinPackagesProvider);
    final memberships = ref.watch(membershipPackagesProvider);
    final balance = ref.watch(
      authControllerProvider.select(
        (value) => value.asData?.value?.user.coinBalance,
      ),
    );
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
          const ColoredBox(color: Color(0xB5040E1B)),
        ],
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: ref.read(topUpControllerProvider.notifier).load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 110),
          children: [
            TopUpHeader(balance: balance),
            const SizedBox(height: 16),
            TopUpTabs(selectedTab: selectedTab),
            const SizedBox(height: 19),
            if (isLoading && coinPackages.isEmpty)
              const Padding(
                padding: EdgeInsets.all(80),
                child: Center(child: CircularProgressIndicator(color: _gold)),
              )
            else if (error != null &&
                coinPackages.isEmpty &&
                memberships.isEmpty)
              _ErrorPanel(message: error)
            else if (selectedTab == TopUpTab.coins)
              _CoinPackageSection(packages: coinPackages)
            else
              _MembershipSection(packages: memberships),
          ],
        ),
      ),
    );
  }
}

// TODO(wallet-cleanup): remove after the extracted header is visually signed off.
// ignore: unused_element
class _TopUpHeader extends StatelessWidget {
  const _TopUpHeader({required this.balance});
  final int? balance;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xB20A1623),
                shape: BoxShape.circle,
                border: Border.all(color: _gold),
              ),
              child: const Icon(Icons.chevron_left, color: Color(0xFFFFDD77)),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Nạp Xu & Gói Hội Viên',
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xFFFFE39A),
                  fontFamily: 'serif',
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xD4283035),
              border: Border.all(color: _gold),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: _gold, size: 14),
                const SizedBox(width: 4),
                Text(
                  balance == null ? '—' : _number(balance!),
                  style: const TextStyle(
                    color: Color(0xFFFFE3A0),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 11),
      const Row(
        children: [
          Expanded(child: Divider(color: Color(0x558F6A22))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.auto_awesome, color: Color(0xFFFFD96B), size: 17),
          ),
          Expanded(child: Divider(color: Color(0x558F6A22))),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Nạp Xu để mở khóa luận giải, hỏi đáp AI\nhoặc nâng cấp Hội Viên để nhận thêm đặc quyền',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
      ),
    ],
  );
}

// TODO(wallet-cleanup): remove after the extracted tabs are visually signed off.
// ignore: unused_element
class _PackageTabs extends ConsumerWidget {
  const _PackageTabs({required this.selectedTab});
  final TopUpTab selectedTab;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xE6081524),
      border: Border.all(color: const Color(0xFF9B7425)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        _TabButton(
          icon: Icons.monetization_on_rounded,
          label: 'Gói Mua Xu',
          selected: selectedTab == TopUpTab.coins,
          onTap: () => ref
              .read(topUpControllerProvider.notifier)
              .selectTab(TopUpTab.coins),
        ),
        _TabButton(
          icon: Icons.workspace_premium_rounded,
          label: 'Gói Hội Viên',
          selected: selectedTab == TopUpTab.membership,
          onTap: () => ref
              .read(topUpControllerProvider.notifier)
              .selectTab(TopUpTab.membership),
        ),
      ],
    ),
  );
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: selected ? const Color(0xFFFFD66B) : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: selected ? _ink : Colors.white70),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? _ink : Colors.white70,
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CoinPackageSection extends StatelessWidget {
  const _CoinPackageSection({required this.packages});
  final List<CoinPackage> packages;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionHeading(
        icon: Icons.monetization_on_rounded,
        title: 'Chọn gói Xu phù hợp với bạn',
        description: 'Giá và số Xu do hệ thống cung cấp',
      ),
      const SizedBox(height: 12),
      if (packages.isEmpty)
        const _EmptyPanel(text: 'Backend chưa cung cấp gói Xu hợp lệ.')
      else
        SizedBox(
          // The package name may wrap to two lines. Keep enough vertical room
          // for the bonus and price rows instead of relying on a tight card.
          height: 344,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            cacheExtent: 500,
            itemCount: packages.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, index) => RepaintBoundary(
              child: _CoinPackageCard(package: packages[index]),
            ),
          ),
        ),
    ],
  );
}

class _CoinPackageCard extends ConsumerWidget {
  const _CoinPackageCard({required this.package});
  final CoinPackage package;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(productCreatingProvider(package.id));
    final availableWidth = MediaQuery.sizeOf(context).width - 28;
    final cardWidth = ((availableWidth - 10) / 2).clamp(156.0, 180.0);
    return SizedBox(
      width: cardWidth,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MysticAssets.walletFrame,
              fit: BoxFit.fill,
              cacheWidth: 500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
            child: Column(
              children: [
                if (package.badgeLabel.isNotEmpty)
                  _Badge(label: package.badgeLabel),
                const SizedBox(height: 5),
                Text(
                  package.name.toUpperCase(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0x55E0AF3B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCB8E20)),
                  ),
                  child: Icon(
                    package.iconName.toLowerCase().contains('crown')
                        ? Icons.workspace_premium
                        : package.iconName.toLowerCase().contains('spark')
                        ? Icons.auto_awesome
                        : Icons.savings_rounded,
                    color: const Color(0xFF9A5C08),
                    size: 38,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_number(package.totalCoins)} Xu',
                  style: const TextStyle(
                    color: Color(0xFF612F18),
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (package.bonusCoins > 0)
                  Text(
                    'Tặng ${_number(package.bonusCoins)} Xu',
                    style: const TextStyle(
                      color: Color(0xFF07836B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                const SizedBox(height: 7),
                _PriceLabel(
                  price: package.price,
                  original: package.originalPrice,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _BuyButton(
                    label: busy ? 'ĐANG TẠO ĐƠN...' : 'NẠP NGAY',
                    onTap: busy
                        ? null
                        : () => _createOrder(
                            context,
                            ref,
                            productId: package.id,
                            productType: 'COIN',
                            productName: package.name,
                            amount: package.price,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipSection extends StatelessWidget {
  const _MembershipSection({required this.packages});
  final List<MembershipPackage> packages;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionHeading(
        icon: Icons.workspace_premium_rounded,
        title: 'Khám phá các gói Hội Viên',
        description: 'Nâng cấp trải nghiệm và nhận thêm đặc quyền',
      ),
      const SizedBox(height: 12),
      if (packages.isEmpty)
        const _EmptyPanel(text: 'Backend chưa cung cấp gói Hội Viên.')
      else
        SizedBox(
          // Benefits are supplied by the backend and may contain five rows.
          // A taller viewport prevents the action button from escaping the
          // decorative card on compact phones.
          height: 410,
          child: PageView.builder(
            padEnds: true,
            itemCount: packages.length,
            physics: const PageScrollPhysics(),
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: RepaintBoundary(
                child: _MembershipCard(package: packages[index]),
              ),
            ),
          ),
        ),
    ],
  );
}

class _MembershipCard extends ConsumerWidget {
  const _MembershipCard({required this.package});
  final MembershipPackage package;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(productCreatingProvider(package.id));
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 16, 13, 14),
        decoration: BoxDecoration(
          color: _paper,
          border: Border.all(
            color: package.isRecommended ? const Color(0xFFD33C28) : _gold,
            width: package.isRecommended ? 2 : 1.2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
        ),
        child: Column(
          children: [
            if (package.badgeLabel.isNotEmpty)
              _Badge(label: package.badgeLabel),
            const SizedBox(height: 6),
            Icon(
              package.isRecommended
                  ? Icons.workspace_premium
                  : Icons.auto_awesome,
              color: const Color(0xFFAE710D),
              size: 32,
            ),
            const SizedBox(height: 5),
            Text(
              package.name.toUpperCase(),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontFamily: 'serif',
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              package.tagline,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF735C40), fontSize: 10),
            ),
            const SizedBox(height: 9),
            if (package.isFree)
              const Text(
                'MIỄN PHÍ',
                style: TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              )
            else
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${_money(package.price)} / ${package.periodLabel}',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF762A1A),
                    fontFamily: 'serif',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            _Benefit(text: 'Lưu tối đa ${package.maxSavedCharts} lá số'),
            _Benefit(text: '${package.aiDailyLimit} câu hỏi AI mỗi ngày'),
            if (package.coinsGranted > 0)
              _Benefit(text: 'Tặng ${_number(package.coinsGranted)} Xu'),
            if (package.hasAiChatHistory)
              const _Benefit(text: 'Lưu lịch sử AI Chat'),
            if (package.hasPriorityServer)
              const _Benefit(text: 'Ưu tiên máy chủ cao cấp'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: _BuyButton(
                label: package.isFree
                    ? 'GÓI HIỆN TẠI'
                    : busy
                    ? 'ĐANG TẠO ĐƠN...'
                    : 'XEM CHI TIẾT',
                onTap: package.isFree || busy
                    ? null
                    : () => _createOrder(
                        context,
                        ref,
                        productId: package.id,
                        productType: 'PREMIUM',
                        productName: package.name,
                        amount: package.price,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFFFFD66B), size: 29),
      const SizedBox(width: 9),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFE5A4),
                fontFamily: 'serif',
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              description,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFB44918),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.price, required this.original});
  final double price;
  final double original;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (original > price)
        Text(
          _money(original),
          style: const TextStyle(
            color: Color(0xFF927D5E),
            fontSize: 9,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      Text(
        _money(price),
        style: const TextStyle(
          color: _ink,
          fontFamily: 'serif',
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFFB57A12), size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: _ink, fontSize: 10.5),
          ),
        ),
      ],
    ),
  );
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onTap,
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF2F1D09),
      foregroundColor: const Color(0xFFFFE6A3),
      disabledBackgroundColor: const Color(0xFF99896A),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
    child: FittedBox(
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'serif',
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _ErrorPanel extends ConsumerWidget {
  const _ErrorPanel({required this.message});
  final String message;
  @override
  Widget build(BuildContext context, WidgetRef ref) => _EmptyPanel(
    text: message,
    action: TextButton(
      onPressed: ref.read(topUpControllerProvider.notifier).load,
      child: const Text('Thử lại'),
    ),
  );
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.text, this.action});
  final String text;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xD9081625),
      border: Border.all(color: const Color(0xFF9A7427)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        ?action,
      ],
    ),
  );
}

Future<void> _createOrder(
  BuildContext context,
  WidgetRef ref, {
  required String productId,
  required String productType,
  required String productName,
  required double amount,
}) async {
  final checkout = await showPaymentCheckoutDialog(
    context: context,
    productName: productName,
    amount: amount,
    featureKey: productType == 'COIN' ? 'COIN_PACKAGE' : 'PREMIUM_PACKAGE',
    onValidateVoucher: ref
        .read(topUpControllerProvider.notifier)
        .validateVoucher,
  );
  if (checkout == null || !context.mounted) return;
  final result = await ref
      .read(topUpControllerProvider.notifier)
      .createOrder(
        productId: productId,
        productType: productType,
        voucherCode: checkout.voucherCode,
      );
  if (!context.mounted) return;
  if (result == null) {
    final error = ref.read(topUpControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
    return;
  }
  final uri = Uri.tryParse(result.checkoutUrl);
  ref.read(paymentOrderControllerProvider.notifier).track(result);
  if (uri == null ||
      !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ref.read(paymentOrderControllerProvider.notifier).clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở trang thanh toán PayOS.')),
      );
    }
    return;
  }
  if (context.mounted) await showPaymentStatusDialog(context);
}

String _money(double value) => '${_number(value.round())}đ';

String _number(int value) {
  final text = value.abs().toString();
  final output = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) output.write('.');
    output.write(text[index]);
  }
  return '${value < 0 ? '-' : ''}$output';
}
