import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr'),
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

  /// No description provided for @homeSearchNeed.
  ///
  /// In en, this message translates to:
  /// **'What do you need?'**
  String get homeSearchNeed;

  /// No description provided for @homeUrgency.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get homeUrgency;

  /// No description provided for @homeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Specific Services'**
  String get homeBannerTitle;

  /// No description provided for @homeBannerSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Post your requirement or check received quotes'**
  String get homeBannerSubTitle;

  /// No description provided for @homeBtnRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get homeBtnRequest;

  /// No description provided for @homeBtnMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get homeBtnMyRequests;

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

  /// No description provided for @settingsFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get settingsFrench;

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

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account'**
  String get authSubtitle;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authRegisterHere.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get authRegisterHere;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authRegisterTitle;

  /// No description provided for @authPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get authPersonalData;

  /// No description provided for @authLocationContact.
  ///
  /// In en, this message translates to:
  /// **'Location & Contact'**
  String get authLocationContact;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get authLastName;

  /// No description provided for @authBirthdate.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get authBirthdate;

  /// No description provided for @authRepeatEmail.
  ///
  /// In en, this message translates to:
  /// **'Repeat Email'**
  String get authRepeatEmail;

  /// No description provided for @authRepeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get authRepeatPassword;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get authPhone;

  /// No description provided for @authAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get authAddress;

  /// No description provided for @authAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms and conditions of service'**
  String get authAcceptTerms;

  /// No description provided for @authProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get authProfilePhoto;

  /// No description provided for @authCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo with camera'**
  String get authCamera;

  /// No description provided for @authGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get authGallery;

  /// No description provided for @authNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get authNext;

  /// No description provided for @authPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get authPrevious;

  /// No description provided for @authCompleteRegister.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get authCompleteRegister;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Your Password?'**
  String get authForgotTitle;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive recovery instructions'**
  String get authForgotSubtitle;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get authSendCode;

  /// No description provided for @authVerifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Code Verification'**
  String get authVerifyOtpTitle;

  /// No description provided for @authVerifyOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your email'**
  String get authVerifyOtpSubtitle;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authResetTitle;

  /// No description provided for @authResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter and confirm your new password'**
  String get authResetSubtitle;

  /// No description provided for @authConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmNewPassword;

  /// No description provided for @authChangePasswordBtn.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get authChangePasswordBtn;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @versionUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get versionUpdateTitle;

  /// No description provided for @versionUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'To continue using Clanship safely, please update the app to the latest available version.'**
  String get versionUpdateMessage;

  /// No description provided for @versionUpdateBtn.
  ///
  /// In en, this message translates to:
  /// **'Update in App Store'**
  String get versionUpdateBtn;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session was opened on another device.'**
  String get sessionExpired;

  /// No description provided for @settingsConfirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get settingsConfirmLogoutTitle;

  /// No description provided for @settingsConfirmLogoutMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your current session?'**
  String get settingsConfirmLogoutMsg;

  /// No description provided for @settingsLogoutBtn.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogoutBtn;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Professional'**
  String get searchTitle;

  /// No description provided for @searchFilterSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Filter by Specialty'**
  String get searchFilterSpecialty;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No professionals found'**
  String get searchNoResults;

  /// No description provided for @loginTaglinePart1.
  ///
  /// In en, this message translates to:
  /// **'Your trusted network '**
  String get loginTaglinePart1;

  /// No description provided for @loginTaglinePart2.
  ///
  /// In en, this message translates to:
  /// **'to solve your needs'**
  String get loginTaglinePart2;

  /// No description provided for @loginConceptTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get loginConceptTrustTitle;

  /// No description provided for @loginConceptTrustSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verification\n& security'**
  String get loginConceptTrustSubtitle;

  /// No description provided for @loginConceptSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get loginConceptSpeedTitle;

  /// No description provided for @loginConceptSpeedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Immediate\nresponse'**
  String get loginConceptSpeedSubtitle;

  /// No description provided for @loginConceptConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get loginConceptConnectionTitle;

  /// No description provided for @loginConceptConnectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People who\nsolve'**
  String get loginConceptConnectionSubtitle;

  /// No description provided for @loginBenefitVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified\nspecialists'**
  String get loginBenefitVerified;

  /// No description provided for @loginBenefitRatings.
  ///
  /// In en, this message translates to:
  /// **'Real\nreviews'**
  String get loginBenefitRatings;

  /// No description provided for @loginBenefitTracking.
  ///
  /// In en, this message translates to:
  /// **'Service\ntracking'**
  String get loginBenefitTracking;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get loginInvalidCredentials;

  /// No description provided for @loginForgotDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get loginForgotDialogTitle;

  /// No description provided for @loginForgotDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send instructions to reset your password.'**
  String get loginForgotDialogMessage;

  /// No description provided for @loginForgotDialogEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get loginForgotDialogEmailRequired;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get authRegisterSubtitle;

  /// No description provided for @authStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your contact details to continue'**
  String get authStep1Subtitle;

  /// No description provided for @authStep0FillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get authStep0FillAllFields;

  /// No description provided for @authStep0NameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'First name cannot exceed 30 characters.'**
  String get authStep0NameMaxLength;

  /// No description provided for @authStep0LastNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Last name cannot exceed 30 characters.'**
  String get authStep0LastNameMaxLength;

  /// No description provided for @authStep0EmailsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Emails do not match.'**
  String get authStep0EmailsDoNotMatch;

  /// No description provided for @authStep0InvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authStep0InvalidEmail;

  /// No description provided for @authStep0PasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authStep0PasswordLength;

  /// No description provided for @authStep0PasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authStep0PasswordsDoNotMatch;

  /// No description provided for @authStep0AgeRestriction.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to register.'**
  String get authStep0AgeRestriction;

  /// No description provided for @authStep0TermsFooter.
  ///
  /// In en, this message translates to:
  /// **'By registering you accept our\nTerms and Conditions and Privacy Policy'**
  String get authStep0TermsFooter;

  /// No description provided for @authPhotoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Profile photo uploaded ✓'**
  String get authPhotoUploaded;

  /// No description provided for @authPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Profile photo * (Required: upload a clear photo of your face)'**
  String get authPhotoRequired;

  /// No description provided for @authPhotoPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Could not open camera or gallery. Please check permissions.'**
  String get authPhotoPermissionError;

  /// No description provided for @authMyAddress.
  ///
  /// In en, this message translates to:
  /// **'My address'**
  String get authMyAddress;

  /// No description provided for @authReadTerms.
  ///
  /// In en, this message translates to:
  /// **'Read the terms and conditions of use'**
  String get authReadTerms;

  /// No description provided for @authSubmitRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authSubmitRegister;

  /// No description provided for @authTermsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get authTermsDialogTitle;

  /// No description provided for @mapSearchAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Search address...'**
  String get mapSearchAddressHint;

  /// No description provided for @mapCurrentGpsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Current GPS'**
  String get mapCurrentGpsTooltip;

  /// No description provided for @mapSelectLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Select a location'**
  String get mapSelectLocationHint;

  /// No description provided for @mapConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get mapConfirmLocation;

  /// No description provided for @addressDialogNoSaved.
  ///
  /// In en, this message translates to:
  /// **'You have no saved addresses.'**
  String get addressDialogNoSaved;

  /// No description provided for @addressDialogLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit of 3 addresses reached.'**
  String get addressDialogLimitReached;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @addressNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Address'**
  String get addressNewTitle;

  /// No description provided for @addressSave.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get addressSave;

  /// No description provided for @addressSaveError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, there was an error saving the address.'**
  String get addressSaveError;

  /// No description provided for @addressNoConfigured.
  ///
  /// In en, this message translates to:
  /// **'You have not set a service address.'**
  String get addressNoConfigured;

  /// No description provided for @addressChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get addressChange;

  /// No description provided for @addressAdd.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addressAdd;

  /// No description provided for @addressMyAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'My address:'**
  String get addressMyAddressLabel;

  /// No description provided for @jobAddressVisitRequired.
  ///
  /// In en, this message translates to:
  /// **'Visit Address *'**
  String get jobAddressVisitRequired;

  /// No description provided for @jobAddressGoogleMapsHint.
  ///
  /// In en, this message translates to:
  /// **'Search address on Google Maps...'**
  String get jobAddressGoogleMapsHint;

  /// No description provided for @jobAddressValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter the address'**
  String get jobAddressValidation;

  /// No description provided for @addressTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Type your address...'**
  String get addressTypeHint;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search nearby services...'**
  String get exploreSearchHint;

  /// No description provided for @exploreUrgencyMode.
  ///
  /// In en, this message translates to:
  /// **'Urgency Mode'**
  String get exploreUrgencyMode;

  /// No description provided for @exploreUrgencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only professionals available now'**
  String get exploreUrgencySubtitle;

  /// No description provided for @exploreClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters ({count})'**
  String exploreClearFilters(int count);

  /// No description provided for @exploreVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get exploreVerified;

  /// No description provided for @exploreViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get exploreViewProfile;

  /// No description provided for @exploreSearchingServices.
  ///
  /// In en, this message translates to:
  /// **'Searching for services...'**
  String get exploreSearchingServices;

  /// No description provided for @exploreSearchThisArea.
  ///
  /// In en, this message translates to:
  /// **'Search in this area'**
  String get exploreSearchThisArea;

  /// No description provided for @filterSheetCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get filterSheetCategoriesTitle;

  /// No description provided for @filterSheetCategoryBreadcrumb.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterSheetCategoryBreadcrumb;

  /// No description provided for @filterSheetSubcategories.
  ///
  /// In en, this message translates to:
  /// **'{count} subcategories'**
  String filterSheetSubcategories(int count);

  /// No description provided for @filterSheetClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filterSheetClearAll;

  /// No description provided for @filterSheetSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search service'**
  String get filterSheetSearchPlaceholder;

  /// No description provided for @filterSheetInfoTip.
  ///
  /// In en, this message translates to:
  /// **'Browse and select the services you need'**
  String get filterSheetInfoTip;

  /// No description provided for @filterSheetNoServices.
  ///
  /// In en, this message translates to:
  /// **'No services found.'**
  String get filterSheetNoServices;

  /// No description provided for @filterSheetSelectedServices.
  ///
  /// In en, this message translates to:
  /// **'{count} services selected'**
  String filterSheetSelectedServices(int count);

  /// No description provided for @filterSheetApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filterSheetApply;

  /// No description provided for @filterSheetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get filterSheetCancel;

  /// No description provided for @jobsDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobsDescription;

  /// No description provided for @jobsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get jobsTotal;

  /// No description provided for @jobsVisitProposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit Proposal'**
  String get jobsVisitProposalTitle;

  /// No description provided for @jobsVisitProposalDesc.
  ///
  /// In en, this message translates to:
  /// **'The professional has scheduled a date and time for the visit:'**
  String get jobsVisitProposalDesc;

  /// No description provided for @jobsRejectedBy.
  ///
  /// In en, this message translates to:
  /// **'Rejected by: {name}'**
  String jobsRejectedBy(String name);

  /// No description provided for @jobsRejectedDefault.
  ///
  /// In en, this message translates to:
  /// **'Job Rejected / Cancelled'**
  String get jobsRejectedDefault;

  /// No description provided for @jobsRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason:'**
  String get jobsRejectionReason;

  /// No description provided for @jobsRejectDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Proposal'**
  String get jobsRejectDialogTitle;

  /// No description provided for @jobsRejectReasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Do you want to specify a rejection reason? (Optional)'**
  String get jobsRejectReasonOptional;

  /// No description provided for @jobsReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Write your reason here...'**
  String get jobsReasonHint;

  /// No description provided for @jobsRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Rejection'**
  String get jobsRejectConfirm;

  /// No description provided for @jobsCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get jobsCancelDialogTitle;

  /// No description provided for @jobsCancelDialogMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request? The professional will be notified.'**
  String get jobsCancelDialogMsg;

  /// No description provided for @jobsCancelReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason (optional):'**
  String get jobsCancelReasonLabel;

  /// No description provided for @jobsCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get jobsCancelConfirm;

  /// No description provided for @jobsYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get jobsYourRating;

  /// No description provided for @jobsRateProfessional.
  ///
  /// In en, this message translates to:
  /// **'Rate Professional'**
  String get jobsRateProfessional;

  /// No description provided for @jobsRejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get jobsRejectAction;

  /// No description provided for @jobsConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get jobsConfirmAction;
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
