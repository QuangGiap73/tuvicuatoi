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
      final chartData = _mergeChartData(chart.chartData, detail.chartData);
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
    final chartId = state.context?.chartId;
    if (chartId != null) loadUnlocks(session: session);
    loadInterpretation(
      session: session,
      force: state.contentByMode.containsKey(state.mode),
    );
  }

  Future<void> loadSections({int? session}) async {
    final activeSession = session ?? _session;
    _sectionsToken?.cancel('Đang tải danh mục mới');
    final token = CancelToken();
    _sectionsToken = token;
    state = state.copyWith(isLoadingSections: true, clearCatalogError: true);
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
      _cachePermissions(chartId, snapshot.canonicalKeys);
      final reconciledStatuses = _reconcileUnlockStatuses(
        state.unlockStatusBySection,
        snapshot.canonicalKeys,
      );
      _unlockStatusCache[chartId] = {...reconciledStatuses};
      state = state.copyWith(
        canonicalUnlockedKeys: snapshot.canonicalKeys,
        legacyUnlockKeys: snapshot.legacyKeys,
        unlockStatusBySection: reconciledStatuses,
        isLoadingUnlocks: false,
        clearUnlockError: !reconciledStatuses.values.contains(
          UnlockStatus.syncing,
        ),
      );
      return snapshot.canonicalKeys;
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
    try {
      InterpretationData content;
      if (force) {
        // Quyền đọc và nội dung là hai nguồn độc lập. Sau khi mở khóa, tải cả
        // snapshot đã lưu lẫn bản sinh mới rồi chọn nội dung chi tiết hơn.
        final generatedFuture = _generateIfPossible(context, mode, token);
        final savedFuture = context.isSaved
            ? ref
                  .read(interpretationRepositoryProvider)
                  .getSavedInterpretation(
                    chartId: context.chartId!,
                    cancelToken: token,
                  )
                  .catchError((_) => const InterpretationData())
            : Future.value(const InterpretationData());
        final values = await Future.wait([savedFuture, generatedFuture]);
        content = values[0].mergeDetailed(values[1]);
      } else if (context.isSaved && mode == InterpretationMode.deep) {
        try {
          content = await ref
              .read(interpretationRepositoryProvider)
              .getSavedInterpretation(
                chartId: context.chartId!,
                cancelToken: token,
              );
          if (content.isEmpty) {
            content = await _generateIfPossible(context, mode, token);
          }
        } on InterpretationException catch (error) {
          if (error.statusCode != 404) rethrow;
          content = await _generateIfPossible(context, mode, token);
        }
      } else {
        content = await _generateIfPossible(context, mode, token);
      }
      if (!_isCurrent(activeSession, token) || state.mode != mode) return;
      final chartId = context.chartId;
      if (chartId != null) _cacheContent(chartId, mode, content);
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

  Future<InterpretationData> _generateIfPossible(
    InterpretationChartContext context,
    InterpretationMode mode,
    CancelToken token,
  ) {
    if (context.chartData.isEmpty) {
      return Future.value(const InterpretationData());
    }
    return _generate(context, mode, token);
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
    loadInterpretation(force: state.contentByMode.containsKey(mode));
  }

  bool isUnlocked(ReadingSection section) {
    if (section.isFree) return true;
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

  UnlockStatus statusFor(ReadingSection section) {
    if (isUnlocked(section)) return UnlockStatus.unlocked;
    final key = _sectionKey(section);
    return key == null
        ? UnlockStatus.idle
        : state.unlockStatusBySection[key.value] ?? UnlockStatus.idle;
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
      final permissions = await loadUnlocks(session: session);
      if (!_isCurrent(session, token)) return result;
      if (permissions?.contains(key) == true) {
        _setUnlockStatuses([key], UnlockStatus.unlocked, clearError: true);
        await loadInterpretation(force: true);
      } else {
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
      final permissions = await loadUnlocks(session: session);
      if (!_isCurrent(session, token)) return result;
      final unresolved = keys
          .where((key) => permissions?.contains(key) != true)
          .toList(growable: false);
      final resolved = keys
          .where((key) => permissions?.contains(key) == true)
          .toList(growable: false);
      _setUnlockStatuses(resolved, UnlockStatus.unlocked);
      if (unresolved.isEmpty) {
        state = state.copyWith(clearUnlockError: true);
        await loadInterpretation(force: true);
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

  static Map<String, dynamic> _mergeChartData(
    Map<String, dynamic> cached,
    Map<String, dynamic> refreshed,
  ) {
    if (cached.isEmpty) return refreshed;
    if (refreshed.isEmpty) return cached;
    final result = <String, dynamic>{...cached, ...refreshed};
    for (final key in const ['palaces', 'generalReading', 'general_reading']) {
      final cachedValue = cached[key];
      final refreshedValue = refreshed[key];
      if (cachedValue is Map && refreshedValue is Map) {
        result[key] = <String, dynamic>{
          ...Map<String, dynamic>.from(cachedValue),
          ...Map<String, dynamic>.from(refreshedValue),
        };
      } else if (_isEmptyCollection(refreshedValue) && cachedValue != null) {
        result[key] = cachedValue;
      }
    }
    return Map.unmodifiable(result);
  }

  static bool _isEmptyCollection(Object? value) =>
      value == null ||
      (value is Map && value.isEmpty) ||
      (value is List && value.isEmpty);

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

  static Map<String, UnlockStatus> _reconcileUnlockStatuses(
    Map<String, UnlockStatus> current,
    Set<ReadingSectionKey> permissions,
  ) {
    final result = <String, UnlockStatus>{...current};
    final grantedValues = permissions.map((key) => key.value).toSet();
    for (final entry in current.entries) {
      if (entry.value == UnlockStatus.unlocked &&
          !grantedValues.contains(entry.key)) {
        result[entry.key] = UnlockStatus.idle;
      }
    }
    for (final key in permissions) {
      result[key.value] = UnlockStatus.unlocked;
    }
    return Map.unmodifiable(result);
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
