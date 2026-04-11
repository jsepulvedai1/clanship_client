// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSignInButton => 'Sign In';

  @override
  String loginWelcomeMessage(String name) {
    return 'Welcome $name';
  }

  @override
  String loginError(String message) {
    return 'Error: $message';
  }

  @override
  String homeGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get homeSearchPlaceholder => 'Search for a professional...';

  @override
  String get homeTagNear => 'Nearby';

  @override
  String get homeTagTopRated => 'Top Rated';

  @override
  String get homeViewAll => 'View all';

  @override
  String get profDetailHire => 'Hire Now';

  @override
  String get profDetailAbout => 'About me';

  @override
  String get profDetailStats => 'Statistics';

  @override
  String get matchingCancel => 'Cancel Request';

  @override
  String get matchingSearching => 'Searching for match...';

  @override
  String matchingConnecting(String name) {
    return 'Connecting with $name';
  }

  @override
  String get matchingSuccess => 'Match Successful!';

  @override
  String matchingAccepted(String name) {
    return '$name has accepted to connect.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsSpanish => 'Spanish';

  @override
  String get chatStatusOnline => 'Online';

  @override
  String get chatInputPlaceholder => 'Type a message...';

  @override
  String get jobsTitle => 'My Jobs';

  @override
  String get jobsEmptyTitle => 'No active jobs yet';

  @override
  String get jobsEmptySubtitle => 'Your matches will appear here.';

  @override
  String get jobsViewDetail => 'View Details';

  @override
  String get jobsStatusPending => 'Pending';

  @override
  String get jobsStatusActive => 'Active';

  @override
  String get jobsStatusRejected => 'Rejected';

  @override
  String get jobsStatusCompleted => 'Completed';

  @override
  String get jobsRequestsTitle => 'Requests';

  @override
  String get jobsInProcess => 'In process';

  @override
  String jobsArrivalInfo(String time) {
    return 'arriving in $time';
  }

  @override
  String get jobsDetailTitle => 'Job details';

  @override
  String get jobsTotalValue => 'Total Value';

  @override
  String get jobsGoToChat => 'Go to chat';

  @override
  String get jobsCancel => 'Cancel';

  @override
  String get jobsBack => 'Back';

  @override
  String get chatActionUrgent => 'Urgent';

  @override
  String get chatActionCall => 'Call';

  @override
  String get chatActionLocation => 'Location';
}
