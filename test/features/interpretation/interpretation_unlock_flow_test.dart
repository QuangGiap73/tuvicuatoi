import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/data/interpretation_repository.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/presentation/controllers/interpretation_controller.dart';

void main() {
  const chartId = 'chart-id';
  const first = ReadingSection(
    id: 'first',
    groupSlug: 'tong_quan_ban_menh',
    groupTitle: 'Tổng quan',
    sectionSlug: 'ban_menh_va_than',
    title: 'Bản mệnh và thân',
    subtitle: '',
    summary: '',
    iconName: '',
    coinCost: 100,
    order: 1,
  );
  const second = ReadingSection(
    id: 'second',
    groupSlug: 'tong_quan_ban_menh',
    groupTitle: 'Tổng quan',
    sectionSlug: 'am_duong_ngu_hanh',
    title: 'Âm dương ngũ hành',
    subtitle: '',
    summary: '',
    iconName: '',
    coinCost: 100,
    order: 2,
  );

  String keyOf(ReadingSection section) =>
      '$chartId:${section.groupSlug}:${section.sectionSlug}:chuyen-sau';

  String everydayKeyOf(ReadingSection section) =>
      '$chartId:${section.groupSlug}:${section.sectionSlug}:doi-thuong';

  ProviderContainer containerFor(_FakeInterpretationRepository repository) {
    final container = ProviderContainer(
      overrides: [
        interpretationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(interpretationControllerProvider.notifier)
        .openContext(
          const InterpretationChartContext(
            name: 'Lá số kiểm thử',
            chartId: chartId,
            chartData: {'fullName': 'Kiểm thử'},
          ),
        );
    return container;
  }

  test(
    'POST keys do not unlock until GET confirms canonical permission',
    () async {
      final repository = _FakeInterpretationRepository(
        postKeys: {keyOf(first)},
        permissionsAfterPost: const {},
      );
      final container = containerFor(repository);
      await Future<void>.delayed(Duration.zero);

      final result = await container
          .read(interpretationControllerProvider.notifier)
          .unlock(first);
      final controller = container.read(
        interpretationControllerProvider.notifier,
      );

      expect(result, isNotNull);
      expect(controller.isUnlocked(first), isFalse);
      expect(controller.statusFor(first), UnlockStatus.syncing);
      expect(
        container.read(interpretationControllerProvider).unlockError,
        contains('đang đồng bộ quyền đọc'),
      );

      repository.permissions = {keyOf(first)};
      await controller.loadUnlocks();

      expect(controller.isUnlocked(first), isTrue);
      expect(controller.statusFor(first), UnlockStatus.unlocked);
    },
  );

  test('bundle unlock grants only sections confirmed by GET', () async {
    final repository = _FakeInterpretationRepository(
      postKeys: {keyOf(first), keyOf(second)},
      permissionsAfterPost: {keyOf(first)},
    );
    final container = containerFor(repository);
    await Future<void>.delayed(Duration.zero);

    final result = await container
        .read(interpretationControllerProvider.notifier)
        .unlockBundle(const [first, second]);
    final controller = container.read(
      interpretationControllerProvider.notifier,
    );

    expect(result?.cost, 180);
    expect(result?.saveCost, 20);
    expect(result?.balance, 820);
    expect(controller.isUnlocked(first), isTrue);
    expect(controller.statusFor(first), UnlockStatus.unlocked);
    expect(controller.isUnlocked(second), isFalse);
    expect(controller.statusFor(second), UnlockStatus.syncing);
  });

  test('content and unlock requests stay isolated by reading mode', () async {
    final repository = _FakeInterpretationRepository(
      postKeys: {everydayKeyOf(first)},
      permissionsAfterPost: {everydayKeyOf(first)},
    );
    final container = containerFor(repository);
    await Future<void>.delayed(Duration.zero);
    final controller = container.read(
      interpretationControllerProvider.notifier,
    );

    expect(repository.generatedModes, contains(InterpretationMode.deep));

    controller.changeMode(InterpretationMode.everyday);
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(interpretationControllerProvider).mode,
      InterpretationMode.everyday,
    );
    expect(repository.generatedModes, contains(InterpretationMode.everyday));

    await controller.unlock(first);

    expect(repository.unlockModes.last, InterpretationMode.everyday);
    expect(controller.isUnlocked(first), isTrue);

    controller.changeMode(InterpretationMode.deep);
    expect(controller.isUnlocked(first), isFalse);
  });

  test(
    'saved chart keeps stored interpretation when engine rejects chart',
    () async {
      const saved = InterpretationData(
        personalityCore: 'Stored personal interpretation',
      );
      final repository = _FakeInterpretationRepository(
        postKeys: const {},
        permissionsAfterPost: const {},
        savedData: saved,
        throwOnGenerate: true,
      );
      final container = containerFor(repository);
      await Future<void>.delayed(Duration.zero);
      final controller = container.read(
        interpretationControllerProvider.notifier,
      );

      controller.changeMode(InterpretationMode.everyday);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(interpretationControllerProvider);
      expect(state.interpretation?.personalityCore, saved.personalityCore);
      expect(state.contentError, isNull);
    },
  );
}

class _FakeInterpretationRepository extends InterpretationRepository {
  _FakeInterpretationRepository({
    required this.postKeys,
    required this.permissionsAfterPost,
    this.savedData = const InterpretationData(),
    this.throwOnGenerate = false,
  }) : super(Dio());

  final Set<String> postKeys;
  final Set<String> permissionsAfterPost;
  final InterpretationData savedData;
  final bool throwOnGenerate;
  Set<String> permissions = {};
  final List<InterpretationMode> generatedModes = [];
  final List<InterpretationMode> unlockModes = [];

  @override
  Future<List<ReadingSection>> getSections({CancelToken? cancelToken}) async =>
      const [];

  @override
  Future<Set<String>> getUnlocks({
    required String chartId,
    CancelToken? cancelToken,
  }) async => Set.unmodifiable(permissions);

  @override
  Future<InterpretationData> getSavedInterpretation({
    required String chartId,
    CancelToken? cancelToken,
  }) async => savedData;

  @override
  Future<InterpretationData> generate({
    required Map<String, dynamic> chartData,
    required InterpretationMode mode,
    DateTime? readingDate,
    CancelToken? cancelToken,
  }) async {
    if (throwOnGenerate) {
      throw const InterpretationException(
        'Dữ liệu lá số không hợp lệ hoặc chưa đủ 12 cung',
        statusCode: 422,
      );
    }
    generatedModes.add(mode);
    return InterpretationData(
      aiShortSummary: mode.apiValue,
      rawData: {'mode': mode.apiValue},
    );
  }

  @override
  Future<ReadingUnlockResult> unlock({
    required String chartId,
    required InterpretationMode mode,
    required ReadingSection section,
    String? voucherCode,
    CancelToken? cancelToken,
  }) async {
    unlockModes.add(mode);
    permissions = Set.of(permissionsAfterPost);
    return ReadingUnlockResult(
      wasAlreadyUnlocked: false,
      balance: 900,
      cost: 100,
      saveCost: 0,
      unlockedKeys: postKeys,
    );
  }

  @override
  Future<ReadingUnlockResult> unlockBundle({
    required String chartId,
    required InterpretationMode mode,
    required List<ReadingSection> sections,
    String? voucherCode,
    CancelToken? cancelToken,
  }) async {
    unlockModes.add(mode);
    permissions = Set.of(permissionsAfterPost);
    return ReadingUnlockResult(
      wasAlreadyUnlocked: false,
      balance: 820,
      cost: 180,
      saveCost: 20,
      unlockedKeys: postKeys,
    );
  }
}
