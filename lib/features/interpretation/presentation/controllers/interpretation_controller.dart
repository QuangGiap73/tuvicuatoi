import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../horoscope/data/chart_repository.dart';
import '../../../horoscope/domain/chart_request.dart';
import '../../../horoscope/domain/chart_result.dart';
import '../../../horoscope/domain/saved_chart.dart';
import '../../../horoscope/presentation/providers/chart_form_providers.dart';
import '../../../wallet/presentation/transaction_history_controller.dart';
import '../../../wallet/presentation/wallet_controller.dart';
import '../../application/chart_session_service.dart';
import '../../application/interpretation_content_service.dart';
import '../../application/reading_catalog_service.dart';
import '../../application/reading_unlock_service.dart';
import '../../data/interpretation_repository.dart';
import '../../domain/interpretation_models.dart';
import '../../domain/interpretation_section_content_resolver.dart';
import '../../domain/section_content.dart';
import '../state/interpretation_state.dart';

class InterpretationController extends Notifier<InterpretationState> {
  static const _chartSessions = ChartSessionService();
  static const _catalogs = ReadingCatalogService();
  static const _contentResolver = InterpretationSectionContentResolver();
  CancelToken? _chartToken;
  CancelToken? _sectionsToken;
  CancelToken? _unlocksToken;
  CancelToken? _contentToken;
  CancelToken? _unlockToken;
  int _session = 0;
  final Map<String, Map<InterpretationMode, InterpretationData>> _contentCache =
      {};
  final Map<String, Map<InterpretationMode, Set<ReadingSectionKey>>>
  _permissionCache = {};
  final Map<String, Map<String, UnlockStatus>> _unlockStatusCache = {};

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
    final chartId = _notEmpty(savedChartId);
    if (chartId != null) {
      openSaved(
        SavedChart(
          id: chartId,
          name: result.fullName,
          gender: result.gender,
          solarDate: result.solarDate,
          lunarDate: result.lunarDate,
          createdAt: '',
          hourBranch: result.hourBranch,
          menh: result.menh,
          cuc: result.cuc,
          chartData: result.rawData,
        ),
      );
      return;
    }
    final context = InterpretationChartContext(
      name: result.fullName,
      chartId: null,
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
    final hasCachedChartData = chart.chartData.isNotEmpty;
    state = InterpretationState(
      context: InterpretationChartContext(
        name: chart.displayName,
        chartId: chart.id,
        chartData: chart.chartData,
        savedSummary: chart,
      ),
      contentByMode: _cachedContent(chart.id),
      canonicalUnlockedKeys: _cachedPermissions(chart.id),
      unlockStatusBySection: _cachedUnlockStatuses(chart.id),
      isLoadingChart: !hasCachedChartData,
    );
    if (hasCachedChartData) _loadAll(session);
    _loadSavedChart(chart, session, usedCachedChartData: hasCachedChartData);
  }

  Future<void> _loadSavedChart(
    SavedChart chart,
    int session, {
    required bool usedCachedChartData,
  }) async {
    final token = CancelToken();
    _chartToken = token;
    try {
      final detail = await ref
          .read(chartRepositoryProvider)
          .getChartDetail(chart, cancelToken: token);
      if (!_isCurrent(session, token)) return;
      final chartData = _chartSessions.mergeChartData(
        chart.chartData,
        detail.chartData,
      );
      final context = InterpretationChartContext(
        name: detail.summary.displayName,
        chartId: detail.summary.id,
        chartData: chartData,
        savedSummary: detail.summary,
      );
      state = state.copyWith(
        context: context,
        isLoadingChart: false,
        clearChartError: true,
      );
      if (usedCachedChartData) {
        loadInterpretation(session: session, force: true);
      } else {
        _loadAll(session);
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || session != _session) return;
      _useSavedChartFallback(
        chart,
        session,
        error.userMessage,
        dataAlreadyLoaded: usedCachedChartData,
      );
    } on ChartException catch (error) {
      if (session != _session) return;
      _useSavedChartFallback(
        chart,
        session,
        error.message,
        dataAlreadyLoaded: usedCachedChartData,
      );
    }
  }

  void _setChartError(String message) {
    state = state.copyWith(isLoadingChart: false, chartError: message);
  }

