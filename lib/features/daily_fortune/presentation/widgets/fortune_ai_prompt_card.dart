import 'package:flutter/material.dart';

class FortuneAiPromptCard extends StatelessWidget {
  const FortuneAiPromptCard({
    required this.prompt,
    required this.onOpenChat,
    super.key,
  });
  final String prompt;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
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
          '✦  HỎI CỐ VẤN AI VỀ NGÀY NÀY',
          style: TextStyle(
            fontFamily: 'serif',
            color: Color(0xFFFFD77C),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          prompt,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFD9CDB5),
            fontSize: 10.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onOpenChat,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8D5A10),
              foregroundColor: const Color(0xFFFFE2A0),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.auto_awesome, size: 15),
            label: const Text(
              'Mở AI Chat',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}
