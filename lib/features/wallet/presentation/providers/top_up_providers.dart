import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final productCreatingProvider = Provider.family<bool, String>(
  (ref, productId) => ref.watch(
    topUpControllerProvider.select(
      (state) => state.creatingProductId == productId,
    ),
  ),
);
