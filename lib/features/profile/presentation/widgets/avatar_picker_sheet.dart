import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<ImageSource?> showAvatarPickerSheet(BuildContext context) =>
    showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xB3000000),
      isScrollControlled: true,
      builder: (context) => const _AvatarPickerSheet(),
    );

class _AvatarPickerSheet extends StatelessWidget {
  const _AvatarPickerSheet();

  @override
  Widget build(BuildContext context) => SafeArea(
    minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF071923),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6A948)),
        boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 24)],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF7C6A46),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Cập nhật ảnh đại diện',
              style: TextStyle(
                color: Color(0xFFFFD98A),
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ảnh sẽ được cắt vuông trước khi tải lên',
              style: TextStyle(color: Color(0xFFAEB4B4), fontSize: 11.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_camera_rounded,
                    label: 'Chụp ảnh',
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Thư viện',
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF102B37),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF81662F)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFD36C), size: 25),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFF4E9D0),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
