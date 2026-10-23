import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ai_chat_message.dart';
import '../controllers/ai_chat_controller.dart';

Future<void> showAiChatHistorySheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xB3000000),
      builder: (_) => const _ChatHistorySheet(),
    );

class _ChatHistorySheet extends ConsumerWidget {
  const _ChatHistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiChatControllerProvider);
    final messages = state.messages
        .where((message) => message.id != 'welcome')
        .toList(growable: false);

    return FractionallySizedBox(
      heightFactor: .82,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF8EACB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFFE0B654), width: 2),
            left: BorderSide(color: Color(0xFFE0B654)),
            right: BorderSide(color: Color(0xFFE0B654)),
          ),
          boxShadow: [BoxShadow(color: Color(0xAA000000), blurRadius: 24)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 9),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF9C783E),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 10, 10),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: Color(0xFF67431E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lịch sử trò chuyện',
                          style: TextStyle(
                            color: Color(0xFF2F1C0E),
                            fontFamily: 'serif',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          state.selectedChart?.displayName ?? 'Chưa chọn lá số',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF7B6041),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    onPressed: Navigator.of(context).pop,
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF4A2C13),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0x669C783E)),
            if (state.isLoadingHistory)
              const LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFFC28B2C),
                backgroundColor: Color(0x33C28B2C),
              ),
            Expanded(
              child: messages.isEmpty
                  ? const _EmptyHistory()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      itemCount: messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 9),
                      itemBuilder: (_, index) =>
                          _HistoryMessage(message: messages[index]),
                    ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      messages.isEmpty ||
                          state.isClearingHistory ||
                          state.selectedChart == null
                      ? null
                      : () => _confirmClear(context, ref),
                  icon: state.isClearingHistory
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline_rounded, size: 19),
                  label: Text(
                    state.isClearingHistory
                        ? 'ĐANG XÓA...'
                        : 'XÓA LỊCH SỬ LÁ SỐ NÀY',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9D2635),
                    side: const BorderSide(color: Color(0xFFB24A4F)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF8EACB),
        title: const Text('Xóa lịch sử trò chuyện?'),
        content: const Text(
          'Toàn bộ cuộc trò chuyện của lá số đang chọn sẽ bị xóa. '
          'Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('HỦY'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8D2634),
            ),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final success = await ref
        .read(aiChatControllerProvider.notifier)
        .clearHistory();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa lịch sử của lá số này.')),
      );
    }
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forum_outlined, size: 42, color: Color(0xFF9A7540)),
          SizedBox(height: 10),
          Text(
            'Chưa có lịch sử trò chuyện',
            style: TextStyle(
              color: Color(0xFF3B2816),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Các câu hỏi và câu trả lời của lá số đang chọn sẽ xuất hiện tại đây.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF806646), fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});
  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .78,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFFEFD49D) : const Color(0xFFFFF8E8),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFBE9146)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(
                    color: Color(0xFF302014),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                if (message.time.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      message.time,
                      style: const TextStyle(
                        color: Color(0xFF806A4E),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
