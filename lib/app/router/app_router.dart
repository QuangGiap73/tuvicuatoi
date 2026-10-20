import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/auth_gate_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/ai_chat/presentation/ai_chat_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/horoscope/presentation/horoscope_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/wallet/presentation/wallet_page.dart';
import 'app_shell.dart';

abstract final class AppRoute {
  static const home = '/';
  static const horoscope = '/horoscope';
  static const chat = '/ai-chat';
  static const wallet = '/wallet';
  static const profile = '/profile';
  static const authGate = '/auth-gate';
  static const login = '/login';
  static const register = '/register';
  static const welcome = '/welcome';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoute.authGate,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoute.welcome ||
          location == AppRoute.login || location == AppRoute.register;
      final isGate = location == AppRoute.authGate;

      if (auth.isLoading) {
        return isAuthRoute || isGate ? null : AppRoute.authGate;
      }
      final isAuthenticated = auth.asData?.value != null;
      if (isAuthenticated) return isAuthRoute || isGate ? AppRoute.home : null;
      return isAuthRoute ? null : AppRoute.welcome;
    },
    routes: [
      GoRoute(path: AppRoute.authGate, builder: (_, _) => const AuthGatePage()),
      GoRoute(path: AppRoute.welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(path: AppRoute.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoute.register, builder: (_, _) => const RegisterPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoute.home, builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.horoscope,
                builder: (_, _) => const HoroscopePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.chat,
                builder: (_, _) => const AiChatPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.wallet,
                builder: (_, _) => const WalletPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.profile,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.listen(authControllerProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
