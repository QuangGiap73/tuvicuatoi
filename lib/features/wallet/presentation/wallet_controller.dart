import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet_models.dart';
import 'transaction_history_controller.dart';

class WalletState {
  const WalletState({
    this.info,
    this.isLoading = false,
    this.error,
    this.activeActions = const {},
  });
  final EarnCoinsInfo? info;
  final bool isLoading;
  final String? error;
  final Set<String> activeActions;

  WalletState copyWith({
    EarnCoinsInfo? info,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Set<String>? activeActions,
  }) => WalletState(
    info: info ?? this.info,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
    activeActions: activeActions ?? this.activeActions,
  );
}

class WalletController extends Notifier<WalletState> {
  CancelToken? _token;
  Timer? _syncTimer;

  @override
  WalletState build() {
    ref.onDispose(() {
      _token?.cancel();
      _syncTimer?.cancel();
    });
    Future.microtask(refresh);
    return const WalletState(isLoading: true);
  }

  Future<void> refresh({bool quietly = false}) async {
    if (state.isLoading && quietly) return;
    _token?.cancel('Tải lại Ví Xu');
    final token = CancelToken();
    _token = token;
    state = state.copyWith(isLoading: !quietly, clearError: true);
    try {
      final info = await ref
          .read(walletRepositoryProvider)
          .getInfo(cancelToken: token);
      if (token.isCancelled) return;
      state = state.copyWith(info: info, isLoading: false, clearError: true);
      _scheduleSync(info);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      state = state.copyWith(isLoading: false, error: error.message);
    } on WalletException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  Future<String?> checkIn() => _run('checkin', () async {
    final response = await ref.read(walletRepositoryProvider).checkIn();
    await _refreshAfterMutation();
    return response['message']?.toString() ?? 'Điểm danh thành công.';
  });

  Future<String?> startMission(CoinMission mission) =>
      _run('start:${mission.code}', () async {
        final response = await ref
            .read(walletRepositoryProvider)
            .startMission(mission.code);
        await refresh(quietly: true);
        return response['message']?.toString() ?? 'Đã bắt đầu nhiệm vụ.';
      });

  Future<String?> claimMission(CoinMission mission) =>
      _run('claim:${mission.code}', () async {
        final response = await ref
            .read(walletRepositoryProvider)
            .claimMission(mission.code);
        await _refreshAfterMutation();
        return response['message']?.toString() ?? 'Đã nhận thưởng.';
      });

  Future<void> recordMissionAction(CoinMission mission) async {
    try {
      await ref
          .read(walletRepositoryProvider)
          .recordMissionAction(mission.code);
      await refresh(quietly: true);
    } on WalletException catch (error) {
      state = state.copyWith(error: error.message);
    }
  }

  Future<String?> _run(String key, Future<String> Function() action) async {
    if (state.activeActions.contains(key)) return null;
    state = state.copyWith(
      activeActions: Set.unmodifiable({...state.activeActions, key}),
      clearError: true,
    );
    try {
      return await action();
    } on WalletException catch (error) {
      state = state.copyWith(error: error.message);
      return null;
    } finally {
      final next = {...state.activeActions}..remove(key);
      state = state.copyWith(activeActions: Set.unmodifiable(next));
    }
  }

  Future<void> _refreshAfterMutation() async {
    ref.invalidate(transactionHistoryControllerProvider);
    await Future.wait([refresh(quietly: true), _refreshProfileSafely()]);
  }

  Future<void> _refreshProfileSafely() async {
    try {
      await ref.read(authControllerProvider.notifier).refreshProfile();
    } catch (_) {}
  }

  void _scheduleSync(EarnCoinsInfo info) {
    _syncTimer?.cancel();
    final remaining = info.missions
        .where(
          (item) =>
              item.isVerifying &&
              !item.canVerify &&
              item.executionRemainingSeconds > 0,
        )
        .map((item) => item.executionRemainingSeconds)
        .fold<int?>(
          null,
          (current, value) =>
              current == null || value < current ? value : current,
        );
    if (remaining == null) return;
    final delaySeconds = (remaining + 1).clamp(2, 61);
    _syncTimer = Timer(
      Duration(seconds: delaySeconds),
      () => refresh(quietly: true),
    );
  }
}

final walletControllerProvider =
    NotifierProvider<WalletController, WalletState>(WalletController.new);
