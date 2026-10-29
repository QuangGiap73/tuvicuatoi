import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/interpretation_controller.dart';
import '../state/interpretation_content_state.dart';

final interpretationContentProvider = Provider<InterpretationContentState>((
  ref,
) {
  final state = ref.watch(interpretationControllerProvider);
  return InterpretationContentState(
    context: state.context,
    mode: state.mode,
    interpretation: state.interpretation,
    isLoadingChart: state.isLoadingChart,
    isLoadingContent: state.isLoadingInterpretation,
    isSavingChart: state.isSavingChart,
    chartError: state.chartError,
    contentError: state.contentError,
  );
});
