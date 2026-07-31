/// Centralized route path strings so screens never hand-type a path GoRouter
/// won't recognize.
abstract final class RoutePaths {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String createAccount = '/create-account';
  static const String signIn = '/sign-in';
  static const String forgotPassword = '/forgot-password';

  static const String onboarding = '/onboarding';
  static const String onboardingSuccess = '/onboarding/success';

  static const String home = '/home';
  static const String jobDetail = '/jobs/:jobId';
  static const String jobApply = '/jobs/:jobId/apply';

  static const String careerSupport = '/career-support';
  static const String messages = '/messages';
  static const String earnings = '/earnings';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  static String jobDetailPath(String jobId) => '/jobs/$jobId';
  static String jobApplyPath(String jobId) => '/jobs/$jobId/apply';
}