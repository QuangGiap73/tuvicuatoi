import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/interpretation_controller.dart';
import '../state/interpretation_catalog_state.dart';

final interpretationCatalogProvider = Provider<InterpretationCatalogState>((
  ref,
) {
  final state = ref.watch(interpretationControllerProvider);
  return InterpretationCatalogState(
    sections: state.sections,
    catalog: state.catalog,
    selectedTab: state.selectedTab,
    isLoading: state.isLoadingSections,
    error: state.catalogError,
  );
});
