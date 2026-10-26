import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../horoscope/data/chart_repository.dart';
import '../../../horoscope/domain/chart_result.dart';
import '../../../horoscope/domain/saved_chart.dart';
import '../../../horoscope/domain/saved_chart_detail.dart';
import '../../data/ai_chat_history_store.dart';
import '../../data/ai_chat_repository.dart';
import '../../domain/ai_chat_message.dart';
import '../state/ai_chat_state.dart';

class AiChatController extends Notifier<AiChatState> {
  CancelToken? _chartCancelToken;
  CancelToken? _historyCancelToken;
  CancelToken? _sendCancelToken;
  int _chartSession = 0;

  static const palaceNames = <String>[
    'Mệnh',
    'Phụ Mẫu',
    'Phúc Đức',
    'Điền Trạch',
    'Quan Lộc',
    'Nô Bộc',
    'Thiên Di',
    'Tật Ách',
    'Tài Bạch',
    'Tử Tức',
    'Phu Thê',
    'Huynh Đệ',
  ];

  @override
  AiChatState build() {
    ref.onDispose(() {
      _chartCancelToken?.cancel();
      _historyCancelToken?.cancel();
      _sendCancelToken?.cancel();
    });
    return const AiChatState();
  }

  void selectTopic(int index) {
    if (index < 0 || index >= palaceNames.length) return;
    if (index == state.selectedTopic) return;
    state = state.copyWith(selectedTopic: index);
  }

  void useGeneratedChart(ChartResult result) {
    ++_chartSession;
    _chartCancelToken?.cancel('Dùng lá số vừa lập');
    _historyCancelToken?.cancel('Dùng lá số vừa lập');
    _sendCancelToken?.cancel('Dùng lá số vừa lập');
    final summary = SavedChart(
      id: result.id,
      name: result.fullName,
      gender: result.gender,
      solarDate: result.solarDate,
      lunarDate: result.lunarDate,
      createdAt: '',
      hourBranch: result.hourBranch,
      menh: result.menh,
      cuc: result.cuc,
    );
    state = AiChatState(
      selectedChart: summary,
      selectedChartDetail: SavedChartDetail(
        summary: summary,
        chartData: result.rawData,
      ),
    );
  }

