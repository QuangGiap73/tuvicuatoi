import 'package:flutter/material.dart';

Future<bool?> showLoginRequiredDialog(
  BuildContext context, {
  required IconData icon,
  required String message,
}) => showDialog<bool>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    backgroundColor: const Color(0xFFF7E9C4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFD39A28), width: 1.2),
    ),
    icon: Icon(icon, color: const Color(0xFF9A6512), size: 42),
    title: const Text(
      'Bạn cần đăng nhập',
      textAlign: TextAlign.center,
      style: TextStyle(color: Color(0xFF38250E), fontWeight: FontWeight.w800),
    ),
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF5E4A2E), height: 1.4),
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      OutlinedButton(
        onPressed: () => Navigator.pop(dialogContext, false),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF705A38),
          side: const BorderSide(color: Color(0xFFB99A63)),
        ),
        child: const Text('Để sau'),
      ),
      FilledButton.icon(
        onPressed: () => Navigator.pop(dialogContext, true),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFAA7415),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.login_rounded, size: 18),
        label: const Text('Đăng nhập'),
      ),
    ],
  ),
);
