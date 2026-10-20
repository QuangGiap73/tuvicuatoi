import 'package:flutter/material.dart';
import '../../shared/presentation/feature_placeholder.dart';

class AiChatPage extends StatelessWidget {
  const AiChatPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: 'Tử Vi AI',
    icon: Icons.forum,
    description:
        'Trò chuyện cùng trợ lý huyền học dựa trên dữ liệu lá số đã được người dùng cho phép.',
  );
}
