import 'package:flutter/material.dart';

import '../../../core/widgets/mystic_notification_dialog.dart';

Future<bool?> showLoginRequiredDialog(
  BuildContext context, {
  required IconData icon,
  required String message,
}) => MysticNotificationDialog.show<bool>(
  context,
  dialog: MysticNotificationDialog(
    header: 'TỬ VI THÀNH VIÊN',
    title: 'Bạn cần đăng nhập',
    description: message,
    leading: Icon(icon, color: const Color(0xFF9A6512), size: 40),
    cancelLabel: 'ĐỂ SAU',
    confirmLabel: 'ĐĂNG NHẬP',
    onCancel: () => Navigator.pop(context, false),
    onConfirm: () => Navigator.pop(context, true),
  ),
);
