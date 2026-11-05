import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../domain/wallet_models.dart';
import 'providers/payment_order_providers.dart';

const _gold = Color(0xFFE5BA50);
const _paper = Color(0xFFF7E8C2);
const _ink = Color(0xFF432910);

class PaymentOrderDetailPage extends ConsumerWidget {
  const PaymentOrderDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(paymentOrderDetailProvider(orderId));
    return MysticScaffold(
      constrainBody: false,
      background: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Image.asset(
              MysticAssets.homeBackground,
              fit: BoxFit.cover,
              cacheWidth:
                  (MediaQuery.sizeOf(context).width *
                          MediaQuery.devicePixelRatioOf(context))
                      .round()
                      .clamp(1, 1024),
            ),
          ),
          const ColoredBox(color: Color(0xC805101D)),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _gold,
          onRefresh: () async {
            ref.invalidate(paymentOrderDetailProvider(orderId));
            await ref.read(paymentOrderDetailProvider(orderId).future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(onBack: () => _back(context))),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 110),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: detail.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: CircularProgressIndicator(color: _gold),
                        ),
                        error: (error, _) => _ErrorCard(
                          message: _errorMessage(error),
                          onRetry: () => ref.invalidate(
                            paymentOrderDetailProvider(orderId),
                          ),
                        ),
                        data: (order) => _OrderDetailCard(order: order),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoute.paymentOrders);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 14, 14),
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFFFFD66B),
          ),
        ),
        const Expanded(
          child: Column(
            children: [
              Text(
                'Chi Tiết Đơn Thanh Toán',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE5A4),
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Thông tin và trạng thái giao dịch',
                style: TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );
}

class _OrderDetailCard extends StatelessWidget {
  const _OrderDetailCard({required this.order});

  final PaymentOrder order;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(order);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(17, 20, 17, 18),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: .13),
                shape: BoxShape.circle,
                border: Border.all(color: status.color, width: 1.3),
              ),
              child: Icon(status.icon, color: status.color, size: 31),
            ),
            const SizedBox(height: 10),
            Text(
              status.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: status.color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              order.productName.isEmpty ? 'Đơn thanh toán' : order.productName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontFamily: 'serif',
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0x55A87520), height: 1),
            const SizedBox(height: 8),
            _DetailRow(label: 'Mã đơn', value: _value(order.orderCode)),
            _DetailRow(
              label: 'Số tiền',
              value: _money(order.amount),
              strong: true,
            ),
            _DetailRow(
              label: 'Loại sản phẩm',
              value: _productType(order.productType),
            ),
            if (order.coinsGranted > 0)
              _DetailRow(
                label: 'Xu nhận được',
                value: '+${_integer(order.coinsGranted)} Xu',
                valueColor: const Color(0xFF18704A),
              ),
            if (order.coinBalance != null)
              _DetailRow(
                label: 'Số dư sau giao dịch',
                value: '${_integer(order.coinBalance!)} Xu',
              ),
            _DetailRow(label: 'Phương thức', value: _method(order.method)),
            _DetailRow(label: 'Ngày tạo', value: _dateTime(order.createdAt)),
            if (order.paidAt != null)
              _DetailRow(
                label: 'Thanh toán lúc',
                value: _dateTime(order.paidAt),
              ),
            if (order.expiresAt != null && !order.isSuccess)
              _DetailRow(
                label: 'Hết hạn lúc',
                value: _dateTime(order.expiresAt),
              ),
            const SizedBox(height: 8),
            Text(
              order.isPending
                  ? 'Kéo xuống để cập nhật trạng thái mới nhất của đơn.'
                  : 'Thông tin được xác nhận từ hệ thống thanh toán.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7A6242), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool strong;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF806745), fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: valueColor ?? _ink,
              fontSize: strong ? 15 : 12,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 38),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xE50C192B),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _gold),
    ),
    child: Column(
      children: [
        const Icon(Icons.receipt_long_outlined, color: _gold, size: 38),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('THỬ LẠI'),
        ),
      ],
    ),
  );
}

({String label, Color color, IconData icon}) _statusPresentation(
  PaymentOrder order,
) {
  if (order.isSuccess) {
    return (
      label: 'THANH TOÁN THÀNH CÔNG',
      color: const Color(0xFF27865D),
      icon: Icons.check_rounded,
    );
  }
  if (order.isPending) {
    return (
      label: 'ĐANG CHỜ THANH TOÁN',
      color: const Color(0xFFB57812),
      icon: Icons.schedule_rounded,
    );
  }
  return (
    label: order.normalizedStatus == 'EXPIRED'
        ? 'ĐƠN ĐÃ HẾT HẠN'
        : order.normalizedStatus == 'CANCELLED' ||
              order.normalizedStatus == 'CANCELED'
        ? 'ĐƠN ĐÃ HỦY'
        : 'THANH TOÁN KHÔNG THÀNH CÔNG',
    color: const Color(0xFFB53F3F),
    icon: Icons.close_rounded,
  );
}

String _errorMessage(Object error) {
  final text = error.toString().replaceFirst(RegExp(r'^\w*Exception:\s*'), '');
  return text.isEmpty ? 'Không thể tải chi tiết đơn thanh toán.' : text;
}

String _value(String value) => value.trim().isEmpty ? '—' : value.trim();

String _productType(String value) => switch (value.trim().toUpperCase()) {
  'COIN' => 'Gói Xu',
  'MEMBERSHIP' || 'VIP' || 'PREMIUM' => 'Gói hội viên',
  _ => _value(value),
};

String _method(String value) => switch (value.trim().toUpperCase()) {
  'PAYOS' || 'VIETQR' || 'QR' => 'Chuyển khoản VietQR',
  _ => _value(value),
};

String _money(double value) => '${_integer(value.round())} VNĐ';

String _integer(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String _dateTime(DateTime? value) {
  if (value == null) return 'Chưa có thông tin';
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)} • '
      '${two(local.day)}/${two(local.month)}/${local.year}';
}