  void _useSavedChartFallback(
    SavedChart chart,
    int session,
    String errorMessage, {
    required bool dataAlreadyLoaded,
  }) {
    if (session != _session) return;
    if (chart.chartData.isEmpty) {
      _setChartError(errorMessage);
      return;
    }
    state = state.copyWith(
      context: InterpretationChartContext(
        name: chart.displayName,
        chartId: chart.id,
        chartData: chart.chartData,
        savedSummary: chart,
      ),
      isLoadingChart: false,
      clearChartError: true,
    );
    if (!dataAlreadyLoaded) _loadAll(session);
  }

  void _start(InterpretationChartContext context) {
    _cancelAll();
    final session = ++_session;
    final chartId = context.chartId;
    state = InterpretationState(
      context: context,
      contentByMode: chartId == null ? const {} : _cachedContent(chartId),
      canonicalUnlockedKeys: chartId == null
          ? const {}
          : _cachedPermissions(chartId),
      unlockStatusBySection: chartId == null
          ? const {}
          : _cachedUnlockStatuses(chartId),
    );
    _loadAll(session);
  }

  void _loadAll(int session) {
    loadSections(session: session);
    loadInterpretation(
      session: session,
      force: state.contentByMode.containsKey(state.mode),
    );
  }

  Future<void> loadSections({
    int? session,
    bool preserveConfirmedPermissions = false,
  }) async {
    final activeSession = session ?? _session;
    _sectionsToken?.cancel('Đang tải danh mục mới');
    final token = CancelToken();
    _sectionsToken = token;
    state = state.copyWith(isLoadingSections: true, clearCatalogError: true);
    try {
      final chartId = state.context?.chartId;
      final catalog = await ref
          .read(interpretationRepositoryProvider)
          .getCatalog(chartId: chartId, cancelToken: token);
      if (!_isCurrent(activeSession, token)) return;
      final catalogHasPermissionState =
          chartId != null &&
          (catalog.allUnlocked ||
              catalog.sections.every((section) => section.hasUnlockState));
      var catalogPermissions = chartId == null
          ? const <ReadingSectionKey>{}
          : catalogHasPermissionState
          ? _catalogs.permissionsFromCatalog(
              chartId: chartId,
              catalog: catalog,
              currentMode: state.mode,
            )
          : state.canonicalUnlockedKeys;
      if (preserveConfirmedPermissions && chartId != null) {
        catalogPermissions = Set.unmodifiable({
          ...state.canonicalUnlockedKeys,
          ...catalogPermissions,
        });
      }
      if (chartId != null && catalogHasPermissionState) {
        _cachePermissions(chartId, catalogPermissions);
      }
      final reconciledStatuses = _catalogs.reconcileStatuses(
        state.unlockStatusBySection,
        catalogPermissions,
      );
      state = state.copyWith(
        catalog: catalog,
        sections: catalog.sections,
        canonicalUnlockedKeys: catalogPermissions,
        unlockStatusBySection: reconciledStatuses,
        isLoadingSections: false,
      );
      if (chartId != null &&
          !catalogHasPermissionState &&
          !preserveConfirmedPermissions) {
        await loadUnlocks(session: activeSession);
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      _setTaskError(error.userMessage, sections: true);
    } on InterpretationException catch (error) {
      if (activeSession != _session) return;
      _setTaskError(error.message, sections: true);
    }
  }

  Future<Set<ReadingSectionKey>?> loadUnlocks({int? session}) async {
    final chartId = state.context?.chartId;
    if (chartId == null) return null;
    final activeSession = session ?? _session;
    _unlocksToken?.cancel('Đang tải quyền đọc mới');
    final token = CancelToken();
    _unlocksToken = token;
    state = state.copyWith(isLoadingUnlocks: true, clearPermissionError: true);
    try {
      final rawKeys = await ref
          .read(interpretationRepositoryProvider)
          .getUnlocks(chartId: chartId, cancelToken: token);
      if (!_isCurrent(activeSession, token) ||
          state.context?.chartId != chartId) {
        return null;
      }
      final snapshot = ReadingUnlockSnapshot.fromRaw(
        rawKeys,
        expectedChartId: chartId,
      );
      _debugLegacyUnlocks(snapshot);
      final canonicalPermissions = _applyModeSharingPolicy(
        snapshot.canonicalKeys,
      );
      _cachePermissions(chartId, canonicalPermissions);
      final reconciledStatuses = _catalogs.reconcileStatuses(
        state.unlockStatusBySection,
        canonicalPermissions,
      );
      _unlockStatusCache[chartId] = {...reconciledStatuses};
      state = state.copyWith(
        canonicalUnlockedKeys: canonicalPermissions,
        legacyUnlockKeys: snapshot.legacyKeys,
        unlockStatusBySection: reconciledStatuses,
        isLoadingUnlocks: false,
        clearUnlockError: !reconciledStatuses.values.contains(
          UnlockStatus.syncing,
        ),
      );
      return canonicalPermissions;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return null;
      _setTaskError(error.userMessage, unlocks: true);
      return null;
    } on InterpretationException catch (error) {
      if (activeSession != _session) return null;
      _setTaskError(error.message, unlocks: true);
      return null;
    }
  }

  Future<void> loadInterpretation({int? session, bool force = false}) async {
    final context = state.context;
    if (context == null) return;
    final activeSession = session ?? _session;
    final mode = state.mode;
    if (!force && state.contentByMode.containsKey(mode)) return;
    _contentToken?.cancel('Đổi chế độ luận giải');
    final token = CancelToken();
    _contentToken = token;
    state = state.copyWith(
      isLoadingInterpretation: true,
      clearContentError: true,
    );
    final contentService = InterpretationContentService(
      ref.read(interpretationRepositoryProvider),
    );
    try {
      String? contentWarning;
      InterpretationData content;
      if (force) {
        // Quyền đọc và nội dung là hai nguồn độc lập. Sau khi mở khóa, tải cả
        // snapshot đã lưu lẫn bản sinh mới rồi chọn nội dung chi tiết hơn.
        Object? generatedError;
        InterpretationData generated = const InterpretationData();
        try {
          generated = await contentService.generateIfPossible(
            context: context,
            mode: mode,
            cancelToken: token,
          );
        } catch (error) {
          generatedError = error;
        }
        final saved = await contentService.loadSavedOrEmpty(
          context: context,
          cancelToken: token,
        );
        content = generated.mergeDetailed(saved);
        if (content.isEmpty && generatedError != null) {
          Error.throwWithStackTrace(generatedError, StackTrace.current);
        } else if (generatedError != null) {
          contentWarning = _contentFallbackMessage(generatedError);
        }
      } else if (context.isSaved && mode == InterpretationMode.deep) {
        Object? generatedError;
        InterpretationData generated = const InterpretationData();
        try {
          generated = await contentService.generateIfPossible(
            context: context,
            mode: mode,
            cancelToken: token,
          );
        } catch (error) {
          generatedError = error;
        }
        final saved = await contentService.loadSavedOrEmpty(
          context: context,
          cancelToken: token,
        );
        content = generated.mergeDetailed(saved);
        if (content.isEmpty && generatedError != null) {
          Error.throwWithStackTrace(generatedError, StackTrace.current);
        } else if (generatedError != null) {
          contentWarning = _contentFallbackMessage(generatedError);
        }
      } else {
        try {
          content = await contentService.generateIfPossible(
            context: context,
            mode: mode,
            cancelToken: token,
          );
        } catch (error) {
          final saved = await contentService.loadSavedOrEmpty(
            context: context,
            cancelToken: token,
          );
          if (saved.isEmpty) rethrow;
          content = saved;
          contentWarning = _contentFallbackMessage(error);
        }
      }
      if (!_isCurrent(activeSession, token) || state.mode != mode) return;
      final chartId = context.chartId;
      if (chartId != null) _cacheContent(chartId, mode, content);
      state = state.copyWith(
        contentByMode: Map.unmodifiable({
          ...state.contentByMode,
          mode: content,
        }),
        contentRevision: state.contentRevision + 1,
        isLoadingInterpretation: false,
        contentError: contentWarning,
        clearContentError: contentWarning == null,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      _setTaskError(error.userMessage, interpretation: true);
    } on InterpretationException catch (error) {
      if (activeSession != _session) return;
      _setTaskError(error.message, interpretation: true);
    }
  }

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
      clearContentError: true,
    );
    // Hiển thị cache theo chartId + mode ngay; chỉ gọi mạng nếu chế độ mới
    // chưa có dữ liệu để thao tác chuyển qua lại luôn mượt.
    loadInterpretation();
  }

