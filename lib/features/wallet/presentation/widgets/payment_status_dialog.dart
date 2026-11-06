import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../domain/wallet_models.dart';
import '../providers/payment_order_providers.dart';

const _gold = Color(0xFFFFD56A);
const _muted = Color(0xFFB8C0CC);

Future<void> showPaymentStatusDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  barrierColor: const Color(0xC9000000),
  builder: (_) => const _PaymentStatusDialog(),
);

class _PaymentStatusDialog extends ConsumerStatefulWidget {
  const _PaymentStatusDialog();

  @override
  ConsumerState<_PaymentStatusDialog> createState() =>
      _PaymentStatusDialogState();
}

class _PaymentStatusDialogState extends ConsumerState<_PaymentStatusDialog>
    with WidgetsBindingObserver {
  bool _checkedOnResume = false;
  bool _invalidatedHistory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _checkedOnResume = false;
    if (state == AppLifecycleState.resumed && !_checkedOnResume) {
      _checkedOnResume = true;
      ref.read(paymentOrderControllerProvider.notifier).check();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentOrderControllerProvider);
    final order = state.order;
    final success = order?.isSuccess == true;
    final terminal = order?.isTerminal == true;
    final pending = !success && !terminal;
    if (success && !_invalidatedHistory) {
      _invalidatedHistory = true;
      Future.microtask(() => ref.invalidate(paymentOrdersControllerProvider));
    }

    final media = MediaQuery.of(context);
    final dpr = media.devicePixelRatio;
    final modalWidth = (media.size.width - 36).clamp(1.0, 440.0);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: media.size.width < 360 ? 10 : 18,
        vertical: 18,
      ),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: media.size.height * .86,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: Image.asset(
                      MysticAssets.paymentBackground,
                      fit: BoxFit.fill,
                      cacheWidth: (modalWidth * dpr).round().clamp(1, 650),
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (success || terminal) ...[
                        _StatusEmblem(success: success, terminal: terminal),
                        const SizedBox(height: 10),
                      ] else
                        const SizedBox(height: 90),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          success
                              ? 'Thanh toán thành công'
                              : terminal
                              ? 'Đơn hàng đã kết thúc'
                              : 'Đang chờ thanh toán',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFFE7A8),
                            fontFamily: 'serif',
                            fontSize: 20.5,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (pending) ...[
                        const SizedBox(height: 10),
                        _ExpiryBadge(order: order),
                      ],
                      if (pending && state.qrCode.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _QrCard(data: state.qrCode),
                      ],
                      const SizedBox(height: 12),
                      if (order != null) _OrderSummary(order: order),
                      if (state.error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFF8A8A),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 11),
                      if (pending &&
                          Uri.tryParse(state.checkoutUrl)?.hasScheme == true)
                        _PrimaryPayOsButton(url: state.checkoutUrl),
                      if (pending) ...[
                        const SizedBox(height: 8),
                        _CheckPaymentButton(isChecking: state.isChecking),
                        const SizedBox(height: 1),
                        TextButton.icon(
                          onPressed: state.isChecking
                              ? null
                              : ref
                                    .read(
                                      paymentOrderControllerProvider.notifier,
                                    )
                                    .check,
                          icon: const Icon(Icons.refresh_rounded, size: 19),
                          label: const Text('Kiểm tra lại'),
                          style: TextButton.styleFrom(
                            foregroundColor: _gold,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: _gold,
                              foregroundColor: const Color(0xFF251800),
                            ),
                            child: const Text(
                              'HOÀN TẤT',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    tooltip: 'Đóng',
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      foregroundColor: _gold,
                      side: const BorderSide(color: Color(0x99FFD56A)),
                      backgroundColor: const Color(0xB3071727),
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusEmblem extends StatelessWidget {
  const _StatusEmblem({required this.success, required this.terminal});

  final bool success;
  final bool terminal;

  @override
  Widget build(BuildContext context) => Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0x221EC4FF),
      border: Border.all(color: const Color(0x88FFD56A)),
    ),
    child: Icon(
      success
          ? Icons.check_circle_rounded
          : terminal
          ? Icons.error_outline_rounded
          : Icons.hourglass_top_rounded,
      color: success
          ? const Color(0xFF67DDB0)
          : terminal
          ? const Color(0xFFFF8A8A)
          : _gold,
      size: 43,
    ),
  );
}

