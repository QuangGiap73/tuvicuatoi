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
    this.streamingMessage,
    this.selectedChart,
    this.selectedChartDetail,
    this.errorMessage,
    this.failure,
  });

  final int selectedTopic;
  final AiChatPhase phase;
  final List<AiChatMessage> messages;
  final AiChatMessage? streamingMessage;
  final SavedChart? selectedChart;
  final SavedChartDetail? selectedChartDetail;
  final String? errorMessage;
  final AiChatFailureDetails? failure;

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
    AiChatMessage? streamingMessage,
    SavedChart? selectedChart,
    SavedChartDetail? selectedChartDetail,
    String? errorMessage,
    AiChatFailureDetails? failure,
    bool clearDetail = false,
    bool clearError = false,
    bool clearStreamingMessage = false,
    bool clearFailure = false,
  }) => AiChatState(
    selectedTopic: selectedTopic ?? this.selectedTopic,
    phase: phase ?? this.phase,
    messages: messages ?? this.messages,
    streamingMessage: clearStreamingMessage
        ? null
        : streamingMessage ?? this.streamingMessage,
    selectedChart: selectedChart ?? this.selectedChart,
    selectedChartDetail: clearDetail
        ? null
        : selectedChartDetail ?? this.selectedChartDetail,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    failure: clearFailure ? null : failure ?? this.failure,
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
