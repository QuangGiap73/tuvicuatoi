import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/ai_chat/data/ai_chat_history_store.dart';
import 'package:tuvicuatoi/features/ai_chat/data/ai_chat_repository.dart';
import 'package:tuvicuatoi/features/ai_chat/domain/ai_chat_message.dart';
import 'package:tuvicuatoi/features/ai_chat/presentation/controllers/ai_chat_controller.dart';
import 'package:tuvicuatoi/features/ai_chat/presentation/state/ai_chat_state.dart';
import 'package:tuvicuatoi/features/auth/data/auth_repository.dart';
import 'package:tuvicuatoi/features/auth/domain/auth_user.dart';
import 'package:tuvicuatoi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tuvicuatoi/features/horoscope/domain/chart_result.dart';

void main() {
  test(
    'burst SSE deltas are coalesced before publishing the final answer',
    () async {
      final session = AuthSession(
        token: 'token',
        user: const AuthUser(
          id: 'user-1',
          email: 'member@example.com',
          fullName: 'Member',
          coinBalance: 10,
          isPremium: false,
          role: 'member',
          authProvider: 'credentials',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(
            () => _FakeAuthController(session),
          ),
          authRepositoryProvider.overrideWithValue(_FailingUsageRepository()),
          aiChatRepositoryProvider.overrideWithValue(_BurstChatRepository()),
          aiChatHistoryStoreProvider.overrideWithValue(_MemoryHistoryStore()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);

      final states = <AiChatState>[];
      final subscription = container.listen(
        aiChatControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final controller = container.read(aiChatControllerProvider.notifier);
      controller.useGeneratedChart(_chartResult());
      states.clear();

      expect(await controller.send('Công việc thế nào?'), isTrue);

      final streamingUpdates = states
          .where((state) => state.streamingMessage != null)
          .length;
      expect(streamingUpdates, lessThan(100));
      final result = container.read(aiChatControllerProvider);
      expect(result.streamingMessage, isNull);
      expect(result.phase, AiChatPhase.ready);
      expect(result.messages.last.content, List.filled(100, 'x').join());
      expect(result.messages.last.status, AiChatMessageStatus.sent);
    },
  );

  test(
    'chat state is cleared when the authenticated account changes',
    () async {
      final auth = _FakeAuthController(_session('user-1'));
      final container = ProviderContainer(
        overrides: [authControllerProvider.overrideWith(() => auth)],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);
      final controller = container.read(aiChatControllerProvider.notifier);
      controller.useGeneratedChart(_chartResult());
      expect(container.read(aiChatControllerProvider).selectedChart, isNotNull);

      auth.setSession(_session('user-2'));
      await Future<void>.delayed(Duration.zero);

      final state = container.read(aiChatControllerProvider);
      expect(state.selectedChart, isNull);
      expect(state.streamingMessage, isNull);
      expect(state.messages, AiChatState.welcomeMessages);
    },
  );
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this.session);
  AuthSession session;

  @override
  Future<AuthSession?> build() async => session;

  void setSession(AuthSession value) {
    session = value;
    state = AsyncData(value);
  }

  @override
  Future<void> refreshProfile() async {}
}

class _FailingUsageRepository extends AuthRepository {
  _FailingUsageRepository() : super(Dio());

  @override
  Future<void> recordAiQuestion() =>
      throw const AuthException('Usage tracking is unavailable in test.');
}

class _BurstChatRepository extends AiChatRepository {
  _BurstChatRepository() : super(Dio());

  @override
  Stream<AiChatStreamEvent> sendMessage({
    required String message,
    required String chartId,
    required Map<String, dynamic> chartData,
    required String focusPalace,
    required bool isPremium,
    required String userEmail,
    CancelToken? cancelToken,
  }) async* {
    for (var index = 0; index < 100; index++) {
      yield const AiChatDelta('x');
    }
    yield AiChatDone(List.filled(100, 'x').join());
  }
}

class _MemoryHistoryStore implements AiChatHistoryStore {
  @override
  Future<void> delete({
    required String userId,
    required String chartId,
  }) async {}

  @override
  Future<List<AiChatMessage>> read({
    required String userId,
    required String chartId,
  }) async => const [];

  @override
  Future<void> write({
    required String userId,
    required String chartId,
    required List<AiChatMessage> messages,
  }) async {}
}

ChartResult _chartResult() => const ChartResult(
  id: 'chart-1',
  fullName: 'Member',
  gender: 'NAM',
  solarDate: '1990-01-01',
  solarTime: '07:00',
  hourBranch: 'Thìn',
  lunarDate: '01/01/1990',
  lunarYearCanChi: 'Canh Ngọ',
  namXem: '2026',
  amDuongThuanLy: '',
  menhCucBinhHoa: '',
  thanCu: '',
  menh: 'Lộ Bàng Thổ',
  cuc: 'Mộc Tam Cục',
  amDuong: 'Dương Nam',
  chuMenh: '',
  chuThan: '',
  palaces: [],
  rawData: {'id': 'chart-1'},
);

AuthSession _session(String id) => AuthSession(
  token: 'token-$id',
  user: AuthUser(
    id: id,
    email: '$id@example.com',
    fullName: id,
    coinBalance: 10,
    isPremium: false,
    role: 'member',
    authProvider: 'credentials',
  ),
);
