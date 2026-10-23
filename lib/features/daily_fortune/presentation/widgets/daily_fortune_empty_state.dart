import 'package:flutter/material.dart';

import '../../../../core/theme/mystic_colors.dart';
import '../../../../core/widgets/ancient_paper_card.dart';

class DailyFortuneEmptyState extends StatelessWidget {
  const DailyFortuneEmptyState({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) => AncientPaperCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 46,
            color: MysticColors.ink,
          ),
          const SizedBox(height: 12),
          Text(
            'Vận hạn ngày ${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MysticColors.ink,
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Hãy chọn một lá số để xem Can Chi, giờ hoàng đạo và vận trình trong ngày.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF735635),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
