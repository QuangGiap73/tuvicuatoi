import 'package:flutter/material.dart';

import '../../../../core/widgets/mystic_frame_button.dart';

class ChartResultActions extends StatelessWidget {
  const ChartResultActions({
    required this.isSaved,
    required this.isSaving,
    required this.onSave,
    required this.onInterpret,
    super.key,
  });

  final bool isSaved;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onInterpret;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: MysticFrameButton(
          label: isSaved ? 'ĐÃ LƯU' : 'LƯU LÁ SỐ',
          icon: isSaved
              ? Icons.check_circle_rounded
              : Icons.bookmark_add_outlined,
          selected: true,
          loading: isSaving,
          onPressed: isSaved || isSaving ? null : onSave,
        ),
      ),
      const SizedBox(width: 4),
      Expanded(
        child: MysticFrameButton(
          label: 'LUẬN GIẢI',
          icon: Icons.menu_book_outlined,
          selected: true,
          onPressed: onInterpret,
        ),
      ),
    ],
  );
}
