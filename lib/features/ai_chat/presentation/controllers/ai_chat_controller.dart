import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../horoscope/domain/saved_chart.dart';
import '../state/ai_chat_state.dart';

class AiChatController extends Notifier<AiChatState> {
  @override
  AiChatState build() => const AiChatState();

  void selectTopic(int index) {
    if (index == state.selectedTopic) return;
    state = state.copyWith(selectedTopic: index);
  }

  void selectChart(SavedChart chart) {
    if (state.selectedChart?.id == chart.id) return;
    state = state.copyWith(selectedChart: chart);
  }

  void send(String rawMessage) {
    final message = rawMessage.trim();
    if (message.isEmpty || state.isSending) return;

    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final userMessage = AiChatMessage(
      id: 'user-${now.microsecondsSinceEpoch}',
      role: AiChatRole.user,
      content: message,
      time: time,
    );

    state = state.copyWith(
      isSending: true,
      messages: List.unmodifiable([...state.messages, userMessage]),
    );

    // Phản hồi mô phỏng thông minh cho phiên bản giao diện
    unawaited(_simulateAssistantResponse(message));
  }

  Future<void> _simulateAssistantResponse(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 750));
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final reply = _generateAstrologyInsight(query);

    final assistantMessage = AiChatMessage(
      id: 'assistant-${now.microsecondsSinceEpoch}',
      role: AiChatRole.assistant,
      content: reply,
      time: time,
    );

    state = state.copyWith(
      isSending: false,
      messages: List.unmodifiable([...state.messages, assistantMessage]),
    );
  }

  String _generateAstrologyInsight(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('quan lộc') || lower.contains('sự nghiệp')) {
      return '**Cung Quan Lộc** của bạn nằm tại Thân có sao chiếu mệnh hội tụ cát tinh, cho thấy thời vận sự nghiệp đang trên đà hanh thông. Hãy chú trọng vào việc phát triển kỹ năng chuyên môn cốt lõi và giữ vững lập trường.';
    }
    if (lower.contains('tình duyên') || lower.contains('hôn nhân')) {
      return 'Về đường **Tình Duyên**, năm 2026 mang tới nhiều cơ duyên kết nối tốt đẹp. Bạn nên giữ tâm thế cởi mở, lắng nghe và thấu hiểu đối phương nhiều hơn.';
    }
    if (lower.contains('cải vận')) {
      return 'Phương pháp **cải vận** tối ưu nhất theo lá số là tu dưỡng tâm tính, hướng thiện và trau dồi tri thức. Giữ tâm bình an thì phúc khí tự khắc tụ về.';
    }
    return 'Dựa theo lá số của bạn, các sao chủ tọa đang báo hiệu những biến chuyển tích cực. Bạn có thể hỏi sâu hơn về từng cung hoặc thời điểm cụ thể để tôi luận giải chi tiết nhé.';
  }
}

final aiChatControllerProvider =
    NotifierProvider.autoDispose<AiChatController, AiChatState>(
      AiChatController.new,
    );
