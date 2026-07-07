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
  String profDetailReviews(String count, String reviews) {
    return '$count ($reviews reviews)';
  }

  @override
  String get profDetailFindMe => 'Find me on:';

  @override
  String get profDetailDocuments => 'Documents';

  @override
  String get profDetailContact => 'Contact';

  @override
  String get addressDialogTitle => 'Your address';

  @override
  String get addressDialogAdd => 'Add new address';

  @override
  String get addressDialogYes => 'Yes';

  @override
  String get addressDialogNo => 'No';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle =>
      'Save your trusted professionals to find them faster next time.';

  @override
  String get favoritesExplore => 'Explore professionals';

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
  String get jobsFinished => 'Finished';

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

  @override
  String get matchingConfirmTitle => 'Before requesting!';

  @override
  String get matchingConfirmSubtitle =>
      'Remember to confirm that this is the address to request';

  @override
  String get matchingConfirmAddressLabel => 'Confirm address';

  @override
  String get matchingConfirmWarning =>
      'Please note that the address cannot be changed in the middle of the request. Carefully review the address to request the service';

  @override
  String get matchingConfirmAction => 'Request';

  @override
  String get settingsPersonalInfo => 'Personal Information';

  @override
  String get settingsEditData => 'Edit my data';

  @override
  String get settingsMyPlan => 'My current plan';

  @override
  String get settingsMyDocs => 'My documents';

  @override
  String get settingsVerificationStatus => 'Verification status';

  @override
  String get settingsChooseLanguage => 'Change language';

  @override
  String get settingsSupport => 'Technical support';

  @override
  String get settingsTerms => 'Terms and conditions';

  @override
  String get chatActionEnrich => 'Enrich';

  @override
  String get chatActionJob => 'Job';

  @override
  String get chatJobCreatedSuccess => 'Job request created successfully';

  @override
  String get chatJobCreatedMessage => 'I have created a job request.';

  @override
  String get chatEnrichTitle => 'Enrich Request';

  @override
  String get chatEnrichHint =>
      'Describe the problem in more detail, add equipment brands, access, or instructions...';

  @override
  String get chatEnrichAttachPhoto => 'Attach Photo of the Problem';

  @override
  String get chatEnrichEnterDetailsError =>
      'Please write the additional details.';

  @override
  String get chatEnrichSuccess => 'Request enriched successfully.';

  @override
  String get chatEnrichMessage =>
      'I have enriched the request with new details.';

  @override
  String get chatEnrichConfirm => 'Confirm and Send';

  @override
  String get navHome => 'Home';

  @override
  String get navJobs => 'Jobs';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Profile';
}
