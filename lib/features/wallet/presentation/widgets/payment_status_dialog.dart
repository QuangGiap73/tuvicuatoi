import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/payment_order_providers.dart';

Future<void> showPaymentStatusDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
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
    if (success && !_invalidatedHistory) {
      _invalidatedHistory = true;
      Future.microtask(() => ref.invalidate(paymentOrdersControllerProvider));
    }
    return AlertDialog(
      backgroundColor: const Color(0xFF0C192B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD7A83C)),
      ),
      icon: Icon(
        success
            ? Icons.check_circle_rounded
            : terminal
            ? Icons.error_outline_rounded
            : Icons.hourglass_top_rounded,
        color: success
            ? const Color(0xFF54D6A1)
            : terminal
            ? const Color(0xFFFF7A7A)
            : const Color(0xFFFFD66B),
        size: 42,
      ),
      title: Text(
        success
            ? 'Thanh toán thành công'
            : terminal
            ? 'Đơn hàng không thành công'
            : 'Đang chờ thanh toán',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFFFE5A4),
          fontFamily: 'serif',
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            success
                ? 'Backend đã xác nhận giao dịch và cập nhật quyền lợi tài khoản.'
                : terminal
                ? 'Trạng thái đơn: ${order?.status ?? 'Không xác định'}.'
                : 'Sau khi hoàn tất PayOS, hãy quay lại đây để kiểm tra trạng thái đơn.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 10),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFF7A7A), fontSize: 11),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (!success && !terminal)
          TextButton.icon(
            onPressed: state.isChecking
                ? null
                : ref.read(paymentOrderControllerProvider.notifier).check,
            icon: state.isChecking
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            label: const Text('TÔI ĐÃ THANH TOÁN'),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD29A22),
            foregroundColor: const Color(0xFF281702),
          ),
          child: Text(success || terminal ? 'ĐÓNG' : 'KIỂM TRA SAU'),
        ),
      ],
    );
  }
}
