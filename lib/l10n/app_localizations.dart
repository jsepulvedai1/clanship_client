import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignInButton;

  /// No description provided for @loginWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String loginWelcomeMessage(String name);

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String loginError(String message);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for a professional...'**
  String get homeSearchPlaceholder;

  /// No description provided for @homeTagNear.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get homeTagNear;

  /// No description provided for @homeTagTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get homeTagTopRated;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @profDetailHire.
  ///
  /// In en, this message translates to:
  /// **'Hire Now'**
  String get profDetailHire;

  /// No description provided for @profDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get profDetailAbout;

  /// No description provided for @profDetailStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profDetailStats;

  /// No description provided for @profDetailReviews.
  ///
  /// In en, this message translates to:
  /// **'{count} ({reviews} reviews)'**
  String profDetailReviews(String count, String reviews);

  /// No description provided for @profDetailFindMe.
  ///
  /// In en, this message translates to:
  /// **'Find me on:'**
  String get profDetailFindMe;

  /// No description provided for @profDetailDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get profDetailDocuments;

  /// No description provided for @profDetailContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get profDetailContact;

  /// No description provided for @addressDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Your address'**
  String get addressDialogTitle;

  /// No description provided for @addressDialogAdd.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get addressDialogAdd;

  /// No description provided for @addressDialogYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get addressDialogYes;

  /// No description provided for @addressDialogNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get addressDialogNo;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your trusted professionals to find them faster next time.'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore professionals'**
  String get favoritesExplore;

  /// No description provided for @matchingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get matchingCancel;

  /// No description provided for @matchingSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching for match...'**
  String get matchingSearching;

  /// No description provided for @matchingConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting with {name}'**
  String matchingConnecting(String name);

  /// No description provided for @matchingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Match Successful!'**
  String get matchingSuccess;

  /// No description provided for @matchingAccepted.
  ///
  /// In en, this message translates to:
  /// **'{name} has accepted to connect.'**
  String matchingAccepted(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsSpanish;

  /// No description provided for @chatStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get chatStatusOnline;

  /// No description provided for @chatInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatInputPlaceholder;

  /// No description provided for @jobsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get jobsTitle;

  /// No description provided for @jobsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active jobs yet'**
  String get jobsEmptyTitle;

  /// No description provided for @jobsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your matches will appear here.'**
  String get jobsEmptySubtitle;

  /// No description provided for @jobsViewDetail.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get jobsViewDetail;

  /// No description provided for @jobsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get jobsStatusPending;

  /// No description provided for @jobsStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get jobsStatusActive;

  /// No description provided for @jobsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get jobsStatusRejected;

  /// No description provided for @jobsStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get jobsStatusCompleted;

  /// No description provided for @jobsRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get jobsRequestsTitle;

  /// No description provided for @jobsInProcess.
  ///
  /// In en, this message translates to:
  /// **'In process'**
  String get jobsInProcess;

  /// No description provided for @jobsFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get jobsFinished;

  /// No description provided for @jobsArrivalInfo.
  ///
  /// In en, this message translates to:
  /// **'arriving in {time}'**
  String jobsArrivalInfo(String time);

  /// No description provided for @jobsDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Job details'**
  String get jobsDetailTitle;

  /// No description provided for @jobsTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get jobsTotalValue;

  /// No description provided for @jobsGoToChat.
  ///
  /// In en, this message translates to:
  /// **'Go to chat'**
  String get jobsGoToChat;

  /// No description provided for @jobsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get jobsCancel;

  /// No description provided for @jobsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get jobsBack;

  /// No description provided for @chatActionUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get chatActionUrgent;

  /// No description provided for @chatActionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get chatActionCall;

  /// No description provided for @chatActionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get chatActionLocation;

  /// No description provided for @matchingConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Before requesting!'**
  String get matchingConfirmTitle;

  /// No description provided for @matchingConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remember to confirm that this is the address to request'**
  String get matchingConfirmSubtitle;

  /// No description provided for @matchingConfirmAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm address'**
  String get matchingConfirmAddressLabel;

  /// No description provided for @matchingConfirmWarning.
  ///
  /// In en, this message translates to:
  /// **'Please note that the address cannot be changed in the middle of the request. Carefully review the address to request the service'**
  String get matchingConfirmWarning;

  /// No description provided for @matchingConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get matchingConfirmAction;

  /// No description provided for @settingsPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get settingsPersonalInfo;

  /// No description provided for @settingsEditData.
  ///
  /// In en, this message translates to:
  /// **'Edit my data'**
  String get settingsEditData;

  /// No description provided for @settingsMyPlan.
  ///
  /// In en, this message translates to:
  /// **'My current plan'**
  String get settingsMyPlan;

  /// No description provided for @settingsMyDocs.
  ///
  /// In en, this message translates to:
  /// **'My documents'**
  String get settingsMyDocs;

  /// No description provided for @settingsVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification status'**
  String get settingsVerificationStatus;

  /// No description provided for @settingsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get settingsChooseLanguage;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Technical support'**
  String get settingsSupport;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get settingsTerms;

  /// No description provided for @chatActionEnrich.
  ///
  /// In en, this message translates to:
  /// **'Enrich'**
  String get chatActionEnrich;

  /// No description provided for @chatActionJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get chatActionJob;

  /// No description provided for @chatJobCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Job request created successfully'**
  String get chatJobCreatedSuccess;

  /// No description provided for @chatJobCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'I have created a job request.'**
  String get chatJobCreatedMessage;

  /// No description provided for @chatEnrichTitle.
  ///
  /// In en, this message translates to:
  /// **'Enrich Request'**
  String get chatEnrichTitle;

  /// No description provided for @chatEnrichHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem in more detail, add equipment brands, access, or instructions...'**
  String get chatEnrichHint;

  /// No description provided for @chatEnrichAttachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach Photo of the Problem'**
  String get chatEnrichAttachPhoto;

  /// No description provided for @chatEnrichEnterDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Please write the additional details.'**
  String get chatEnrichEnterDetailsError;

  /// No description provided for @chatEnrichSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request enriched successfully.'**
  String get chatEnrichSuccess;

  /// No description provided for @chatEnrichMessage.
  ///
  /// In en, this message translates to:
  /// **'I have enriched the request with new details.'**
  String get chatEnrichMessage;

  /// No description provided for @chatEnrichConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Send'**
  String get chatEnrichConfirm;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get navJobs;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
