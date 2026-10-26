import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/auth_gate_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/ai_chat/presentation/ai_chat_page.dart';
import '../../features/daily_fortune/presentation/daily_fortune_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/horoscope/presentation/horoscope_page.dart';
import '../../features/horoscope/presentation/chart_result_page.dart';
import '../../features/horoscope/presentation/my_charts_page.dart';
import '../../features/interpretation/presentation/interpretation_page.dart';
import '../../features/palace_detail/presentation/palace_detail_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/personal_profile_page.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
import '../../features/wallet/presentation/wallet_page.dart';
import 'app_shell.dart';

abstract final class AppRoute {
  static const home = '/';
  static const horoscope = '/horoscope';
  static const chartResult = '/horoscope/result';
  static const interpretation = '/horoscope/interpretation';
  static const palaceDetail = '/horoscope/palace-detail';
  static const myCharts = '/profile/charts';
  static const chat = '/ai-chat';
  static const dailyFortune = '/daily-fortune';
  static const wallet = '/wallet';
  static const profile = '/profile';
  static const personalProfile = '/profile/personal';
  static const editProfile = '/profile/personal/edit';
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
          location == AppRoute.login ||
          location == AppRoute.register;
      final isGate = location == AppRoute.authGate;
      final isGuestChat = location == AppRoute.chat;

      if (auth.isLoading) {
        return isAuthRoute || isGate || isGuestChat ? null : AppRoute.authGate;
      }
      final isAuthenticated = auth.asData?.value != null;
      if (isAuthenticated) {
        if (!isAuthRoute && !isGate) return null;
        final redirect = state.uri.queryParameters['redirect'];
        return redirect == AppRoute.chat ? AppRoute.chat : AppRoute.home;
      }
      return isAuthRoute || isGuestChat ? null : AppRoute.welcome;
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
              GoRoute(
                path: AppRoute.home,
                builder: (_, _) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'daily-fortune',
                    builder: (_, _) => const DailyFortunePage(),
                  ),
                ],
              ),
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
                routes: [
                  GoRoute(
                    path: 'personal',
                    builder: (_, _) => const PersonalProfilePage(),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (_, _) => const EditProfilePage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'charts',
                    builder: (_, _) => const MyChartsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.chartResult,
        builder: (_, _) => const ChartResultPage(),
      ),
      GoRoute(
        path: AppRoute.interpretation,
        builder: (_, _) => const InterpretationPage(),
      ),
      GoRoute(
        path: AppRoute.palaceDetail,
        builder: (_, _) => const PalaceDetailPage(),
      ),
    ],
  );
  ref.listen(authControllerProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