  bool isUnlocked(ReadingSection section) {
    if (section.isFree ||
        section.isUnlocked ||
        state.catalog?.allUnlocked == true) {
      return true;
    }
    final chartId = state.context?.chartId;
    if (chartId == null) return false;
    return state.canonicalUnlockedKeys.contains(
      ReadingSectionKey(
        chartId: chartId,
        mode: state.mode,
        groupSlug: section.groupSlug,
        sectionSlug: section.sectionSlug,
      ),
    );
  }

  bool hasReadableContent(ReadingSection section) {
    final interpretation = state.interpretation;
    final chartData = state.context?.chartData;
    if (interpretation == null || chartData == null) return false;
    final content = _contentResolver.resolve(
      section: section,
      interpretation: interpretation,
      chartData: chartData,
    );
    return content.fullContent?.trim().isNotEmpty == true &&
        !content.isFallback &&
        content.source != ContentSource.catalogSummary &&
        content.source != ContentSource.unavailable;
  }

  UnlockStatus statusFor(ReadingSection section) {
    final key = _sectionKey(section);
    final tracked = key == null ? null : state.unlockStatusBySection[key.value];
    if (tracked == UnlockStatus.confirming ||
        tracked == UnlockStatus.submitting ||
        tracked == UnlockStatus.syncing) {
      return tracked!;
    }
    if (isUnlocked(section)) {
      return hasReadableContent(section)
          ? UnlockStatus.unlocked
          : UnlockStatus.syncing;
    }
    return key == null ? UnlockStatus.idle : tracked ?? UnlockStatus.idle;
  }