  Future<void> selectChart(SavedChart chart) async {
    if (state.selectedChart?.id == chart.id &&
        state.selectedChartDetail != null) {
      return;
    }
    final session = ++_chartSession;
    _chartCancelToken?.cancel('Chart changed');
    _historyCancelToken?.cancel('Chart changed');
    _sendCancelToken?.cancel('Chart changed');
    final chartToken = CancelToken();
    final historyToken = CancelToken();
    _chartCancelToken = chartToken;
    _historyCancelToken = historyToken;

    state = AiChatState(selectedChart: chart, phase: AiChatPhase.loadingChart);

    try {
      final detail = await ref
          .read(chartRepositoryProvider)
          .getChartDetail(chart, cancelToken: chartToken);
      if (session != _chartSession || chartToken.isCancelled) return;
      state = state.copyWith(
        selectedChart: detail.summary,
        selectedChartDetail: detail,
        phase: AiChatPhase.loadingHistory,
        clearError: true,
      );

      final user = ref.read(authControllerProvider).asData?.value?.user;
      if (user == null) {
        state = state.copyWith(phase: AiChatPhase.ready);
        return;
      }
      final localUserId = user.id.isNotEmpty ? user.id : user.email;
      final localHistory = await ref
          .read(aiChatHistoryStoreProvider)
          .read(userId: localUserId, chartId: detail.summary.id);
      if (session != _chartSession || historyToken.isCancelled) return;
      if (localHistory.isNotEmpty) {
        state = state.copyWith(
          messages: localHistory,
          phase: AiChatPhase.loadingHistory,
        );
      }

      final canSyncCloudHistory =
          user.hasAiChatHistory || user.isPremium || user.role == 'admin';
      if (!canSyncCloudHistory) {
        state = state.copyWith(phase: AiChatPhase.ready);
        return;
      }
      final history = await ref
          .read(aiChatRepositoryProvider)
          .getHistory(
            chartId: detail.summary.id,
            email: user.email,
            cancelToken: historyToken,
          );
      if (session != _chartSession || historyToken.isCancelled) return;
      state = state.copyWith(
        messages: history.isNotEmpty
            ? List.unmodifiable(history)
            : localHistory.isNotEmpty
            ? localHistory
            : AiChatState.welcomeMessages,
        phase: AiChatPhase.ready,
      );
      if (history.isNotEmpty) {
        await ref
            .read(aiChatHistoryStoreProvider)
            .write(
              userId: localUserId,
              chartId: detail.summary.id,
              messages: history,
            );
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      _setLoadError(error.userMessage, session);
    } on ChartException catch (error) {
      _setLoadError(error.message, session);
    } on AiChatException catch (error) {
      if (session != _chartSession) return;
      // Chi tiết lá số đã tải thành công; lỗi history không được chặn Chat.
      state = state.copyWith(
        phase: AiChatPhase.ready,
        errorMessage: error.message,
      );
    }
  }

  void _setLoadError(String message, int session) {
    if (session != _chartSession) return;
    state = state.copyWith(phase: AiChatPhase.ready, errorMessage: message);
  }

  Future<bool> send(String rawMessage) async {
    final message = rawMessage.trim();
    if (message.isEmpty || state.isBusy) return false;
    final chart = state.selectedChart;
    final detail = state.selectedChartDetail;
    final user = ref.read(authControllerProvider).asData?.value?.user;
    if (chart == null || detail == null) {
      state = state.copyWith(
        errorMessage: 'Vui lòng chọn và tải đầy đủ một lá số trước khi hỏi.',
      );
      return false;
    }
    if (user == null) {
      state = state.copyWith(errorMessage: 'Vui lòng đăng nhập để sử dụng AI.');
      return false;
    }

    final session = _chartSession;
    final now = DateTime.now();
    final time = _time(now);
    final userId = 'user-${now.microsecondsSinceEpoch}';
    final assistantId = 'assistant-${now.microsecondsSinceEpoch}';
    final userMessage = AiChatMessage(
      id: userId,
      role: AiChatRole.user,
      content: message,
      time: time,
      createdAt: now,
      status: AiChatMessageStatus.sending,
    );
    state = state.copyWith(
      phase: AiChatPhase.sending,
      messages: List.unmodifiable([...state.messages, userMessage]),
      clearError: true,
    );

    _sendCancelToken?.cancel('A newer message was sent');
    final token = CancelToken();
    _sendCancelToken = token;
    var accumulated = '';
    var hasAssistantBubble = false;
    try {
      final selectedPalace = palaceNames[state.selectedTopic];
      // Giữ tiền tố để tương thích backend hiện tại, đồng thời gửi focusPalace
      // riêng theo hợp đồng API mới.
      final contextualMessage =
          '[Cung đang luận giải: $selectedPalace]\n\n$message';
      await for (final event
          in ref
              .read(aiChatRepositoryProvider)
              .sendMessage(
                message: contextualMessage,
                chartId: chart.id,
                chartData: detail.chartData,
                focusPalace: selectedPalace,
                isPremium: user.isPremium || user.hasUnlimitedAi,
                userEmail: user.email,
                cancelToken: token,
              )) {
        if (session != _chartSession || token.isCancelled) return false;
        if (event is AiChatDelta) {
          accumulated += event.text;
          hasAssistantBubble = true;
          _upsertAssistant(
            assistantId,
            accumulated,
            time,
            AiChatMessageStatus.streaming,
            userId,
          );
        } else if (event is AiChatDone) {
          if (event.fullText.trim().isNotEmpty) accumulated = event.fullText;
          hasAssistantBubble = true;
          _upsertAssistant(
            assistantId,
            accumulated,
            time,
            AiChatMessageStatus.sent,
            userId,
          );
        } else if (event is AiChatStreamError) {
          throw AiChatException(event.message);
        }
      }
      if (!hasAssistantBubble || accumulated.trim().isEmpty) {
        throw const AiChatException('AI chưa trả về nội dung.');
      }
      state = state.copyWith(phase: AiChatPhase.ready);
      final localUserId = user.id.isNotEmpty ? user.id : user.email;
      await ref
          .read(aiChatHistoryStoreProvider)
          .write(
            userId: localUserId,
            chartId: chart.id,
            messages: state.messages,
          );
      await ref.read(authControllerProvider.notifier).refreshProfile();
      return true;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return false;
      _markFailed(userId, error.userMessage);
      return false;
    } on AiChatException catch (error) {
      _markFailed(userId, error.message);
      return false;
    } finally {
      if (identical(_sendCancelToken, token)) _sendCancelToken = null;
    }
  }

  Future<bool> clearHistory() async {
    if (state.isBusy) return false;
    final chart = state.selectedChart;
    final user = ref.read(authControllerProvider).asData?.value?.user;
    if (chart == null || user == null) {
      state = state.copyWith(
        errorMessage: 'Vui lòng chọn lá số trước khi xóa lịch sử.',
      );
      return false;
    }

    state = state.copyWith(
      phase: AiChatPhase.clearingHistory,
      clearError: true,
    );
    final localUserId = user.id.isNotEmpty ? user.id : user.email;
    try {
      final hasCloudHistory =
          user.hasAiChatHistory || user.isPremium || user.role == 'admin';
      if (hasCloudHistory) {
        await ref
            .read(aiChatRepositoryProvider)
            .clearHistory(chartId: chart.id);
      }
      await ref
          .read(aiChatHistoryStoreProvider)
          .delete(userId: localUserId, chartId: chart.id);
      state = state.copyWith(
        phase: AiChatPhase.ready,
        messages: AiChatState.welcomeMessages,
      );
      return true;
    } on AiChatException catch (error) {
      state = state.copyWith(
        phase: AiChatPhase.ready,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        phase: AiChatPhase.ready,
        errorMessage: 'Không thể xóa lịch sử trên thiết bị.',
      );
      return false;
    }
  }

  void _upsertAssistant(
    String assistantId,
    String content,
    String time,
    AiChatMessageStatus status,
    String userId,
  ) {
    final messages = [...state.messages];
    final userIndex = messages.indexWhere((item) => item.id == userId);
    if (userIndex >= 0) {
      messages[userIndex] = messages[userIndex].copyWith(
        status: AiChatMessageStatus.sent,
      );
    }
    final index = messages.indexWhere((item) => item.id == assistantId);
    final assistant = AiChatMessage(
      id: assistantId,
      role: AiChatRole.assistant,
      content: content,
      time: time,
      status: status,
    );
    if (index >= 0) {
      messages[index] = assistant;
    } else {
      messages.add(assistant);
    }
    state = state.copyWith(
      phase: status == AiChatMessageStatus.streaming
          ? AiChatPhase.streaming
          : AiChatPhase.sending,
      messages: List.unmodifiable(messages),
    );
  }

  void _markFailed(String userId, String message) {
    final messages = state.messages
        .map(
          (item) => item.id == userId
              ? item.copyWith(status: AiChatMessageStatus.failed)
              : item,
        )
        .toList(growable: false);
    state = state.copyWith(
      phase: AiChatPhase.ready,
      messages: List.unmodifiable(messages),
      errorMessage: message,
    );
  }

  static String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);
