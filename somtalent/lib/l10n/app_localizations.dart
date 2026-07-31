// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Somali (`so`).
class AppLocalizationsSo extends AppLocalizations {
  AppLocalizationsSo([String locale = 'so']) : super(locale);

  @override
  String get welcomeTitle => 'Xirfadahaagu Caalamka\nBuu Ka Shaqayn Karaa';

  @override
  String get welcomeSubtitle =>
      'La xiriir shaqooyin fog iyo fursado freelance ah oo ka socda shirkado caalami ah. Dhis mustaqbalkaaga shaqo iyadoo aan xad lahayn.';

  @override
  String get createAccount => 'Samee Akoon';

  @override
  String get signIn => 'Gal';

  @override
  String get welcomeBack => 'Ku Soo Dhawoow Mar Kale';

  @override
  String get signInSubtitle => 'Gal si aad u sii wadato safarkaaga';

  @override
  String get email => 'Iimayl';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Furaha Sirta ah';

  @override
  String get yourPasswordHint => 'Furahaaga sirta ah';

  @override
  String get forgotPassword => 'Ma illowday furahaaga sirta ah?';

  @override
  String get or => 'ama';

  @override
  String get continueWithGoogle => 'Ku sii wad Google';

  @override
  String get noAccountPrompt => 'Akoon ma lihid? ';

  @override
  String get startYourJourney => 'Bilow safarka shaqadaada caalamiga ah';

  @override
  String get fullName => 'Magaca Buuxa';

  @override
  String get fullNameHint => 'tusaale, Hodan Ahmed';

  @override
  String get phoneNumber => 'Lambarka Taleefanka';

  @override
  String get passwordHint => 'Ugu yaraan 8 xaraf';

  @override
  String get continueLabel => 'Sii wad';

  @override
  String get termsAgreement => 'Marka aad sii wado, waxaad ogolaanaysaa ';

  @override
  String get termsOfService => 'Shuruudaha Adeegga';

  @override
  String get and => ' iyo ';

  @override
  String get privacyPolicy => 'Siyaasadda Asturnaanta';

  @override
  String get alreadyHaveAccount => 'Horey akoon ma u lahayd? ';

  @override
  String get goodMorning => 'Subax wanaagsan';

  @override
  String get goodAfternoon => 'Galab wanaagsan';

  @override
  String get goodEvening => 'Fiid wanaagsan';

  @override
  String get readyToFindOpportunity =>
      'Ma diyaar u tahay inaad hesho fursaddaada xigta?';

  @override
  String get convertEarnings => 'Beddel Dakhligaaga';

  @override
  String get receiveMoneyZaad => 'Lacagtaada ku hel Telesom ZAAD';

  @override
  String earnedAmount(String amount) {
    return '\$$amount oo la kasbaday!';
  }

  @override
  String get applications => 'Codsiyada';

  @override
  String get interviews => 'Wareysiyada';

  @override
  String get careerSupportMeetings => 'Kulamada Taageerada Shaqada';

  @override
  String tipOfTheDay(int pct) {
    return 'Talada Maanta: Astaantaada waa $pct% dhammaystiran. Dhammaystir si aad u hesho 14 jibbaar daawasho oo badan.';
  }

  @override
  String get recommendedForYou => 'Kuu Talinaya';

  @override
  String get seeAll => 'Dhammaan arag';

  @override
  String get noOpenRoles => 'Hadda shaqo furan ma jirto — dib u eeg dhawaan.';

  @override
  String get recentActivity => 'Dhaqdhaqaaqii Dhowaa';

  @override
  String get noApplicationsYet =>
      'Codsiyada aad soo dirto ayaa halkan ka muuqan doona.';

  @override
  String appliedTo(String title) {
    return 'Waxaad codsatay $title';
  }

  @override
  String get jobMarketplace => 'Suuqa Shaqooyinka';

  @override
  String get searchJobsHint => 'Ku raadi cinwaanka, shirkadda, ama xirfadda';

  @override
  String couldNotLoadJobs(String error) {
    return 'Shaqooyinka lama soo rari karin.\n$error';
  }

  @override
  String get noJobsMatchSearch =>
      'Wax shaqo ah oo raadintaada la mid ah lama helin.';

  @override
  String get remote => 'Fog';

  @override
  String get onSite => 'Goobta';

  @override
  String get applyNow => 'Hadda Codso';
}