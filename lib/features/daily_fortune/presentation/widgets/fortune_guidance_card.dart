import 'package:flutter/material.dart';

import '../../domain/daily_fortune.dart';

class FortuneGuidanceCard extends StatelessWidget {
  const FortuneGuidanceCard({required this.fortune, super.key});

  final DailyFortune fortune;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFD66D), Color(0xFFB87519), Color(0xFFFFD66D)],
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 3,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6DA), Color(0xFFFFE5AA), Color(0xFFFFF1CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF8F5A17), width: .8),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Direction(
              icon: Icons.wb_sunny_rounded,
              label: 'HỶ THẦN',
              subtitle: 'Hướng may mắn',
              value: fortune.joyDirection,
            ),
          ),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFFB77A26),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(
            child: _Direction(
              icon: Icons.savings_rounded,
              label: 'TÀI THẦN',
              subtitle: 'Hướng tài lộc',
              value: fortune.wealthDirection,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Direction extends StatelessWidget {
  const _Direction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String? value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE18B), Color(0xFFE7A52C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFB77417)),
        ),
        child: Icon(icon, color: const Color(0xFF70420D), size: 21),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF8A5A18),
                fontSize: 8,
                letterSpacing: .5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value?.trim().isNotEmpty == true ? value!.trim() : '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'serif',
                color: Color(0xFF39230C),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF8B7652), fontSize: 7.5),
            ),
          ],
        ),
      ),
    ],
  );
}
