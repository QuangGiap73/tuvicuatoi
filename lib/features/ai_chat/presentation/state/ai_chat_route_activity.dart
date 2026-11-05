import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiChatRouteActivityController extends Notifier<bool> {
  @override
  bool build() => false;

  void setActive(bool value) {
    if (state != value) state = value;
  }
}

final aiChatRouteActivityProvider =
    NotifierProvider<AiChatRouteActivityController, bool>(
      AiChatRouteActivityController.new,
    );
