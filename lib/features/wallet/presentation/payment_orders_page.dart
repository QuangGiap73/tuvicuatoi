import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../domain/wallet_models.dart';
import 'providers/payment_order_providers.dart';

class PaymentOrdersPage extends ConsumerStatefulWidget {
  const PaymentOrdersPage({super.key});

  @override
  ConsumerState<PaymentOrdersPage> createState() => _PaymentOrdersPageState();
}

class _PaymentOrdersPageState extends ConsumerState<PaymentOrdersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(paymentOrdersControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentOrdersControllerProvider);
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
          const ColoredBox(color: Color(0xC805101D)),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFE5BA50),
        onRefresh: () => ref
            .read(paymentOrdersControllerProvider.notifier)
            .load(force: true),
        child: CustomScrollView(
          key: const PageStorageKey('payment-orders-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 14, 14),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFFFFD66B),
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Lịch Sử Đơn Thanh Toán',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFE5A4),
                                fontFamily: 'serif',
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Đơn mua Xu và gói Hội viên',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
            if (state.isLoading && state.orders.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFE5BA50)),
                ),
              )
            else if (state.error != null && state.orders.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _OrdersMessage(
                  message: state.error!,
                  onRetry: () => ref
                      .read(paymentOrdersControllerProvider.notifier)
                      .load(force: true),
                ),
              )
            else if (state.orders.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _OrdersMessage(
                  message: 'Bạn chưa có đơn thanh toán nào.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                sliver: SliverList.separated(
                  itemCount: state.orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => RepaintBoundary(
                    child: _OrderCard(order: state.orders[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final PaymentOrder order;

  @override
  Widget build(BuildContext context) {
    final success = order.isSuccess;
    final pending = order.isPending;
    final color = success
        ? const Color(0xFF3F9D70)
        : pending
        ? const Color(0xFFD49A25)
        : const Color(0xFFC65353);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E4B8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD3A33B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(
              success
                  ? Icons.check_rounded
                  : pending
                  ? Icons.schedule_rounded
                  : Icons.close_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName.isEmpty
                      ? 'Đơn thanh toán'
                      : order.productName,
                  style: const TextStyle(
                    color: Color(0xFF442911),
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_money(order.amount)} • ${_date(order.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF735B3C),
                    fontSize: 11,
                  ),
                ),
                if (order.orderCode.isNotEmpty)
                  Text(
                    'Mã đơn: ${order.orderCode}',
                    style: const TextStyle(
                      color: Color(0xFF8A704F),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              success
                  ? 'THÀNH CÔNG'
                  : pending
                  ? 'ĐANG CHỜ'
                  : order.status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  const _OrdersMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('THỬ LẠI')),
        ],
      ),
    ),
  );
}

String _money(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return '$buffer VNĐ';
}

String _date(DateTime? value) {
  if (value == null) return 'Không rõ thời gian';
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)} • '
      '${two(local.day)}/${two(local.month)}/${local.year}';
}
