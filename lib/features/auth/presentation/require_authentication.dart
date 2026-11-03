import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/auth_route_policy.dart';
import 'controllers/auth_controller.dart';

bool requireAuthentication(
  BuildContext context,
  WidgetRef ref, {
  required String reason,
}) {
  if (ref.read(authControllerProvider).asData?.value != null) return true;

  final destination = GoRouterState.of(context).uri.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reason)));
  context.go(AuthRoutePolicy.loginLocation(destination));
  return false;
}