  Future<bool> syncUnlockedContent(ReadingSection section) async {
    final key = _sectionKey(section);
    if (key == null || !isUnlocked(section)) return false;
    if (hasReadableContent(section)) {
      _setUnlockStatuses([key], UnlockStatus.unlocked, clearError: true);
      return true;
    }
    if (_unlockToken == null || _unlockToken!.isCancelled) {
      _unlockToken = CancelToken();
    }
    final session = _session;
    _setUnlockStatuses([key], UnlockStatus.syncing, clearError: true);
    final ready = await _waitForUnlockedContent([section], session: session);
    if (session != _session) return false;
    _setUnlockStatuses(
      [key],
      ready ? UnlockStatus.unlocked : UnlockStatus.syncing,
      clearError: ready,
      error: ready
          ? null
          : 'Quyền đọc đã được ghi nhận nhưng nội dung vẫn đang đồng bộ.',
    );
    return ready;
  }

  bool canPurchase(ReadingSection section) {
    final status = statusFor(section);
    return !section.isFree &&
        status != UnlockStatus.confirming &&
        status != UnlockStatus.submitting &&
        status != UnlockStatus.syncing &&
        status != UnlockStatus.unlocked;
  }

  void beginUnlockConfirmation(ReadingSection section) {
    final key = _sectionKey(section);
    if (key == null || _preventsPayment(statusFor(section))) return;
    _setUnlockStatuses([key], UnlockStatus.confirming, clearError: true);
  }

  void cancelUnlockConfirmation(ReadingSection section) {
    final key = _sectionKey(section);
    if (key == null || statusFor(section) != UnlockStatus.confirming) return;
    _setUnlockStatuses([key], UnlockStatus.idle);
  }

  void beginBundleUnlockConfirmation(Iterable<ReadingSection> sections) {
    final keys = sections
        .where(canPurchase)
        .map(_sectionKey)
        .whereType<ReadingSectionKey>();
    _setUnlockStatuses(keys, UnlockStatus.confirming, clearError: true);
  }