class _ExpiryBadge extends StatefulWidget {
  const _ExpiryBadge({required this.order});

  final PaymentOrder? order;

  @override
  State<_ExpiryBadge> createState() => _ExpiryBadgeState();
}

class _ExpiryBadgeState extends State<_ExpiryBadge> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _ExpiryBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order?.expiresAt != widget.order?.expiresAt) {
      _timer?.cancel();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final expiry = widget.order?.expiresAt;
    if (expiry == null || !expiry.isAfter(DateTime.now())) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!expiry.isAfter(DateTime.now())) timer.cancel();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.order?.expiresAt?.difference(DateTime.now());
    final expired = remaining != null && remaining.isNegative;
    final label = remaining == null
        ? 'Đang chờ xác nhận'
        : expired
        ? 'Đã hết hiệu lực'
        : '${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x660A1724),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xCCFFD56A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, color: _gold, size: 17),
          const SizedBox(width: 7),
          Text(
            remaining == null ? label : 'Còn hiệu lực  $label',
            style: const TextStyle(
              color: Color(0xFFFFE3A1),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = (constraints.maxWidth * .52).clamp(155.0, 185.0);
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          padding: EdgeInsets.zero,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(0xFF071827),
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(0xFF071827),
          ),
        ),
      );
    },
  );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final PaymentOrder order;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0x88071422),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xB3D9A73D)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _SummaryRow(
                label: 'Gói:',
                value: order.productName.isEmpty
                    ? _productLabel(order.productType)
                    : order.productName,
              ),
              const Divider(height: 6, color: Color(0x334F6170)),
              _SummaryRow(label: 'Số tiền:', value: _money(order.amount)),
              const Divider(height: 6, color: Color(0x334F6170)),
              _SummaryRow(
                label: 'Mã đơn:',
                value: order.orderCode.isEmpty ? order.id : order.orderCode,
                canCopy: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.canCopy = false,
  });

  final String label;
  final String value;
  final bool canCopy;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFFFFE09A),
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      if (canCopy) ...[
        const SizedBox(width: 5),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã sao chép mã đơn.')),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.copy_rounded, color: _gold, size: 16),
          ),
        ),
      ],
    ],
  );
}

class _PrimaryPayOsButton extends StatelessWidget {
  const _PrimaryPayOsButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: SizedBox(
      width: double.infinity,
      height: 41,
      child: FilledButton.icon(
        onPressed: () async {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: const Color(0xFF211600),
          shape: const StadiumBorder(),
        ),
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text(
          'Mở PayOS',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
  );
}

class _CheckPaymentButton extends ConsumerWidget {
  const _CheckPaymentButton({required this.isChecking});

  final bool isChecking;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: SizedBox(
      width: double.infinity,
      height: 39,
      child: OutlinedButton.icon(
        onPressed: isChecking
            ? null
            : ref.read(paymentOrderControllerProvider.notifier).check,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFFE4A2),
          side: const BorderSide(color: _gold, width: 1.3),
          shape: const StadiumBorder(),
        ),
        icon: isChecking
            ? const SizedBox.square(
                dimension: 17,
                child: CircularProgressIndicator(strokeWidth: 2, color: _gold),
              )
            : const Icon(Icons.check_circle_outline_rounded),
        label: Text(
          isChecking ? 'ĐANG KIỂM TRA...' : 'Tôi đã thanh toán',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

String _productLabel(String type) =>
    type.toUpperCase() == 'PREMIUM' ? 'Gói Hội Viên' : 'Gói Xu';

String _money(double value) {
  final digits = value.round().toString();
  final output = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) output.write('.');
    output.write(digits[index]);
  }
  return '$outputđ';
}
