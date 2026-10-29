import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/interpretation_controller.dart';
import '../state/reading_permission_state.dart';

final readingPermissionProvider = Provider<ReadingPermissionState>((ref) {
  final state = ref.watch(interpretationControllerProvider);
  return ReadingPermissionState(
    chartId: state.context?.chartId,
    mode: state.mode,
    allUnlocked: state.catalog?.allUnlocked == true,
    unlockedKeys: state.canonicalUnlockedKeys,
    statusBySection: state.unlockStatusBySection,
    isLoading: state.isLoadingUnlocks,
    permissionError: state.permissionError,
    unlockError: state.unlockError,
  );
});