  void cancelBundleUnlockConfirmation(Iterable<ReadingSection> sections) {
    final keys = sections
        .map(_sectionKey)
        .whereType<ReadingSectionKey>()
        .where(
          (key) =>
              state.unlockStatusBySection[key.value] == UnlockStatus.confirming,
        );
    _setUnlockStatuses(keys, UnlockStatus.idle);
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
    state = state.copyWith(isSavingChart: true, clearChartError: true);
    try {
      final receipt = await ref
          .read(chartRepositoryProvider)
          .saveWithReceipt(request, result);
      final id = receipt.chartId;
      if (id.trim().isEmpty) {
        throw const ChartException('Máy chủ không trả về mã lá số đã lưu.');
      }
      final fallback = SavedChart(
        id: id,
        name: result.fullName,
        gender: result.gender,
        solarDate: result.solarDate,
        lunarDate: result.lunarDate,
        createdAt: '',
        hourBranch: result.hourBranch,
        menh: result.menh,
        cuc: result.cuc,
        chartData: result.rawData,
      );
      var savedSummary = fallback;
      var savedChartData = context.chartData;
      try {
        final detail = await ref
            .read(chartRepositoryProvider)
            .getChartDetail(fallback);
        savedSummary = detail.summary;
        savedChartData = _chartSessions.mergeChartData(
          context.chartData,
          detail.chartData,
        );
      } on ChartException {
        // Việc lưu đã thành công. Giữ dữ liệu vừa lập làm fallback; lần mở
        // sau từ danh sách lá số vẫn tải lại bản chuẩn hóa từ backend.
      }
      state = state.copyWith(
        context: context.copyWith(
          chartId: id,
          chartData: savedChartData,
          savedSummary: savedSummary,
        ),
        isSavingChart: false,
      );
      ref.read(chartGenerationControllerProvider.notifier).markSaved(id);
      ref.invalidate(myChartsControllerProvider);
      ref
          .read(authControllerProvider.notifier)
          .applyChartSave(
            coinBalance: receipt.coinBalance,
            savedChartsCount: receipt.savedChartsCount,
            maxSavedCharts: receipt.maxSavedCharts,
          );
      if (receipt.coinBalance != null) {
        ref
            .read(walletControllerProvider.notifier)
            .applyBalance(receipt.coinBalance!);
      }
      if (receipt.usedCoins) {
        ref.invalidate(transactionHistoryControllerProvider);
      }
      try {
        await ref.read(authControllerProvider.notifier).refreshProfile();
      } catch (_) {
        // Lá số đã được lưu thành công; lỗi làm mới hồ sơ không được biến
        // giao dịch thành thất bại hoặc khiến người dùng lưu trùng.
      }
      await loadSections();
      await loadInterpretation(force: true);
      return true;
    } on ChartException catch (error) {
      state = state.copyWith(isSavingChart: false, chartError: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSavingChart: false,
        chartError: 'Không thể lưu lá số. Vui lòng thử lại.',
      );
      return false;
    }
  }

  Future<ReadingUnlockResult?> unlock(ReadingSection section) async {
    final context = state.context;
    if (context == null || !context.isSaved || _hasSubmittingUnlock) {
      return null;
    }
    if (isUnlocked(section)) {
      return ReadingUnlockResult(
        wasAlreadyUnlocked: true,
        balance: null,
        cost: 0,
        saveCost: 0,
        unlockedKeys: state.canonicalUnlockedKeys
            .map((key) => key.value)
            .toSet(),
      );
    }
    final key = _sectionKey(section);
    final currentStatus = statusFor(section);
    if (key == null ||
        currentStatus == UnlockStatus.submitting ||
        currentStatus == UnlockStatus.syncing ||
        currentStatus == UnlockStatus.unlocked) {
      return null;
    }
    _unlockToken?.cancel('Yêu cầu mở khóa mới');
    final token = CancelToken();
    _unlockToken = token;
    final session = _session;
    final mode = state.mode;
    _setUnlockStatuses([key], UnlockStatus.submitting, clearError: true);
    try {
      final result = await ref
          .read(interpretationRepositoryProvider)
          .unlock(
            chartId: context.chartId!,
            mode: mode,
            section: section,
            cancelToken: token,
          );
      if (!_isCurrent(session, token)) return null;
      // POST không phải nguồn cấp quyền. Các key trong response chỉ được phân
      // tích để chẩn đoán; UI chỉ mở sau khi GET permissions xác nhận.
      final snapshot = ReadingUnlockSnapshot.fromRaw(
        result.unlockedKeys,
        expectedChartId: context.chartId!,
      );
      _debugLegacyUnlocks(snapshot);
      _setUnlockStatuses([key], UnlockStatus.syncing);
      try {
        await ref.read(authControllerProvider.notifier).refreshProfile();
      } catch (_) {
        // Giao dịch đã được POST thành công; lỗi refresh số dư không đổi kết quả.
      }
      final permissionPoll = await _waitForUnlockPermissions([
        key,
      ], session: session);
      if (!_isCurrent(session, token)) return result;
      if (permissionPoll?.permissions.contains(key) == true) {
        _invalidateSharedModeContent(mode);
        final contentReady = await _waitForUnlockedContent([
          section,
        ], session: session);
        if (!_isCurrent(session, token)) return result;
        _publishPermissionPoll(context.chartId!, permissionPoll!);
        await loadSections(
          session: session,
          preserveConfirmedPermissions: true,
        );
        _setUnlockStatuses(
          [key],
          contentReady ? UnlockStatus.unlocked : UnlockStatus.syncing,
          clearError: contentReady,
          error: contentReady
              ? null
              : 'Đã mở khóa, đang đồng bộ nội dung đầy đủ. Vui lòng thử lại sau giây lát.',
        );
      } else {
        if (permissionPoll != null) {
          _publishPermissionPoll(context.chartId!, permissionPoll);
        }
        _setUnlockStatuses(
          [key],
          UnlockStatus.syncing,
          error:
              'Đã thanh toán, đang đồng bộ quyền đọc. Vui lòng tải lại quyền.',
        );
      }
      return result;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return null;
      _setUnlockStatuses([key], UnlockStatus.failed, error: error.userMessage);
      return null;
    } on InterpretationException catch (error) {
      if (session != _session) return null;
      _setUnlockStatuses(
        [key],
        error.statusCode == null ? UnlockStatus.syncing : UnlockStatus.failed,
        error: error.statusCode == null
            ? 'Đang xác minh giao dịch. Vui lòng tải lại quyền đọc.'
            : error.message,
      );
      return null;
    } catch (_) {
      if (session != _session) return null;
      _setUnlockStatuses(
        [key],
        UnlockStatus.syncing,
        error: 'Đang xác minh giao dịch. Vui lòng tải lại quyền đọc.',
      );
      return null;
    }
  }

