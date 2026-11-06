import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/widgets/mystic_notification_dialog.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../wallet/presentation/providers/top_up_providers.dart';

Future<bool> confirmChartSaveIfNeeded(
  BuildContext context,
  WidgetRef ref,
) async {
  final user = ref.read(authControllerProvider).asData?.value?.user;
  if (user == null) return false;
  var cost = 100;
  try {
    cost = (await ref.read(
      featureCostsProvider.future,
    )).costOf('saved_chart', fallback: cost);
  } catch (_) {
    // Backend remains authoritative; fallback is only for preflight UI.
  }
  if (!context.mounted) return false;
  final count = user.savedChartsCount ?? 0;
  final limit = user.maxSavedCharts ?? 2;
  if (user.hasUnlimitedSavedCharts || count < limit || cost <= 0) return true;

  if (!user.unlimitedCoins && user.coinBalance < cost) {
    final topUp = await MysticNotificationDialog.show<bool>(
      context,
      dialog: MysticNotificationDialog(
        header: 'KHÔNG ĐỦ XU',
        title: 'Bạn cần thêm Xu để lưu lá số',
        description:
            'Lưu thêm lá số cần $cost Xu, số dư hiện tại là ${user.coinBalance} Xu.',
        leading: const Icon(
          Icons.account_balance_wallet_outlined,
          size: 38,
          color: Color(0xFFA13A2C),
        ),
        cancelLabel: 'ĐỂ SAU',
        confirmLabel: 'NẠP XU',
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    if (topUp == true && context.mounted) context.push(AppRoute.coinPackages);
    return false;
  }

  return await MysticNotificationDialog.show<bool>(
        context,
        dialog: MysticNotificationDialog(
          header: 'LƯU THÊM LÁ SỐ',
          title: 'Xác nhận sử dụng Xu',
          description: 'Bạn đã dùng hết $count/$limit lượt lưu miễn phí.',
          leading: const Icon(
            Icons.bookmark_add_rounded,
            size: 38,
            color: Color(0xFF9A6417),
          ),
          priceLabel: 'Chi phí lưu thêm',
          priceText: '$cost Xu',
          priceNote: 'Số dư hiện tại: ${user.coinBalance} Xu',
          items: const [
            MysticNotificationItem('Lá số được lưu và đồng bộ với tài khoản.'),
            MysticNotificationItem('Backend xác nhận giá và trừ Xu khi lưu.'),
          ],
          cancelLabel: 'HỦY',
          confirmLabel: 'LƯU LÁ SỐ',
          onCancel: () => Navigator.pop(context, false),
          onConfirm: () => Navigator.pop(context, true),
        ),
      ) ==
      true;
}
