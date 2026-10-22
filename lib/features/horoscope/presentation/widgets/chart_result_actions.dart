import 'package:flutter/material.dart';

class ChartResultActions extends StatelessWidget {
  const ChartResultActions({
    required this.isSaved,
    required this.isSaving,
    required this.onSave,
    required this.onInterpret,
    required this.onAskAi,
    required this.onExport,
    super.key,
  });

  final bool isSaved;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onInterpret;
  final VoidCallback onAskAi;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: isSaved ? 'ĐÃ LƯU' : 'LƯU LÁ SỐ',
              icon: isSaved ? Icons.check_circle : Icons.bookmark_add_outlined,
              filled: true,
              loading: isSaving,
              onPressed: isSaved || isSaving ? null : onSave,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: 'LUẬN GIẢI',
              icon: Icons.menu_book_outlined,
              onPressed: onInterpret,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'HỎI ĐÁP TỬ VI',
              icon: Icons.auto_awesome,
              onPressed: onAskAi,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: 'TẢI PDF',
              icon: Icons.download_outlined,
              onPressed: onExport,
            ),
          ),
        ],
      ),
    ],
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF9BECCB) : const Color(0xD9081824),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE0AD46), width: 1.3),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: loading
            ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
        ),
        style: TextButton.styleFrom(
          foregroundColor: filled
              ? const Color(0xFF174F43)
              : const Color(0xFFFFE8B5),
        ),
      ),
    ),
  );
}
