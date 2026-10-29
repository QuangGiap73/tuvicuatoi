import '../../domain/wallet_models.dart';

enum TopUpTab { coins, membership }

class TopUpState {
  const TopUpState({
    this.coinPackages = const [],
    this.memberships = const [],
    this.selectedTab = TopUpTab.coins,
    this.isLoading = false,
    this.creatingProductId,
    this.error,
  });

  final List<CoinPackage> coinPackages;
  final List<MembershipPackage> memberships;
  final TopUpTab selectedTab;
  final bool isLoading;
  final String? creatingProductId;
  final String? error;

  TopUpState copyWith({
    List<CoinPackage>? coinPackages,
    List<MembershipPackage>? memberships,
    TopUpTab? selectedTab,
    bool? isLoading,
    String? creatingProductId,
    bool clearCreating = false,
    String? error,
    bool clearError = false,
  }) => TopUpState(
    coinPackages: coinPackages ?? this.coinPackages,
    memberships: memberships ?? this.memberships,
    selectedTab: selectedTab ?? this.selectedTab,
    isLoading: isLoading ?? this.isLoading,
    creatingProductId: clearCreating
        ? null
        : creatingProductId ?? this.creatingProductId,
    error: clearError ? null : error ?? this.error,
  );
}
