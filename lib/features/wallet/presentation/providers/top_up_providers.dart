import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/wallet_repository.dart';
import '../../domain/wallet_models.dart';
import '../controllers/top_up_controller.dart';
import '../state/top_up_state.dart';

final topUpControllerProvider = NotifierProvider<TopUpController, TopUpState>(
  TopUpController.new,
);

final topUpTabProvider = Provider<TopUpTab>(
  (ref) =>
      ref.watch(topUpControllerProvider.select((state) => state.selectedTab)),
);

final topUpLoadingProvider = Provider<bool>(
  (ref) =>
      ref.watch(topUpControllerProvider.select((state) => state.isLoading)),
);

final topUpErrorProvider = Provider<String?>(
  (ref) => ref.watch(topUpControllerProvider.select((state) => state.error)),
);

final coinPackagesProvider = Provider(
  (ref) =>
      ref.watch(topUpControllerProvider.select((state) => state.coinPackages)),
);

final membershipPackagesProvider = Provider(
  (ref) =>
      ref.watch(topUpControllerProvider.select((state) => state.memberships)),
);

final paymentSettingProvider = Provider<PaymentSetting>(
  (ref) => ref.watch(
    topUpControllerProvider.select((state) => state.paymentSetting),
  ),
);

/// Cached for the lifetime of the app. Backend remains authoritative when a
/// paid action is executed; this catalog is only for labels and pre-checks.
final featureCostsProvider = FutureProvider<FeatureCosts>(
  (ref) => ref.watch(walletRepositoryProvider).getFeatureCosts(),
);

final productCreatingProvider = Provider.family<bool, String>(
  (ref, productId) => ref.watch(
    topUpControllerProvider.select(
      (state) => state.creatingProductId == productId,
    ),
  ),
);