  Future<ReadingUnlockResult?> unlockBundle(
    List<ReadingSection> sections, {
    String? voucherCode,
  }) async {
    final context = state.context;
    if (context == null || !context.isSaved || _hasSubmittingUnlock) {
      return null;
    }
    final pending = sections
        .where((section) {
          final status = statusFor(section);
          return !section.isFree &&
              !isUnlocked(section) &&
              status != UnlockStatus.submitting &&
              status != UnlockStatus.syncing &&
              status != UnlockStatus.unlocked;
        })
        .toList(growable: false);
    if (pending.isEmpty) {
      if (sections.any(
        (section) => statusFor(section) == UnlockStatus.syncing,
      )) {
        state = state.copyWith(
          unlockError:
              'Đã thanh toán, đang đồng bộ quyền đọc. Vui lòng tải lại quyền.',
        );
        return null;
      }
      return ReadingUnlockResult(
        wasAlreadyUnlocked: true,
        balance: null,
        cost: 0,
        saveCost: 0,
        unlockedKeys: state.canonicalUnlockedKeys
            .map((key) => key.value)
            .toSet(),
      );
    }

    _unlockToken?.cancel('Yêu cầu mở khóa bundle mới');
    final token = CancelToken();
    _unlockToken = token;
    final session = _session;
    final mode = state.mode;
    final allLocked = state.sections
        .where((section) => !section.isFree && !isUnlocked(section))
        .toList(growable: false);
    final pendingSlugs = pending.map((section) => section.sectionSlug).toSet();
    final unlocksAll =
        allLocked.isNotEmpty &&
        allLocked.every(
          (section) => pendingSlugs.contains(section.sectionSlug),
        );
    final groupSlugs = pending.map((section) => section.groupSlug).toSet();
    final scope = unlocksAll
        ? 'all'
        : groupSlugs.length == 1
        ? 'tab'
        : 'bundle';
    final keys = pending
        .map(_sectionKey)
        .whereType<ReadingSectionKey>()
        .toList();
    _setUnlockStatuses(keys, UnlockStatus.submitting, clearError: true);
    try {
      final result = await ref
          .read(interpretationRepositoryProvider)
          .unlockBundle(
            chartId: context.chartId!,
            mode: mode,
            sections: pending,
            scope: scope,
            voucherCode: voucherCode,
            cancelToken: token,
          );
      if (!_isCurrent(session, token)) return null;
      final snapshot = ReadingUnlockSnapshot.fromRaw(
        result.unlockedKeys,
        expectedChartId: context.chartId!,
      );
      _debugLegacyUnlocks(snapshot);
      _setUnlockStatuses(keys, UnlockStatus.syncing);
      try {
        await ref.read(authControllerProvider.notifier).refreshProfile();
      } catch (_) {
        // Giao dịch đã được POST thành công; lỗi refresh số dư không đổi kết quả.
      }
      final permissionPoll = await _waitForUnlockPermissions(
        keys,
        session: session,
      );
      if (!_isCurrent(session, token)) return result;
      final unresolved = keys
          .where((key) => permissionPoll?.permissions.contains(key) != true)
          .toList(growable: false);
      final resolved = keys
          .where((key) => permissionPoll?.permissions.contains(key) == true)
          .toList(growable: false);
      var resolvedContentReady = false;
      if (resolved.isNotEmpty) {
        _invalidateSharedModeContent(mode);
        final resolvedSections = pending
            .where((section) {
              final sectionKey = _sectionKey(section);
              return sectionKey != null && resolved.contains(sectionKey);
            })
            .toList(growable: false);
        resolvedContentReady = await _waitForUnlockedContent(
          resolvedSections,
          session: session,
        );
        if (!_isCurrent(session, token)) return result;
      }
      if (permissionPoll != null) {
        _publishPermissionPoll(context.chartId!, permissionPoll);
      }
      if (resolved.isNotEmpty) {
        await loadSections(
          session: session,
          preserveConfirmedPermissions: true,
        );
        _setUnlockStatuses(
          resolved,
          resolvedContentReady ? UnlockStatus.unlocked : UnlockStatus.syncing,
          error: !resolvedContentReady
              ? 'Đã mở khóa, đang đồng bộ nội dung đầy đủ. Vui lòng thử lại sau giây lát.'
              : null,
        );
      }
      if (unresolved.isEmpty && resolvedContentReady) {
        state = state.copyWith(clearUnlockError: true);
      } else {
        _setUnlockStatuses(
          unresolved,
          UnlockStatus.syncing,
          error:
              'Đã thanh toán, đang đồng bộ quyền đọc. Vui lòng tải lại quyền.',
        );
      }
      return result;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return null;
      _setUnlockStatuses(keys, UnlockStatus.failed, error: error.userMessage);
      return null;
    } on InterpretationException catch (error) {
      if (session != _session) return null;
      _setUnlockStatuses(
        keys,
        error.statusCode == null ? UnlockStatus.syncing : UnlockStatus.failed,
        error: error.statusCode == null
            ? 'Đang xác minh giao dịch. Vui lòng tải lại quyền đọc.'
            : error.message,
      );
      return null;
    } catch (_) {
      if (session != _session) return null;
      _setUnlockStatuses(
        keys,
        UnlockStatus.syncing,
        error: 'Đang xác minh giao dịch. Vui lòng tải lại quyền đọc.',
      );
      return null;
    }
  }

