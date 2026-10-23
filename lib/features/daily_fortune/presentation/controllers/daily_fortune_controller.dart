import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/daily_fortune.dart';
import '../state/daily_fortune_state.dart';

class DailyFortuneController extends Notifier<DailyFortuneState> {
  @override
  DailyFortuneState build() {
    final now = DateTime.now();
    return DailyFortuneState(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  void selectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized == state.selectedDate) return;
    state = state.copyWith(
      selectedDate: normalized,
      phase: DailyFortunePhase.idle,
      clearFortune: true,
      clearError: true,
    );
  }

  void setLoading() {
    state = state.copyWith(phase: DailyFortunePhase.loading, clearError: true);
  }

  void setFortune(DailyFortune fortune) {
    state = state.copyWith(
      phase: DailyFortunePhase.ready,
      fortune: fortune,
      clearError: true,
    );
  }

  void setEmpty() {
    state = state.copyWith(
      phase: DailyFortunePhase.empty,
      clearFortune: true,
      clearError: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      phase: DailyFortunePhase.failure,
      errorMessage: message,
    );
  }
}

final dailyFortuneControllerProvider =
    NotifierProvider.autoDispose<DailyFortuneController, DailyFortuneState>(
      DailyFortuneController.new,
    );
