import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/interpretation_controller.dart';
import '../state/interpretation_view_snapshot.dart';

final interpretationViewSnapshotProvider = Provider<InterpretationViewSnapshot>(
  (ref) {
    final state = ref.watch(interpretationControllerProvider);
    return InterpretationViewSnapshot(state: state);
  },
);
