import '../../../horoscope/domain/saved_chart.dart';
import '../../../horoscope/domain/saved_chart_detail.dart';
import '../../domain/ai_chat_message.dart';

enum AiChatPhase {
  ready,
  loadingChart,
  loadingHistory,
  sending,
  streaming,
  clearingHistory,
}

class AiChatState {
  const AiChatState({
    this.selectedTopic = 0,
    this.phase = AiChatPhase.ready,
    this.messages = welcomeMessages,
    this.selectedChart,
    this.selectedChartDetail,
    this.errorMessage,
  });

  final int selectedTopic;
  final AiChatPhase phase;
  final List<AiChatMessage> messages;
  final SavedChart? selectedChart;
  final SavedChartDetail? selectedChartDetail;
  final String? errorMessage;

  bool get isSending =>
      phase == AiChatPhase.sending || phase == AiChatPhase.streaming;
  bool get isWaitingForFirstToken => phase == AiChatPhase.sending;
  bool get isLoadingHistory => phase == AiChatPhase.loadingHistory;
  bool get isClearingHistory => phase == AiChatPhase.clearingHistory;
  bool get isBusy =>
      isSending ||
      phase == AiChatPhase.loadingChart ||
      phase == AiChatPhase.loadingHistory ||
      phase == AiChatPhase.clearingHistory;

  AiChatState copyWith({
    int? selectedTopic,
    AiChatPhase? phase,
    List<AiChatMessage>? messages,
    SavedChart? selectedChart,
    SavedChartDetail? selectedChartDetail,
    String? errorMessage,
    bool clearDetail = false,
    bool clearError = false,
  }) => AiChatState(
    selectedTopic: selectedTopic ?? this.selectedTopic,
    phase: phase ?? this.phase,
    messages: messages ?? this.messages,
    selectedChart: selectedChart ?? this.selectedChart,
    selectedChartDetail: clearDetail
        ? null
        : selectedChartDetail ?? this.selectedChartDetail,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  static const welcomeMessages = <AiChatMessage>[
    AiChatMessage(
      id: 'welcome',
      role: AiChatRole.assistant,
      content:
          'Chào bạn, rất vui được đồng hành cùng bạn trên hành trình khám phá lá số Tử Vi. Hãy chọn một lá số và đặt câu hỏi để bắt đầu.',
      time: '',
    ),
  ];
}
