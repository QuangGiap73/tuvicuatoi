import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../horoscope/data/chart_repository.dart';
import '../../../horoscope/domain/chart_request.dart';
import '../../../horoscope/domain/chart_result.dart';
import '../../../horoscope/domain/saved_chart.dart';
import '../../../horoscope/presentation/providers/chart_form_providers.dart';
import '../../data/interpretation_repository.dart';
import '../../domain/interpretation_models.dart';
import '../state/interpretation_state.dart';

class InterpretationController extends Notifier<InterpretationState> {
  CancelToken? _chartToken;
  CancelToken? _sectionsToken;
  CancelToken? _unlocksToken;
  CancelToken? _contentToken;
  CancelToken? _unlockToken;
  int _session = 0;

  @override
  InterpretationState build() {
    ref.onDispose(_cancelAll);
    return const InterpretationState();
  }

  void openGenerated({
    required ChartRequest request,
    required ChartResult result,
    String? savedChartId,
  }) {
    final context = InterpretationChartContext(
      name: result.fullName,
      chartId: _notEmpty(savedChartId),
      chartData: result.rawData,
      request: request,
      generatedResult: result,
    );
    _start(context);
  }

  void openContext(InterpretationChartContext context) => _start(context);

  void openSaved(SavedChart chart) {
    _cancelAll();
    final session = ++_session;
    state = InterpretationState(
      context: InterpretationChartContext(
        name: chart.displayName,
        chartId: chart.id,
        chartData: const {},
        savedSummary: chart,
      ),
      isLoadingChart: true,
    );
    _loadSavedChart(chart, session);
  }

