import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../horoscope/domain/chart_result.dart';
import '../../../interpretation/data/interpretation_repository.dart';
import '../../../interpretation/domain/interpretation_models.dart';
import '../../data/palace_detail_repository.dart';
import '../../domain/palace_detail_models.dart';
import '../state/palace_detail_state.dart';

class PalaceDetailController extends Notifier<PalaceDetailState> {
  CancelToken? _loadToken;
  int _session = 0;
  final _cache = <String, PalaceDetailPayload>{};

  @override
  PalaceDetailState build() {
    ref.onDispose(() => _loadToken?.cancel());
    return const PalaceDetailState();
  }

  void open(PalaceDetailContext context) {
    _loadToken?.cancel('Đổi cung đang xem');
    final session = ++_session;
    final related = _relatedPalaces(context);
    final key = '${context.chart.id}:${context.palace.id}';
    final cached = _cache[key];
    state = PalaceDetailState(
      context: context,
      relatedPalaces: related,
      rules: cached?.rules ?? const [],
      triadRules: cached?.triadRules ?? const [],
      isLoading: cached == null,
    );
    _load(context, related, key, session, loadRules: cached == null);
  }

  Future<void> retry() async {
    final context = state.context;
    if (context == null) return;
    final key = '${context.chart.id}:${context.palace.id}';
    await _load(context, state.relatedPalaces, key, _session, loadRules: true);
  }

  Future<void> _load(
    PalaceDetailContext context,
    List<ChartPalace> related,
    String key,
    int session, {
    required bool loadRules,
  }) async {
    final token = CancelToken();
    _loadToken = token;
    state = PalaceDetailState(
      context: context,
      relatedPalaces: state.relatedPalaces,
      rules: state.rules,
      triadRules: state.triadRules,
      readingSection: state.readingSection,
      unlockedKeys: state.unlockedKeys,
      isLoading: loadRules,
    );
    try {
      final stars = context.palace.mainStars
          .map((star) => star.name)
          .where((name) => name.trim().isNotEmpty)
          .toList(growable: false);
      final triadStars = state.relatedPalaces
          .expand((palace) => palace.mainStars)
          .map((star) => star.name)
          .where((name) => name.trim().isNotEmpty)
          .toSet()
          .toList(growable: false);

      final repository = ref.read(palaceDetailRepositoryProvider);
      final interpretation = ref.read(interpretationRepositoryProvider);
      final futures = <Future<Object?>>[
        if (loadRules)
          repository.getPalaceRules(
            palaceName: context.palace.name,
            stars: stars,
            cancelToken: token,
          ),
        if (loadRules)
          repository.getTriadRules(
            palaceName: context.palace.name,
            triadStars: triadStars,
            cancelToken: token,
          ),
        interpretation.getSections(cancelToken: token),
        if (context.isSaved)
          interpretation.getUnlocks(
            chartId: context.chartId!,
            cancelToken: token,
          ),
      ];
      final values = await Future.wait(futures);
      if (token.isCancelled || session != _session) return;

      var index = 0;
      final rules = loadRules
          ? values[index++] as List<PalaceRule>
          : state.rules;
      final triadRules = loadRules
          ? values[index++] as List<TriadRule>
          : state.triadRules;
      final sections = values[index++] as List<ReadingSection>;
      final unlocks = context.isSaved
          ? values[index] as Set<String>
          : const <String>{};
      final payload = PalaceDetailPayload(rules: rules, triadRules: triadRules);
      _cache[key] = payload;
      if (_cache.length > 12) _cache.remove(_cache.keys.first);
      state = PalaceDetailState(
        context: context,
        relatedPalaces: state.relatedPalaces,
        rules: rules,
        triadRules: triadRules,
        readingSection: readingSectionForPalace(sections, context.palace.name),
        unlockedKeys: unlocks,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || session != _session) return;
      _setError(error.message ?? 'Không thể tải chi tiết cung.');
    } on PalaceDetailException catch (error) {
      if (session != _session) return;
      _setError(error.message);
    } on InterpretationException catch (error) {
      if (session != _session) return;
      _setError(error.message);
    } catch (_) {
      if (session != _session) return;
      _setError('Không thể đọc dữ liệu chi tiết cung từ máy chủ.');
    } finally {
      if (identical(_loadToken, token)) _loadToken = null;
    }
  }

  void _setError(String message) {
    state = PalaceDetailState(
      context: state.context,
      relatedPalaces: state.relatedPalaces,
      rules: state.rules,
      triadRules: state.triadRules,
      readingSection: state.readingSection,
      unlockedKeys: state.unlockedKeys,
      errorMessage: message,
    );
  }

  static List<ChartPalace> _relatedPalaces(PalaceDetailContext context) {
    const triads = <Set<String>>[
      {'Dần', 'Ngọ', 'Tuất'},
      {'Thân', 'Tý', 'Thìn'},
      {'Hợi', 'Mão', 'Mùi'},
      {'Tỵ', 'Dậu', 'Sửu'},
    ];
    const branches = <String>[
      'Tý',
      'Sửu',
      'Dần',
      'Mão',
      'Thìn',
      'Tỵ',
      'Ngọ',
      'Mùi',
      'Thân',
      'Dậu',
      'Tuất',
      'Hợi',
    ];
    final branch = context.palace.branch;
    final triad = triads.firstWhere(
      (group) => group.contains(branch),
      orElse: () => {branch},
    );
    final branchIndex = branches.indexOf(branch);
    final opposite = branchIndex < 0 ? null : branches[(branchIndex + 6) % 12];
    final allowed = {...triad, ?opposite};
    return context.chart.palaces
        .where((palace) => allowed.contains(palace.branch))
        .toList(growable: false);
  }
}

final palaceDetailControllerProvider =
    NotifierProvider<PalaceDetailController, PalaceDetailState>(
      PalaceDetailController.new,
    );
