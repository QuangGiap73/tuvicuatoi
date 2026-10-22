import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/home_daily_messages.dart';
import '../state/home_state.dart';

class HomeController extends Notifier<HomeState> {
  Timer? _midnightTimer;

  @override
  HomeState build() {
    ref.onDispose(() => _midnightTimer?.cancel());
    final now = DateTime.now();
    _scheduleNextDay(now);
    return HomeState.initial(
      dailyMessage: dailyMessageFor(now),
      auspiciousYear: now.year,
    );
  }

  /// Làm mới dữ liệu server đang có mà không xóa nội dung cache trên màn hình.
  /// Khi backend bổ sung endpoint Home, repository sẽ được gọi tại đây.
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(status: HomeStatus.refreshing, clearError: true);
    try {
      await ref.read(authControllerProvider.notifier).refreshProfile();
      final now = DateTime.now();
      state = state.copyWith(
        status: HomeStatus.ready,
        dailyMessage: dailyMessageFor(now),
        auspiciousYear: now.year,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: HomeStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void _scheduleNextDay(DateTime now) {
    _midnightTimer?.cancel();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextDay.difference(now), () {
      final current = DateTime.now();
      state = state.copyWith(
        status: HomeStatus.ready,
        dailyMessage: dailyMessageFor(current),
        auspiciousYear: current.year,
        clearError: true,
      );
      _scheduleNextDay(current);
    });
  }
}