  Future<bool> _waitForUnlockedContent(
    List<ReadingSection> sections, {
    required int session,
  }) async {
    if (sections.isEmpty) return true;
    const delays = <Duration>[
      Duration.zero,
      Duration(milliseconds: 400),
      Duration(milliseconds: 900),
      Duration(milliseconds: 1600),
    ];
    for (final delay in delays) {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      if (session != _session || _unlockToken?.isCancelled != false) {
        return false;
      }
      await loadInterpretation(session: session, force: true);
      if (session != _session) return false;
      if (sections.every(hasReadableContent)) return true;
    }
    return false;
  }

  Future<ReadingUnlockPollResult?> _waitForUnlockPermissions(
    Iterable<ReadingSectionKey> expectedKeys, {
    required int session,
  }) async {
    final chartId = state.context?.chartId;
    final unlockToken = _unlockToken;
    if (chartId == null || unlockToken == null) return null;
    final result =
        await ReadingUnlockService(
          ref.read(interpretationRepositoryProvider),
        ).waitForPermissions(
          chartId: chartId,
          expectedKeys: expectedKeys.toSet(),
          shareAcrossModes: state.catalog?.pricing.buyOneGetBothModes == true,
          isCurrent: () => session == _session && !unlockToken.isCancelled,
          cancelToken: unlockToken,
        );
    if (session != _session) return result;
    return result;
  }

