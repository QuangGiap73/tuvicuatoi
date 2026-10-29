import 'package:flutter/material.dart';

const _gold = Color(0xFFE5BA50);

class TopUpHeader extends StatelessWidget {
  const TopUpHeader({required this.balance, super.key});
  final int? balance;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xB20A1623),
                shape: BoxShape.circle,
                border: Border.all(color: _gold),
              ),
              child: const Icon(Icons.chevron_left, color: Color(0xFFFFDD77)),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Nạp Xu & Gói Hội Viên',
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xFFFFE39A),
                  fontFamily: 'serif',
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xD4283035),
              border: Border.all(color: _gold),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: _gold, size: 14),
                const SizedBox(width: 4),
                Text(
                  balance == null ? '—' : _number(balance!),
                  style: const TextStyle(
                    color: Color(0xFFFFE3A0),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 11),
      const Row(
        children: [
          Expanded(child: Divider(color: Color(0x558F6A22))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.auto_awesome, color: Color(0xFFFFD96B), size: 17),
          ),
          Expanded(child: Divider(color: Color(0x558F6A22))),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Nạp Xu để mở khóa luận giải, hỏi đáp AI\nhoặc nâng cấp Hội Viên để nhận thêm đặc quyền',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
      ),
    ],
  );
}

String _number(int value) {
  final text = value.abs().toString();
  final output = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) output.write('.');
    output.write(text[index]);
  }
  return '${value < 0 ? '-' : ''}$output';
}
