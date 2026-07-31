// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Your Skills Can\nWork Globally';

  @override
  String get welcomeSubtitle =>
      'Connect with remote jobs and freelance opportunities from companies worldwide. Build your career without borders.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signIn => 'Sign In';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInSubtitle => 'Sign in to continue your journey';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get yourPasswordHint => 'Your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get startYourJourney => 'Start your global career journey';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'e.g., Hodan Ahmed';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get continueLabel => 'Continue';

  @override
  String get termsAgreement => 'By continuing, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get readyToFindOpportunity => 'Ready to find your next opportunity?';

  @override
  String get convertEarnings => 'Convert Your Earnings';

  @override
  String get receiveMoneyZaad => 'Receive your money through Telesom ZAAD';

  @override
  String earnedAmount(String amount) {
    return '\$$amount EARNED!';
  }

  @override
  String get applications => 'Applications';

  @override
  String get interviews => 'Interviews';

  @override
  String get careerSupportMeetings => 'Career support meetings';

  @override
  String tipOfTheDay(int pct) {
    return 'Tip of the Day: Your profile is $pct% complete. Finish it to get 14x more profile views.';
  }

  @override
  String get recommendedForYou => 'Recommended for You';

  @override
  String get seeAll => 'See all';

  @override
  String get noOpenRoles => 'No open roles right now — check back soon.';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noApplicationsYet => 'Applications you submit will show up here.';

  @override
  String appliedTo(String title) {
    return 'Applied to $title';
  }

  @override
  String get jobMarketplace => 'Job Marketplace';

  @override
  String get searchJobsHint => 'Search by title, company, or skill';

  @override
  String couldNotLoadJobs(String error) {
    return 'Could not load jobs.\n$error';
  }

  @override
  String get noJobsMatchSearch => 'No jobs match your search yet.';

  @override
  String get remote => 'Remote';

  @override
  String get onSite => 'On-site';

  @override
  String get applyNow => 'Apply Now';
}
