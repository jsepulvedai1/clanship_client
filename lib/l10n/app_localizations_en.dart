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
  String get homeSearchNeed => 'What do you need?';

  @override
  String get homeUrgency => 'Urgent';

  @override
  String get homeBannerTitle => 'Specific Services';

  @override
  String get homeBannerSubTitle =>
      'Post your requirement or check received quotes';

  @override
  String get homeBtnRequest => 'Request';

  @override
  String get homeBtnMyRequests => 'My Requests';

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
  String get settingsFrench => 'French';

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

  @override
  String get authSubtitle => 'Sign in to access your account';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authRegisterHere => 'Register here';

  @override
  String get authRegisterTitle => 'Create Account';

  @override
  String get authPersonalData => 'Personal Information';

  @override
  String get authLocationContact => 'Location & Contact';

  @override
  String get authFirstName => 'First Name';

  @override
  String get authLastName => 'Last Name';

  @override
  String get authBirthdate => 'Date of Birth';

  @override
  String get authRepeatEmail => 'Repeat Email';

  @override
  String get authRepeatPassword => 'Repeat Password';

  @override
  String get authPhone => 'Contact Phone';

  @override
  String get authAddress => 'Address';

  @override
  String get authAcceptTerms => 'I accept the terms and conditions of service';

  @override
  String get authProfilePhoto => 'Profile Photo';

  @override
  String get authCamera => 'Take photo with camera';

  @override
  String get authGallery => 'Choose from gallery';

  @override
  String get authNext => 'Next';

  @override
  String get authPrevious => 'Previous';

  @override
  String get authCompleteRegister => 'Complete Registration';

  @override
  String get authForgotTitle => 'Forgot Your Password?';

  @override
  String get authForgotSubtitle =>
      'Enter your email to receive recovery instructions';

  @override
  String get authSendCode => 'Send Code';

  @override
  String get authVerifyOtpTitle => 'Code Verification';

  @override
  String get authVerifyOtpSubtitle => 'Enter the code sent to your email';

  @override
  String get authResetTitle => 'New Password';

  @override
  String get authResetSubtitle => 'Enter and confirm your new password';

  @override
  String get authConfirmNewPassword => 'Confirm new password';

  @override
  String get authChangePasswordBtn => 'Change Password';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAccept => 'Accept';

  @override
  String get commonSave => 'Save';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get versionUpdateTitle => 'Update Required';

  @override
  String get versionUpdateMessage =>
      'To continue using Clanship safely, please update the app to the latest available version.';

  @override
  String get versionUpdateBtn => 'Update in App Store';

  @override
  String get sessionExpired => 'Your session was opened on another device.';

  @override
  String get settingsConfirmLogoutTitle => 'Log Out?';

  @override
  String get settingsConfirmLogoutMsg =>
      'Are you sure you want to log out of your current session?';

  @override
  String get settingsLogoutBtn => 'Log Out';

  @override
  String get searchTitle => 'Search Professional';

  @override
  String get searchFilterSpecialty => 'Filter by Specialty';

  @override
  String get searchNoResults => 'No professionals found';

  @override
  String get loginTaglinePart1 => 'Your trusted network ';

  @override
  String get loginTaglinePart2 => 'to solve your needs';

  @override
  String get loginConceptTrustTitle => 'Trust';

  @override
  String get loginConceptTrustSubtitle => 'Verification\n& security';

  @override
  String get loginConceptSpeedTitle => 'Speed';

  @override
  String get loginConceptSpeedSubtitle => 'Immediate\nresponse';

  @override
  String get loginConceptConnectionTitle => 'Connection';

  @override
  String get loginConceptConnectionSubtitle => 'People who\nsolve';

  @override
  String get loginBenefitVerified => 'Verified\nspecialists';

  @override
  String get loginBenefitRatings => 'Real\nreviews';

  @override
  String get loginBenefitTracking => 'Service\ntracking';

  @override
  String get loginInvalidCredentials => 'Incorrect email or password';

  @override
  String get loginForgotDialogTitle => 'Reset password';

  @override
  String get loginForgotDialogMessage =>
      'Enter your email address and we\'ll send instructions to reset your password.';

  @override
  String get loginForgotDialogEmailRequired =>
      'Please enter your email address.';

  @override
  String get authRegisterSubtitle => 'Create your account to get started';

  @override
  String get authStep1Subtitle => 'Complete your contact details to continue';

  @override
  String get authStep0FillAllFields => 'Please fill in all fields.';

  @override
  String get authStep0NameMaxLength =>
      'First name cannot exceed 30 characters.';

  @override
  String get authStep0LastNameMaxLength =>
      'Last name cannot exceed 30 characters.';

  @override
  String get authStep0EmailsDoNotMatch => 'Emails do not match.';

  @override
  String get authStep0InvalidEmail => 'Please enter a valid email address.';

  @override
  String get authStep0PasswordLength =>
      'Password must be at least 6 characters.';

  @override
  String get authStep0PasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authStep0AgeRestriction =>
      'You must be at least 18 years old to register.';

  @override
  String get authStep0TermsFooter =>
      'By registering you accept our\nTerms and Conditions and Privacy Policy';

  @override
  String get authPhotoUploaded => 'Profile photo uploaded ✓';

  @override
  String get authPhotoRequired =>
      'Profile photo * (Required: upload a clear photo of your face)';

  @override
  String get authPhotoPermissionError =>
      'Could not open camera or gallery. Please check permissions.';

  @override
  String get authMyAddress => 'My address';

  @override
  String get authReadTerms => 'Read the terms and conditions of use';

  @override
  String get authSubmitRegister => 'Register';

  @override
  String get authTermsDialogTitle => 'Terms and Conditions';

  @override
  String get mapSearchAddressHint => 'Search address...';

  @override
  String get mapCurrentGpsTooltip => 'Current GPS';

  @override
  String get mapSelectLocationHint => 'Select a location';

  @override
  String get mapConfirmLocation => 'Confirm Location';

  @override
  String get addressDialogNoSaved => 'You have no saved addresses.';

  @override
  String get addressDialogLimitReached => 'Limit of 3 addresses reached.';

  @override
  String get commonClose => 'Close';

  @override
  String get addressNewTitle => 'New Address';

  @override
  String get addressSave => 'Save address';

  @override
  String get addressSaveError =>
      'Sorry, there was an error saving the address.';

  @override
  String get addressNoConfigured => 'You have not set a service address.';

  @override
  String get addressChange => 'Change';

  @override
  String get addressAdd => 'Add address';

  @override
  String get addressMyAddressLabel => 'My address:';

  @override
  String get jobAddressVisitRequired => 'Visit Address *';

  @override
  String get jobAddressGoogleMapsHint => 'Search address on Google Maps...';

  @override
  String get jobAddressValidation => 'Enter the address';

  @override
  String get addressTypeHint => 'Type your address...';

  @override
  String get exploreSearchHint => 'Search nearby services...';

  @override
  String get exploreUrgencyMode => 'Urgency Mode';

  @override
  String get exploreUrgencySubtitle => 'Only professionals available now';

  @override
  String exploreClearFilters(int count) {
    return 'Clear filters ($count)';
  }

  @override
  String get exploreVerified => 'Verified';

  @override
  String get exploreViewProfile => 'View profile';

  @override
  String get exploreSearchingServices => 'Searching for services...';

  @override
  String get exploreSearchThisArea => 'Search in this area';

  @override
  String get filterSheetCategoriesTitle => 'Categories';

  @override
  String get filterSheetCategoryBreadcrumb => 'Category';

  @override
  String filterSheetSubcategories(int count) {
    return '$count subcategories';
  }

  @override
  String get filterSheetClearAll => 'Clear all';

  @override
  String get filterSheetSearchPlaceholder => 'Search service';

  @override
  String get filterSheetInfoTip => 'Browse and select the services you need';

  @override
  String get filterSheetNoServices => 'No services found.';

  @override
  String filterSheetSelectedServices(int count) {
    return '$count services selected';
  }

  @override
  String get filterSheetApply => 'Apply filters';

  @override
  String get filterSheetCancel => 'Cancel';

  @override
  String get jobsDescription => 'Job Description';

  @override
  String get jobsTotal => 'Total';

  @override
  String get jobsVisitProposalTitle => 'Visit Proposal';

  @override
  String get jobsVisitProposalDesc =>
      'The professional has scheduled a date and time for the visit:';

  @override
  String jobsRejectedBy(String name) {
    return 'Rejected by: $name';
  }

  @override
  String get jobsRejectedDefault => 'Job Rejected / Cancelled';

  @override
  String get jobsRejectionReason => 'Rejection reason:';

  @override
  String get jobsRejectDialogTitle => 'Reject Proposal';

  @override
  String get jobsRejectReasonOptional =>
      'Do you want to specify a rejection reason? (Optional)';

  @override
  String get jobsReasonHint => 'Write your reason here...';

  @override
  String get jobsRejectConfirm => 'Confirm Rejection';

  @override
  String get jobsCancelDialogTitle => 'Cancel Request';

  @override
  String get jobsCancelDialogMsg =>
      'Are you sure you want to cancel this request? The professional will be notified.';

  @override
  String get jobsCancelReasonLabel => 'Cancellation reason (optional):';

  @override
  String get jobsCancelConfirm => 'Confirm Cancellation';

  @override
  String get jobsYourRating => 'Your Rating';

  @override
  String get jobsRateProfessional => 'Rate Professional';

  @override
  String get jobsRejectAction => 'Reject';

  @override
  String get jobsConfirmAction => 'Confirm';
}
