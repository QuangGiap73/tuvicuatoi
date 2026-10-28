import 'package:flutter/material.dart';

import '../../../../core/widgets/mystic_notification_dialog.dart';

class BundleUnlockRequest {
  const BundleUnlockRequest({this.voucherCode});
  final String? voucherCode;
}

Future<BundleUnlockRequest?> showBundleUnlockDialog(
  BuildContext context, {
  required int sectionCount,
  required int estimatedCost,
  required int balance,
}) => MysticNotificationDialog.show<BundleUnlockRequest>(
  context,
  dialog: _BundleUnlockDialog(
    sectionCount: sectionCount,
    estimatedCost: estimatedCost,
    balance: balance,
  ),
);

class _BundleUnlockDialog extends StatefulWidget {
  const _BundleUnlockDialog({
    required this.sectionCount,
    required this.estimatedCost,
    required this.balance,
  });

  final int sectionCount;
  final int estimatedCost;
  final int balance;

  @override
  State<_BundleUnlockDialog> createState() => _BundleUnlockDialogState();
}

class _BundleUnlockDialogState extends State<_BundleUnlockDialog> {
  final _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MysticNotificationDialog(
    header: 'Mở khóa cả nhóm',
    title: 'Toàn bộ luận giải',
    description:
        'Mở ${widget.sectionCount} mục còn lại để đọc trọn nội dung của lá số.',
    leading: Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x33D09A2C),
        border: Border.all(color: const Color(0xFFBF8623)),
      ),
      child: const Icon(
        Icons.card_giftcard_rounded,
        color: Color(0xFF9A6416),
        size: 34,
      ),
    ),
    priceLabel: 'Giá mở nhóm',
    priceText: '${widget.estimatedCost} Xu',
    priceNote: 'Số dư: ${widget.balance} Xu',
    items: const [
      MysticNotificationItem('Mở các mục đã chọn cho lá số này'),
      MysticNotificationItem('Quyền đọc được lưu vĩnh viễn trên tài khoản'),
      MysticNotificationItem('Giá cuối cùng do máy chủ xác nhận'),
    ],
    extraContent: TextField(
      controller: _voucherController,
      textCapitalization: TextCapitalization.characters,
      decoration: const InputDecoration(
        labelText: 'Mã giảm giá (không bắt buộc)',
        prefixIcon: Icon(Icons.sell_outlined, size: 19),
        border: OutlineInputBorder(),
        isDense: true,
      ),
    ),
    cancelLabel: 'Hủy',
    confirmLabel: 'Xác nhận mở khóa',
    onConfirm: () {
      final voucher = _voucherController.text.trim();
      Navigator.pop(
        context,
        BundleUnlockRequest(voucherCode: voucher.isEmpty ? null : voucher),
      );
    },
  );
}
