import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../state/home_state.dart';

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

/// Chỉ cập nhật AppBar khi số Xu thực sự thay đổi.
final homeCoinBalanceProvider = Provider<int>((ref) {
  return ref.watch(
    authControllerProvider.select(
      (state) => state.asData?.value?.user.coinBalance ?? 0,
    ),
  );
});

final homeDailyMessageProvider = Provider<String>((ref) {
  return ref.watch(
    homeControllerProvider.select((state) => state.dailyMessage),
  );
});

final homeAuspiciousYearProvider = Provider<int>((ref) {
  return ref.watch(
    homeControllerProvider.select((state) => state.auspiciousYear),
  );
});

final homeRefreshingProvider = Provider<bool>((ref) {
  return ref.watch(
    homeControllerProvider.select((state) => state.isRefreshing),
  );
});

final homeErrorProvider = Provider<String?>((ref) {
  return ref.watch(
    homeControllerProvider.select((state) => state.errorMessage),
  );
});
