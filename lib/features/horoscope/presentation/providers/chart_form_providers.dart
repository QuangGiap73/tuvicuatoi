import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/chart_form_controller.dart';
import '../controllers/chart_generation_controller.dart';
import '../controllers/my_charts_controller.dart';
import '../state/chart_form_state.dart';
import '../state/chart_generation_state.dart';
import '../state/my_charts_state.dart';

final chartFormControllerProvider =
    NotifierProvider.autoDispose<ChartFormController, ChartFormState>(
      ChartFormController.new,
    );

final chartGenerationControllerProvider =
    NotifierProvider<ChartGenerationController, ChartGenerationState>(
      ChartGenerationController.new,
    );

final myChartsControllerProvider =
    NotifierProvider.autoDispose<MyChartsController, MyChartsState>(
      MyChartsController.new,
    );
