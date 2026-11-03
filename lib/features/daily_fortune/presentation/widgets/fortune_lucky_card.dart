import 'package:flutter/material.dart';

import '../../domain/personal_fortune.dart';

class FortuneLuckyCard extends StatelessWidget {
  const FortuneLuckyCard({required this.fortune, super.key});

  final PersonalFortune fortune;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFD66D), Color(0xFFB87519), Color(0xFFFFD66D)],
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8DF), Color(0xFFFFE5AE), Color(0xFFFFF4D5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF8F5A17), width: .8),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _Title(),
              Container(
                width: 1,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 9),
                color: const Color(0x55A56B20),
              ),
              Expanded(
                child: _LuckyValue(
                  icon: Icons.palette_rounded,
                  label: 'Màu may mắn',
                  value: fortune.luckyColor,
                  green: true,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _LuckyValue(
                  icon: Icons.navigation_rounded,
                  label: 'Hướng may mắn',
                  value: fortune.luckyDirection,
                  green: false,
                ),
              ),
            ],
          ),
          if (fortune.luckyColorReason.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 11,
                  color: Color(0xFFC58A22),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    fortune.luckyColorReason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF69502E),
                      fontSize: 8.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 105,
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [Color(0xFFFFE18B), Color(0xFFB77A17)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF8A560F)),
          ),
          child: const Icon(
            Icons.local_florist_rounded,
            color: Color(0xFFFFE7A4),
            size: 21,
          ),
        ),
        const SizedBox(width: 7),
        const Expanded(
          child: Text(
            'MAY MẮN\nTRONG NGÀY',
            style: TextStyle(
              fontFamily: 'serif',
              color: Color(0xFF35220C),
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _LuckyValue extends StatelessWidget {
  const _LuckyValue({
    required this.icon,
    required this.label,
    required this.value,
    required this.green,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool green;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 7),
    decoration: BoxDecoration(
      color: green ? const Color(0xFFDDF0D7) : const Color(0xFFFFEBC2),
      border: Border.all(
        color: green ? const Color(0xFF84A779) : const Color(0xFFD3A14C),
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: green ? const Color(0xFF3D7759) : const Color(0xFF99651D),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF716044), fontSize: 7.5),
              ),
              const SizedBox(height: 1),
              Text(
                value.trim().isEmpty ? '—' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  color: Color(0xFF30210F),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