  Future<void> _loadSavedChart(SavedChart chart, int session) async {
    final token = CancelToken();
    _chartToken = token;
    try {
      final detail = await ref
          .read(chartRepositoryProvider)
          .getChartDetail(chart, cancelToken: token);
      if (!_isCurrent(session, token)) return;
      final context = InterpretationChartContext(
        name: detail.summary.displayName,
        chartId: detail.summary.id,
        chartData: detail.chartData,
        savedSummary: detail.summary,
      );
      state = state.copyWith(
        context: context,
        isLoadingChart: false,
        clearError: true,
      );
      _loadAll(session);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || session != _session) return;
      _setChartError(error.userMessage);
    } on ChartException catch (error) {
      if (session != _session) return;
      _setChartError(error.message);
    }
  }

  void _setChartError(String message) {
    state = state.copyWith(isLoadingChart: false, errorMessage: message);
  }

  void _start(InterpretationChartContext context) {
    _cancelAll();
    final session = ++_session;
    state = InterpretationState(context: context);
    _loadAll(session);
  }

  void _loadAll(int session) {
    loadSections(session: session);
    final chartId = state.context?.chartId;
    if (chartId != null) loadUnlocks(session: session);
    loadInterpretation(session: session);
  }

  Future<void> loadSections({int? session}) async {
    final activeSession = session ?? _session;
    _sectionsToken?.cancel('Đang tải danh mục mới');
    final token = CancelToken();
    _sectionsToken = token;
    state = state.copyWith(isLoadingSections: true, clearError: true);
    try {
      final sections = await ref
          .read(interpretationRepositoryProvider)
          .getSections(cancelToken: token);
      if (!_isCurrent(activeSession, token)) return;
      state = state.copyWith(sections: sections, isLoadingSections: false);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      _setTaskError(error.userMessage, sections: true);
    } on InterpretationException catch (error) {
      if (activeSession != _session) return;
      _setTaskError(error.message, sections: true);
    }
  }

  Future<void> loadUnlocks({int? session}) async {
    final chartId = state.context?.chartId;
    if (chartId == null) return;
    final activeSession = session ?? _session;
    _unlocksToken?.cancel('Đang tải quyền đọc mới');
    final token = CancelToken();
    _unlocksToken = token;
    state = state.copyWith(isLoadingUnlocks: true, clearError: true);
    try {
      final keys = await ref
          .read(interpretationRepositoryProvider)
          .getUnlocks(chartId: chartId, cancelToken: token);
      if (!_isCurrent(activeSession, token) ||
          state.context?.chartId != chartId) {
        return;
      }
      state = state.copyWith(unlockedKeys: keys, isLoadingUnlocks: false);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      _setTaskError(error.userMessage, unlocks: true);
    } on InterpretationException catch (error) {
      if (activeSession != _session) return;
      _setTaskError(error.message, unlocks: true);
    }
  }

  Future<void> loadInterpretation({int? session, bool force = false}) async {
    final context = state.context;
    if (context == null || context.chartData.isEmpty) return;
    final activeSession = session ?? _session;
    final mode = state.mode;
    if (!force && state.contentByMode.containsKey(mode)) return;
    _contentToken?.cancel('Đổi chế độ luận giải');
    final token = CancelToken();
    _contentToken = token;
    state = state.copyWith(isLoadingInterpretation: true, clearError: true);
    try {
      InterpretationData content;
      if (context.isSaved && mode == InterpretationMode.deep) {
        try {
          content = await ref
              .read(interpretationRepositoryProvider)
              .getSavedInterpretation(
                chartId: context.chartId!,
                cancelToken: token,
              );
          if (content.isEmpty) {
            content = await _generate(context, mode, token);
          }
        } on InterpretationException catch (error) {
          if (error.statusCode != 404) rethrow;
          content = await _generate(context, mode, token);
        }
      } else {
        content = await _generate(context, mode, token);
      }
      if (!_isCurrent(activeSession, token) || state.mode != mode) return;
      state = state.copyWith(
        contentByMode: Map.unmodifiable({
          ...state.contentByMode,
          mode: content,
        }),
        isLoadingInterpretation: false,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      _setTaskError(error.userMessage, interpretation: true);
    } on InterpretationException catch (error) {
      if (activeSession != _session) return;
      _setTaskError(error.message, interpretation: true);
    }
  }

  Future<InterpretationData> _generate(
    InterpretationChartContext context,
    InterpretationMode mode,
    CancelToken token,
  ) => ref
      .read(interpretationRepositoryProvider)
      .generate(chartData: context.chartData, mode: mode, cancelToken: token);

  void selectTab(InterpretationTab tab) {
    if (tab == state.selectedTab) return;
    state = state.copyWith(selectedTab: tab);
  }

  void selectPalace(String? palace) {
    state = state.copyWith(
      selectedPalace: palace,
      clearSelectedPalace: palace == null,
    );
  }

  void changeMode(InterpretationMode mode) {
    if (mode == state.mode) return;
    _contentToken?.cancel('Đổi chế độ luận giải');
    state = state.copyWith(
      mode: mode,
      isLoadingInterpretation: false,
      clearError: true,
    );
    loadInterpretation();
  }

  bool isUnlocked(ReadingSection section) {
    if (section.isFree) return true;
    final chartId = state.context?.chartId;
    if (chartId == null) return false;
    final base = '$chartId:${section.groupSlug}:${section.sectionSlug}';
    return state.unlockedKeys.contains(base) ||
        state.unlockedKeys.contains('$base:${state.mode.apiValue}');
  }

  Future<bool> saveCurrentChart() async {
    final context = state.context;
    final request = context?.request;
    final result = context?.generatedResult;
    if (context == null ||
        context.isSaved ||
        request == null ||
        result == null) {
      return context?.isSaved ?? false;
    }
    if (state.isSavingChart) return false;
    state = state.copyWith(isSavingChart: true, clearError: true);
    try {
      final id = await ref.read(chartRepositoryProvider).save(request, result);
      if (id.trim().isEmpty) {
        throw const ChartException('Máy chủ không trả về mã lá số đã lưu.');
      }
      state = state.copyWith(
        context: context.copyWith(chartId: id),
        isSavingChart: false,
      );
      ref.read(chartGenerationControllerProvider.notifier).markSaved(id);
      try {
        await ref.read(authControllerProvider.notifier).refreshProfile();
      } catch (_) {
        // Lá số đã được lưu thành công; lỗi làm mới hồ sơ không được biến
        // giao dịch thành thất bại hoặc khiến người dùng lưu trùng.
      }
      loadUnlocks();
      return true;
    } on ChartException catch (error) {
      state = state.copyWith(isSavingChart: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSavingChart: false,
        errorMessage: 'Không thể lưu lá số. Vui lòng thử lại.',
      );
      return false;
    }
  }

  Future<ReadingUnlockResult?> unlock(ReadingSection section) async {
    final context = state.context;
    if (context == null ||
        !context.isSaved ||
        state.unlockingSectionId != null) {
      return null;
    }
    if (isUnlocked(section)) {
      return ReadingUnlockResult(
        wasAlreadyUnlocked: true,
        balance: null,
        cost: 0,
        saveCost: 0,
        unlockedKeys: state.unlockedKeys,
      );
    }
    _unlockToken?.cancel('Yêu cầu mở khóa mới');
    final token = CancelToken();
    _unlockToken = token;
    final session = _session;
    state = state.copyWith(unlockingSectionId: section.id, clearError: true);
    try {
      final result = await ref
          .read(interpretationRepositoryProvider)
          .unlock(
            chartId: context.chartId!,
            mode: state.mode,
            section: section,
            cancelToken: token,
          );
      if (!_isCurrent(session, token)) return null;
      state = state.copyWith(
        unlockedKeys: result.unlockedKeys.isEmpty
            ? state.unlockedKeys
            : result.unlockedKeys,
        clearUnlockingSection: true,
      );
      try {
        await ref.read(authControllerProvider.notifier).refreshProfile();
      } catch (_) {
        // Quyền mở khóa từ response vẫn là nguồn sự thật của giao dịch này.
      }
      await loadInterpretation(force: true);
      return result;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return null;
      state = state.copyWith(
        clearUnlockingSection: true,
        errorMessage: error.userMessage,
      );
      return null;
    } on InterpretationException catch (error) {
      if (session != _session) return null;
      state = state.copyWith(
        clearUnlockingSection: true,
        errorMessage: error.message,
      );
      return null;
    } catch (_) {
      if (session != _session) return null;
      state = state.copyWith(
        clearUnlockingSection: true,
        errorMessage: 'Không thể hoàn tất mở khóa. Vui lòng tải lại quyền đọc.',
      );
      return null;
    }
  }

  void _setTaskError(
    String message, {
    bool sections = false,
    bool unlocks = false,
    bool interpretation = false,
  }) {
    state = state.copyWith(
      isLoadingSections: sections ? false : state.isLoadingSections,
      isLoadingUnlocks: unlocks ? false : state.isLoadingUnlocks,
      isLoadingInterpretation: interpretation
          ? false
          : state.isLoadingInterpretation,
      errorMessage: message,
    );
  }

  bool _isCurrent(int session, CancelToken token) =>
      session == _session && !token.isCancelled;

  void _cancelAll() {
    _chartToken?.cancel();
    _sectionsToken?.cancel();
    _unlocksToken?.cancel();
    _contentToken?.cancel();
    _unlockToken?.cancel();
  }

  static String? _notEmpty(String? value) =>
      value == null || value.trim().isEmpty ? null : value;
}

final interpretationControllerProvider =
    NotifierProvider<InterpretationController, InterpretationState>(
      InterpretationController.new,
    );