  void _publishPermissionPoll(String chartId, ReadingUnlockPollResult result) {
    final permissions = result.permissions;
    _debugLegacyUnlocks(
      ReadingUnlockSnapshot(
        canonicalKeys: permissions,
        legacyKeys: result.legacyKeys,
      ),
    );
    _cachePermissions(chartId, permissions);
    final statuses = _catalogs.reconcileStatuses(
      state.unlockStatusBySection,
      permissions,
    );
    _unlockStatusCache[chartId] = {...statuses};
    state = state.copyWith(
      canonicalUnlockedKeys: permissions,
      legacyUnlockKeys: result.legacyKeys,
      unlockStatusBySection: statuses,
      isLoadingUnlocks: false,
      clearPermissionError: true,
    );
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
      catalogError: sections ? message : null,
      permissionError: unlocks ? message : null,
      contentError: interpretation ? message : null,
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

  static String _contentFallbackMessage(Object error) {
    final detail = switch (error) {
      InterpretationException exception => exception.message,
      DioException exception => exception.userMessage,
      _ => error.toString(),
    };
    return 'Đang hiển thị nội dung dự phòng vì chưa tải được bản luận giải '
        'cá nhân đầy đủ. $detail';
  }

  ReadingSectionKey? _sectionKey(ReadingSection section) {
    final chartId = state.context?.chartId;
    if (chartId == null) return null;
    return ReadingSectionKey(
      chartId: chartId,
      mode: state.mode,
      groupSlug: section.groupSlug,
      sectionSlug: section.sectionSlug,
    );
  }

  bool get _hasSubmittingUnlock => state.unlockStatusBySection.values.any(
    (status) => status == UnlockStatus.submitting,
  );

  static bool _preventsPayment(UnlockStatus status) =>
      status == UnlockStatus.confirming ||
      status == UnlockStatus.submitting ||
      status == UnlockStatus.syncing ||
      status == UnlockStatus.unlocked;

  void _setUnlockStatuses(
    Iterable<ReadingSectionKey> keys,
    UnlockStatus status, {
    String? error,
    bool clearError = false,
  }) {
    final next = <String, UnlockStatus>{...state.unlockStatusBySection};
    for (final key in keys) {
      next[key.value] = status;
      final cached = _unlockStatusCache.putIfAbsent(key.chartId, () => {});
      cached[key.value] = status;
    }
    state = state.copyWith(
      unlockStatusBySection: Map.unmodifiable(next),
      unlockError: error,
      clearUnlockError: clearError,
    );
  }

  Map<InterpretationMode, InterpretationData> _cachedContent(String chartId) =>
      Map.unmodifiable(_contentCache[chartId] ?? const {});

  Set<ReadingSectionKey> _cachedPermissions(String chartId) => Set.unmodifiable(
    (_permissionCache[chartId]?.values ?? const <Set<ReadingSectionKey>>[])
        .expand((keys) => keys),
  );

  Map<String, UnlockStatus> _cachedUnlockStatuses(String chartId) =>
      Map.unmodifiable(_unlockStatusCache[chartId] ?? const {});

  void _cacheContent(
    String chartId,
    InterpretationMode mode,
    InterpretationData content,
  ) {
    final byMode = _contentCache.putIfAbsent(chartId, () => {});
    byMode[mode] = content;
  }

  void _cachePermissions(String chartId, Set<ReadingSectionKey> permissions) {
    final byMode = <InterpretationMode, Set<ReadingSectionKey>>{};
    for (final mode in InterpretationMode.values) {
      byMode[mode] = Set.unmodifiable(
        permissions.where((key) => key.mode == mode),
      );
    }
    _permissionCache[chartId] = Map.unmodifiable(byMode);
  }

  Set<ReadingSectionKey> _applyModeSharingPolicy(
    Set<ReadingSectionKey> permissions,
  ) {
    if (state.catalog?.pricing.buyOneGetBothModes != true) {
      return permissions;
    }
    return ReadingUnlockService.sharePermissionsAcrossModes(permissions);
  }

  void _invalidateSharedModeContent(InterpretationMode purchasedMode) {
    if (state.catalog?.pricing.buyOneGetBothModes != true) return;
    final chartId = state.context?.chartId;
    final retained = <InterpretationMode, InterpretationData>{
      for (final entry in state.contentByMode.entries)
        if (entry.key == purchasedMode) entry.key: entry.value,
    };
    if (chartId != null) {
      final cached = _contentCache[chartId];
      if (cached != null) {
        cached.removeWhere((mode, _) => mode != purchasedMode);
      }
    }
    state = state.copyWith(contentByMode: Map.unmodifiable(retained));
  }

  static void _debugLegacyUnlocks(ReadingUnlockSnapshot snapshot) {
    if (!kDebugMode || snapshot.legacyKeys.isEmpty) return;
    final counts = <LegacyUnlockKeyKind, int>{};
    for (final key in snapshot.legacyKeys) {
      counts.update(key.kind, (value) => value + 1, ifAbsent: () => 1);
    }
    debugPrint(
      '[Interpretation] Ignored ${snapshot.legacyKeys.length} legacy unlock '
      'keys: $counts',
    );
  }
}

final interpretationControllerProvider =
    NotifierProvider<InterpretationController, InterpretationState>(
      InterpretationController.new,
    );
