import 'package:flutter/material.dart';
import '../../domain/daily_fortune.dart';

class FortuneHoursCard extends StatelessWidget {
  const FortuneHoursCard({required this.fortune, super.key});
  final DailyFortune fortune;
  @override
  Widget build(BuildContext context) {
    final good = fortune.auspiciousHours.toSet();
    final all = [...fortune.auspiciousHours, ...fortune.inauspiciousHours];
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xE9071A29),
        border: Border.all(color: const Color(0xFFD5A443)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '◷  12 KHUNG GIỜ TRONG NGÀY',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 15,
              color: Color(0xFFFFD77C),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 83,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final item = all[index];
                final isGood = good.contains(item);
                final parts = item.split(' ');
                return Container(
                  width: 103,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10283A),
                    border: Border.all(
                      color: isGood
                          ? const Color(0xFFD6A63D)
                          : const Color(0xFF415365),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        parts.first,
                        style: TextStyle(
                          color: isGood
                              ? const Color(0xFFFFD77C)
                              : const Color(0xFFD0D5D9),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parts.skip(1).join(' '),
                        style: const TextStyle(
                          color: Color(0xFFBFC4C7),
                          fontSize: 8,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isGood ? 'Hoàng Đạo' : 'Hắc Đạo',
                        style: TextStyle(
                          color: isGood
                              ? const Color(0xFFFFC94D)
                              : const Color(0xFFB9C3CD),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
