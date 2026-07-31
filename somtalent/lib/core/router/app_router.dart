import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/create_account_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/career_support/presentation/screens/career_support_screen.dart';
import '../../features/dashboard/presentation/screens/home_shell.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/jobs/presentation/screens/job_apply_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_success_screen.dart';
import 'route_paths.dart';

/// Bridges a Riverpod stream to a `Listenable` GoRouter can watch, so auth
/// state changes trigger a redirect re-evaluation without manual `context.go`
/// calls scattered across every screen.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    _sub = ref.listen<AsyncValue<dynamic>>(
      authStateChangesProvider,
      (previous, next) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AsyncValue<dynamic>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RoutePaths.welcome,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authAsync = ref.read(authStateChangesProvider);
      // While the very first auth check is in flight, don't redirect yet.
      if (authAsync.isLoading && !authAsync.hasValue) return null;

      final user = authAsync.value;
      final loggedIn = user != null;
      final location = state.matchedLocation;

      final isAuthRoute =
          location == RoutePaths.welcome ||
          location == RoutePaths.createAccount ||
          location == RoutePaths.signIn ||
          location == RoutePaths.forgotPassword;

      if (!loggedIn) {
        return isAuthRoute ? null : RoutePaths.welcome;
      }

      final needsOnboarding = !user.onboardingCompleted;
      final isOnboardingRoute = location.startsWith(RoutePaths.onboarding);

      if (needsOnboarding && !isOnboardingRoute) return RoutePaths.onboarding;
      if (!needsOnboarding && (isAuthRoute || isOnboardingRoute)) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.createAccount,
        builder: (_, _) => const CreateAccountScreen(),
      ),
      GoRoute(path: RoutePaths.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingSuccess,
        builder: (_, _) => const OnboardingSuccessScreen(),
      ),
      GoRoute(path: RoutePaths.home, builder: (_, _) => const HomeShell()),
      GoRoute(
        path: RoutePaths.jobDetail,
        builder: (_, state) =>
            JobDetailScreen(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: RoutePaths.jobApply,
        builder: (_, state) =>
            JobApplyScreen(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: RoutePaths.earnings,
        builder: (_, _) => const EarningsScreen(),
      ),
      GoRoute(
        path: RoutePaths.careerSupport,
        builder: (_, _) => const CareerSupportScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
    ],
  );
});