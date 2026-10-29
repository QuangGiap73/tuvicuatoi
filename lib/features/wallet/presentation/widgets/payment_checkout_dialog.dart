import 'package:flutter/material.dart';

import '../../domain/wallet_models.dart';

enum WalletPaymentMethod { payos, momo, card }

class PaymentCheckoutRequest {
  const PaymentCheckoutRequest({required this.method, this.voucherCode});

  final WalletPaymentMethod method;
  final String? voucherCode;
}

Future<PaymentCheckoutRequest?> showPaymentCheckoutDialog({
  required BuildContext context,
  required String productName,
  required double amount,
  required String featureKey,
  required Future<VoucherValidationResult> Function({
    required String code,
    required String featureKey,
    required double originalCost,
  })
  onValidateVoucher,
}) => showDialog<PaymentCheckoutRequest>(
  context: context,
  barrierDismissible: true,
  builder: (_) => _PaymentCheckoutDialog(
    productName: productName,
    amount: amount,
    featureKey: featureKey,
    onValidateVoucher: onValidateVoucher,
  ),
);

class _PaymentCheckoutDialog extends StatefulWidget {
  const _PaymentCheckoutDialog({
    required this.productName,
    required this.amount,
    required this.featureKey,
    required this.onValidateVoucher,
  });

  final String productName;
  final double amount;
  final String featureKey;
  final Future<VoucherValidationResult> Function({
    required String code,
    required String featureKey,
    required double originalCost,
  })
  onValidateVoucher;

  @override
  State<_PaymentCheckoutDialog> createState() => _PaymentCheckoutDialogState();
}

class _PaymentCheckoutDialogState extends State<_PaymentCheckoutDialog> {
  final _voucherController = TextEditingController();
  VoucherValidationResult? _validatedVoucher;
  String? _voucherError;
  bool _isValidating = false;

  bool get _requiresValidation =>
      _voucherController.text.trim().isNotEmpty &&
      _validatedVoucher?.code.toUpperCase() !=
          _voucherController.text.trim().toUpperCase();

  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty || _isValidating) return;
    setState(() {
      _isValidating = true;
      _voucherError = null;
      _validatedVoucher = null;
    });
    try {
      final result = await widget.onValidateVoucher(
        code: code,
        featureKey: widget.featureKey,
        originalCost: widget.amount,
      );
      if (!mounted ||
          _voucherController.text.trim().toUpperCase() != code.toUpperCase()) {
        return;
      }
      setState(() => _validatedVoucher = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _voucherError = error.toString());
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 650),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1930),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD8AB3D), width: 1.4),
            boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 30)],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'CỔNG THANH TOÁN',
                        style: TextStyle(
                          color: Color(0xFFFFD66B),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFFFDF83),
                      ),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    text: 'Thanh toán gói ',
                    children: [
                      TextSpan(
                        text: widget.productName,
                        style: const TextStyle(color: Color(0xFFFFD66B)),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    color: Color(0xFFFFEBC0),
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                _PaymentAmount(
                  originalAmount: widget.amount,
                  voucher: _validatedVoucher,
                ),
                const SizedBox(height: 18),
                _VoucherField(
                  controller: _voucherController,
                  isLoading: _isValidating,
                  onApply: _applyVoucher,
                  onChanged: (_) {
                    if (_validatedVoucher == null && _voucherError == null) {
                      return;
                    }
                    setState(() {
                      _validatedVoucher = null;
                      _voucherError = null;
                    });
                  },
                ),
                if (_validatedVoucher != null || _voucherError != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    _validatedVoucher?.message.isNotEmpty == true
                        ? _validatedVoucher!.message
                        : _validatedVoucher != null
                        ? 'Áp dụng voucher thành công.'
                        : _voucherError!,
                    style: TextStyle(
                      color: _validatedVoucher != null
                          ? const Color(0xFF54D6A1)
                          : const Color(0xFFFF7A7A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(
                      child: _PaymentMethodTile(
                        icon: Icons.account_balance_rounded,
                        label: 'PAYOS / VIETQR',
                        selected: true,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _PaymentMethodTile(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'VÍ MOMO',
                        maintenance: true,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _PaymentMethodTile(
                        icon: Icons.credit_card_rounded,
                        label: 'VISA/MC',
                        maintenance: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101D36),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF405174)),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFFFFD66B),
                        size: 34,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Thanh toán an toàn qua PayOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Xu hoặc quyền Hội viên chỉ được cấp sau khi ngân hàng và backend xác nhận giao dịch.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isValidating || _requiresValidation
                      ? null
                      : () {
                          final voucher = _voucherController.text.trim();
                          Navigator.of(context).pop(
                            PaymentCheckoutRequest(
                              method: WalletPaymentMethod.payos,
                              voucherCode: voucher.isEmpty ? null : voucher,
                            ),
                          );
                        },
                  icon: const Icon(Icons.qr_code_2_rounded),
                  label: const Text('TIẾP TỤC THANH TOÁN QUA PAYOS'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD29A22),
                    foregroundColor: const Color(0xFF281702),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MoMo và thẻ Visa/Mastercard đang bảo trì.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoucherField extends StatelessWidget {
  const _VoucherField({
    required this.controller,
    required this.isLoading,
    required this.onApply,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onApply;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF101D36),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFF405174)),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        prefixIcon: const Icon(
          Icons.confirmation_number_outlined,
          color: Color(0xFFFFD66B),
          size: 18,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 30),
        hintText: 'Mã giảm giá / Voucher (không bắt buộc)',
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 68,
          minHeight: 32,
        ),
        suffixIcon: TextButton(
          onPressed: isLoading ? null : onApply,
          child: isLoading
              ? const SizedBox.square(
                  dimension: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFD66B),
                  ),
                )
              : const Text(
                  'ÁP DỤNG',
                  style: TextStyle(
                    color: Color(0xFFFFD66B),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    ),
  );
}

class _PaymentAmount extends StatelessWidget {
  const _PaymentAmount({required this.originalAmount, required this.voucher});

  final double originalAmount;
  final VoucherValidationResult? voucher;

  @override
  Widget build(BuildContext context) {
    final finalCost = voucher?.finalCost ?? originalAmount;
    return Wrap(
      spacing: 6,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Số tiền cần thanh toán:',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        if (voucher != null)
          Text(
            _money(originalAmount),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          _money(finalCost),
          style: const TextStyle(
            color: Color(0xFFFFD66B),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (voucher != null && voucher!.discountAmount > 0)
          Text(
            'Giảm ${_money(voucher!.discountAmount)}',
            style: const TextStyle(
              color: Color(0xFF54D6A1),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    this.selected = false,
    this.maintenance = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool maintenance;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: maintenance ? .48 : 1,
    child: Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14213D),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: selected ? const Color(0xFFFFD66B) : const Color(0xFF405174),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFFD66B), size: 20),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (maintenance)
            const Text(
              'BẢO TRÌ',
              style: TextStyle(
                color: Color(0xFFFFC65A),
                fontSize: 7,
                fontWeight: FontWeight.w900,
              ),
            ),
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
  return '$buffer'
      'đ';
}
