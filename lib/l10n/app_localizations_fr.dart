// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginTitle => 'Bienvenue';

  @override
  String get loginEmailLabel => 'Adresse e-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSignInButton => 'Se connecter';

  @override
  String loginWelcomeMessage(String name) {
    return 'Bienvenue $name';
  }

  @override
  String loginError(String message) {
    return 'Erreur: $message';
  }

  @override
  String homeGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get homeSearchPlaceholder => 'Quel professionnel cherchez-vous ?';

  @override
  String get homeSearchNeed => 'De quoi avez-vous besoin ?';

  @override
  String get homeUrgency => 'Urgence';

  @override
  String get homeBannerTitle => 'Services spécifiques';

  @override
  String get homeBannerSubTitle =>
      'Publiez votre besoin ou consultez vos devis reçus';

  @override
  String get homeBtnRequest => 'Demander';

  @override
  String get homeBtnMyRequests => 'Mes demandes';

  @override
  String get homeTagNear => 'Les plus proches';

  @override
  String get homeTagTopRated => 'Les mieux notés';

  @override
  String get homeViewAll => 'Voir tout';

  @override
  String get profDetailHire => 'Engager maintenant';

  @override
  String get profDetailAbout => 'À propos de moi';

  @override
  String get profDetailStats => 'Statistiques';

  @override
  String profDetailReviews(String count, String reviews) {
    return '$count ($reviews avis)';
  }

  @override
  String get profDetailFindMe => 'Retrouvez-moi sur :';

  @override
  String get profDetailDocuments => 'Documents';

  @override
  String get profDetailContact => 'Contacter';

  @override
  String get addressDialogTitle => 'Votre adresse';

  @override
  String get addressDialogAdd => 'Ajouter une nouvelle adresse';

  @override
  String get addressDialogYes => 'Oui';

  @override
  String get addressDialogNo => 'Non';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesEmptyTitle => 'Pas encore de favoris';

  @override
  String get favoritesEmptySubtitle =>
      'Enregistrez vos professionnels de confiance pour les retrouver plus rapidement la prochaine fois.';

  @override
  String get favoritesExplore => 'Explorer les professionnels';

  @override
  String get matchingCancel => 'Annuler la demande';

  @override
  String get matchingSearching => 'Recherche de correspondance...';

  @override
  String matchingConnecting(String name) {
    return 'Connexion avec $name';
  }

  @override
  String get matchingSuccess => 'Correspondance réussie !';

  @override
  String matchingAccepted(String name) {
    return '$name a accepté de vous contacter.';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsEnglish => 'Anglais';

  @override
  String get settingsSpanish => 'Espagnol';

  @override
  String get settingsFrench => 'Français';

  @override
  String get chatStatusOnline => 'En ligne';

  @override
  String get chatInputPlaceholder => 'Écrivez un message...';

  @override
  String get jobsTitle => 'Mes Travaux';

  @override
  String get jobsEmptyTitle => 'Aucun travail actif pour le moment';

  @override
  String get jobsEmptySubtitle => 'Vos correspondances apparaîtront ici.';

  @override
  String get jobsViewDetail => 'Voir le détail';

  @override
  String get jobsStatusPending => 'En attente';

  @override
  String get jobsStatusActive => 'Actif';

  @override
  String get jobsStatusRejected => 'Rejeté';

  @override
  String get jobsStatusCompleted => 'Terminé';

  @override
  String get jobsRequestsTitle => 'Demandes';

  @override
  String get jobsInProcess => 'En cours';

  @override
  String get jobsFinished => 'Terminées';

  @override
  String jobsArrivalInfo(String time) {
    return 'arrive dans $time';
  }

  @override
  String get jobsDetailTitle => 'Détails du travail';

  @override
  String get jobsTotalValue => 'Valeur totale';

  @override
  String get jobsGoToChat => 'Aller au chat';

  @override
  String get jobsCancel => 'Annuler';

  @override
  String get jobsBack => 'Retour';

  @override
  String get chatActionUrgent => 'Urgent';

  @override
  String get chatActionCall => 'Appeler';

  @override
  String get chatActionLocation => 'Localisation';

  @override
  String get matchingConfirmTitle => 'Avant de demander !';

  @override
  String get matchingConfirmSubtitle =>
      'N\'oubliez pas de confirmer qu\'il s\'agit de la bonne adresse';

  @override
  String get matchingConfirmAddressLabel => 'Confirmer l\'adresse';

  @override
  String get matchingConfirmWarning =>
      'Veuillez noter que l\'adresse ne pourra pas être modifiée au cours de la demande. Vérifiez attentivement l\'adresse.';

  @override
  String get matchingConfirmAction => 'Demander';

  @override
  String get settingsPersonalInfo => 'Informations personnelles';

  @override
  String get settingsEditData => 'Modifier mes données';

  @override
  String get settingsMyPlan => 'Mon forfait actuel';

  @override
  String get settingsMyDocs => 'Mes documents';

  @override
  String get settingsVerificationStatus => 'Statut de vérification';

  @override
  String get settingsChooseLanguage => 'Changer de langue';

  @override
  String get settingsSupport => 'Support technique';

  @override
  String get settingsTerms => 'Conditions générales';

  @override
  String get chatActionEnrich => 'Ajouter des détails';

  @override
  String get chatActionJob => 'Travail';

  @override
  String get chatJobCreatedSuccess => 'Demande de travail créée avec succès';

  @override
  String get chatJobCreatedMessage => 'J\'ai créé une demande de travail.';

  @override
  String get chatEnrichTitle => 'Détails de la demande';

  @override
  String get chatEnrichHint =>
      'Décrivez le problème plus en détail, ajoutez des marques d\'équipement ou des instructions...';

  @override
  String get chatEnrichAttachPhoto => 'Joindre une photo du problème';

  @override
  String get chatEnrichEnterDetailsError =>
      'Veuillez saisir les détails supplémentaires.';

  @override
  String get chatEnrichSuccess => 'Détails ajoutés avec succès.';

  @override
  String get chatEnrichMessage =>
      'J\'ai ajouté des détails supplémentaires à la demande.';

  @override
  String get chatEnrichConfirm => 'Confirmer et envoyer';

  @override
  String get navHome => 'Accueil';

  @override
  String get navJobs => 'Travaux';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navSettings => 'Profil';

  @override
  String get authSubtitle => 'Connectez-vous pour accéder à votre compte';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authNoAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get authRegisterHere => 'Inscrivez-vous ici';

  @override
  String get authRegisterTitle => 'Créer un compte';

  @override
  String get authPersonalData => 'Données personnelles';

  @override
  String get authLocationContact => 'Localisation et contact';

  @override
  String get authFirstName => 'Prénom';

  @override
  String get authLastName => 'Nom';

  @override
  String get authBirthdate => 'Date de naissance';

  @override
  String get authRepeatEmail => 'Répéter l\'e-mail';

  @override
  String get authRepeatPassword => 'Répéter le mot de passe';

  @override
  String get authPhone => 'Téléphone de contact';

  @override
  String get authAddress => 'Adresse';

  @override
  String get authAcceptTerms => 'J\'accepte les conditions d\'utilisation';

  @override
  String get authProfilePhoto => 'Photo de profil';

  @override
  String get authCamera => 'Prendre une photo avec l\'appareil';

  @override
  String get authGallery => 'Choisir dans la galerie';

  @override
  String get authNext => 'Suivant';

  @override
  String get authPrevious => 'Précédent';

  @override
  String get authCompleteRegister => 'Terminer l\'inscription';

  @override
  String get authForgotTitle => 'Mot de passe oublié ?';

  @override
  String get authForgotSubtitle =>
      'Entrez votre e-mail pour recevoir les instructions';

  @override
  String get authSendCode => 'Envoyer le code';

  @override
  String get authVerifyOtpTitle => 'Vérification du code';

  @override
  String get authVerifyOtpSubtitle => 'Entrez le code envoyé à votre e-mail';

  @override
  String get authResetTitle => 'Nouveau mot de passe';

  @override
  String get authResetSubtitle =>
      'Entrez et confirmez votre nouveau mot de passe';

  @override
  String get authConfirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get authChangePasswordBtn => 'Changer le mot de passe';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonAccept => 'Accepter';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonSuccess => 'Succès';

  @override
  String get versionUpdateTitle => 'Mise à jour requise';

  @override
  String get versionUpdateMessage =>
      'Pour continuer à utiliser Clanship en toute sécurité, veuillez mettre à jour l\'application.';

  @override
  String get versionUpdateBtn => 'Mettre à jour sur le Store';

  @override
  String get sessionExpired =>
      'Votre session a été ouverte sur un autre appareil.';

  @override
  String get settingsConfirmLogoutTitle => 'Se déconnecter ?';

  @override
  String get settingsConfirmLogoutMsg =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get settingsLogoutBtn => 'Se déconnecter';

  @override
  String get searchTitle => 'Rechercher un professionnel';

  @override
  String get searchFilterSpecialty => 'Filtrer par spécialité';

  @override
  String get searchNoResults => 'Aucun professionnel trouvé';

  @override
  String get loginTaglinePart1 => 'Votre réseau de confiance ';

  @override
  String get loginTaglinePart2 => 'pour répondre à vos besoins';

  @override
  String get loginConceptTrustTitle => 'Confiance';

  @override
  String get loginConceptTrustSubtitle => 'Vérification\net sécurité';

  @override
  String get loginConceptSpeedTitle => 'Rapidité';

  @override
  String get loginConceptSpeedSubtitle => 'Réponse\nimmédiate';

  @override
  String get loginConceptConnectionTitle => 'Connexion';

  @override
  String get loginConceptConnectionSubtitle => 'Des personnes qui\nrésolvent';

  @override
  String get loginBenefitVerified => 'Spécialistes\nvérifiés';

  @override
  String get loginBenefitRatings => 'Évaluations\nréelles';

  @override
  String get loginBenefitTracking => 'Suivi des\nservices';

  @override
  String get loginInvalidCredentials => 'E-mail ou mot de passe incorrect';

  @override
  String get loginForgotDialogTitle => 'Réinitialiser le mot de passe';

  @override
  String get loginForgotDialogMessage =>
      'Entrez votre adresse e-mail et nous vous enverrons des instructions pour réinitialiser votre mot de passe.';

  @override
  String get loginForgotDialogEmailRequired =>
      'Veuillez entrer votre adresse e-mail.';

  @override
  String get authRegisterSubtitle => 'Créez votre compte pour commencer';

  @override
  String get authStep1Subtitle => 'Complétez vos coordonnées pour continuer';

  @override
  String get authStep0FillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get authStep0NameMaxLength =>
      'Le prénom ne peut pas dépasser 30 caractères.';

  @override
  String get authStep0LastNameMaxLength =>
      'Le nom ne peut pas dépasser 30 caractères.';

  @override
  String get authStep0EmailsDoNotMatch => 'Les e-mails ne correspondent pas.';

  @override
  String get authStep0InvalidEmail => 'Veuillez entrer un e-mail valide.';

  @override
  String get authStep0PasswordLength =>
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get authStep0PasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get authStep0AgeRestriction =>
      'Vous devez avoir au moins 18 ans pour vous inscrire.';

  @override
  String get authStep0TermsFooter =>
      'En vous inscrivant, vous acceptez nos\nConditions Générales et Politique de Confidentialité';

  @override
  String get authPhotoUploaded => 'Photo de profil téléchargée ✓';

  @override
  String get authPhotoRequired =>
      'Photo de profil * (Obligatoire : téléchargez une photo claire de votre visage)';

  @override
  String get authPhotoPermissionError =>
      'Impossible d\'ouvrir l\'appareil photo ou la galerie. Veuillez vérifier les autorisations.';

  @override
  String get authMyAddress => 'Mon adresse';

  @override
  String get authReadTerms => 'Lire les conditions d\'utilisation';

  @override
  String get authSubmitRegister => 'S\'inscrire';

  @override
  String get authTermsDialogTitle => 'Conditions Générales';

  @override
  String get mapSearchAddressHint => 'Rechercher une adresse...';

  @override
  String get mapCurrentGpsTooltip => 'GPS Actuel';

  @override
  String get mapSelectLocationHint => 'Sélectionnez un emplacement';

  @override
  String get mapConfirmLocation => 'Confirmer l\'emplacement';

  @override
  String get addressDialogNoSaved => 'Vous n\'avez aucune adresse enregistrée.';

  @override
  String get addressDialogLimitReached => 'Limite de 3 adresses atteinte.';

  @override
  String get commonClose => 'Fermer';

  @override
  String get addressNewTitle => 'Nouvelle Adresse';

  @override
  String get addressSave => 'Enregistrer l\'adresse';

  @override
  String get addressSaveError =>
      'Désolé, une erreur s\'est produite lors de l\'enregistrement de l\'adresse.';

  @override
  String get addressNoConfigured =>
      'Vous n\'avez pas configuré d\'adresse de service.';

  @override
  String get addressChange => 'Changer';

  @override
  String get addressAdd => 'Ajouter une adresse';

  @override
  String get addressMyAddressLabel => 'Mon adresse :';

  @override
  String get jobAddressVisitRequired => 'Adresse de Visite *';

  @override
  String get jobAddressGoogleMapsHint =>
      'Rechercher une adresse sur Google Maps...';

  @override
  String get jobAddressValidation => 'Entrez l\'adresse';

  @override
  String get addressTypeHint => 'Tapez votre adresse...';

  @override
  String get exploreSearchHint => 'Rechercher des services à proximité...';

  @override
  String get exploreUrgencyMode => 'Mode d\'Urgence';

  @override
  String get exploreUrgencySubtitle =>
      'Uniquement les professionnels disponibles maintenant';

  @override
  String exploreClearFilters(int count) {
    return 'Effacer les filtres ($count)';
  }

  @override
  String get exploreVerified => 'Vérifié';

  @override
  String get exploreViewProfile => 'Voir le profil';

  @override
  String get exploreSearchingServices => 'Recherche de services...';

  @override
  String get exploreSearchThisArea => 'Rechercher dans cette zone';

  @override
  String get filterSheetCategoriesTitle => 'Catégories';

  @override
  String get filterSheetCategoryBreadcrumb => 'Catégorie';

  @override
  String filterSheetSubcategories(int count) {
    return '$count sous-catégories';
  }

  @override
  String get filterSheetClearAll => 'Tout effacer';

  @override
  String get filterSheetSearchPlaceholder => 'Rechercher un service';

  @override
  String get filterSheetInfoTip =>
      'Parcourez et sélectionnez les services dont vous avez besoin';

  @override
  String get filterSheetNoServices => 'Aucun service trouvé.';

  @override
  String filterSheetSelectedServices(int count) {
    return '$count services sélectionnés';
  }

  @override
  String get filterSheetApply => 'Appliquer les filtres';

  @override
  String get filterSheetCancel => 'Annuler';

  @override
  String get jobsDescription => 'Description du travail';

  @override
  String get jobsTotal => 'Total';

  @override
  String get jobsVisitProposalTitle => 'Proposition de visite';

  @override
  String get jobsVisitProposalDesc =>
      'Le professionnel a programmé une date et une heure pour la visite :';

  @override
  String jobsRejectedBy(String name) {
    return 'Rejeté par : $name';
  }

  @override
  String get jobsRejectedDefault => 'Travail rejeté / annulé';

  @override
  String get jobsRejectionReason => 'Motif du refus :';

  @override
  String get jobsRejectDialogTitle => 'Refuser la proposition';

  @override
  String get jobsRejectReasonOptional =>
      'Souhaitez-vous indiquer un motif de refus ? (Optionnel)';

  @override
  String get jobsReasonHint => 'Écrivez votre raison ici...';

  @override
  String get jobsRejectConfirm => 'Confirmer le refus';

  @override
  String get jobsCancelDialogTitle => 'Annuler la demande';

  @override
  String get jobsCancelDialogMsg =>
      'Êtes-vous sûr de vouloir annuler cette demande ? Le professionnel sera notifié.';

  @override
  String get jobsCancelReasonLabel => 'Motif d\'annulation (optionnel) :';

  @override
  String get jobsCancelConfirm => 'Confirmer l\'annulation';

  @override
  String get jobsYourRating => 'Votre évaluation';

  @override
  String get jobsRateProfessional => 'Évaluer le professionnel';

  @override
  String get jobsRejectAction => 'Refuser';

  @override
  String get jobsConfirmAction => 'Confirmer';

  @override
  String get authTermsAndEula => 'Conditions & EULA';

  @override
  String get eulaTitle => 'Conditions Générales (EULA)';

  @override
  String get eulaSubtitle =>
      'Contrat de Licence Utilisateur Final & Modération';

  @override
  String get eulaZeroToleranceTitle => 'POLITIQUE DE TOLÉRANCE ZÉRO';

  @override
  String get eulaZeroToleranceBody =>
      'Clanship applique une politique stricte de TOLÉRANCE ZÉRO contre tout contenu répréhensible, offensant, discriminatoire, abusif, sexuel ou spam, ainsi que contre les utilisateurs ayant un comportement abusif.';

  @override
  String get eulaSection1Title =>
      '1. Contrat de Licence Utilisateur Final (EULA)';

  @override
  String get eulaSection1Body =>
      'En téléchargeant, installant, vous inscrivant ou utilisant l\'application Clanship, vous acceptez d\'être lié par ces Conditions d\'utilisation et ce Contrat de licence (EULA). Si vous n\'acceptez pas ces conditions, vous ne devez pas utiliser l\'application.';

  @override
  String get eulaSection2Title =>
      '2. Règles de la communauté & Contenu interdit';

  @override
  String get eulaSection2Intro =>
      'En tant que utilisateur, vous vous engagez à ne pas télécharger, publier, envoyer ni partager :';

  @override
  String get eulaSection2Bullet1 =>
      'Contenu sexuellement explicite, pornographique ou violent.';

  @override
  String get eulaSection2Bullet2 =>
      'Discours de haine, harcèlement, diffamation, menaces ou discrimination pour quelque motif que ce soit.';

  @override
  String get eulaSection2Bullet3 =>
      'Informations fausses ou frauduleuses, escroqueries ou usurpation d\'identité.';

  @override
  String get eulaSection2Bullet4 =>
      'Contenu portant atteinte à la propriété intellectuelle ou aux droits de tiers.';

  @override
  String get eulaSection3Title => '3. Outils de Signalement & Blocage';

  @override
  String get eulaSection3Intro =>
      'Pour protéger notre communauté, Clanship fournit des outils accessibles sur l\'ensemble de la plateforme :';

  @override
  String get eulaSection3Bullet1 =>
      'Bloquer les utilisateurs abusifs : Vous pouvez bloquer tout professionnel ou utilisateur immédiatement depuis le chat ou son profil. Une fois bloqué, son contenu et ses messages disparaîtront immédiatement de votre vue.';

  @override
  String get eulaSection3Bullet2 =>
      'Signaler un contenu ou des utilisateurs : Vous pouvez signaler tout message, photo ou profil à l\'aide du bouton de signalement.';

  @override
  String get eulaSection3Bullet3 =>
      'Engagement de modération sous 24 heures : Notre équipe examine chaque signalement dans les 24 heures. Tout contenu répréhensible sera supprimé et les utilisateurs contrevenants définitivement exclus.';

  @override
  String get eulaSection4Title => '4. Nature du Service & Responsabilité';

  @override
  String get eulaSection4Body =>
      'Clanship opère en tant que plateforme technologique de mise en relation connectant clients et professionnels techniques indépendants. Chaque prestation est convenue directement entre les parties.';

  @override
  String get eulaSection5Title => '5. Confidentialité & Sécurité';

  @override
  String get eulaSection5Body =>
      'Vos données personnelles et de localisation sont traitées conformément à notre Politique de confidentialité uniquement pour la fourniture des services demandés et des fins de sécurité.';

  @override
  String get eulaWebLink =>
      'Consulter les conditions complètes sur le site officiel';

  @override
  String get eulaAcceptButton =>
      'J\'accepte les conditions et la politique EULA';

  @override
  String get eulaCloseButton => 'Compris et Fermer';

  @override
  String get authReferralCodeLabel =>
      'Code d\'associé ou d\'invitation (Facultatif)';

  @override
  String get authReferralCodeHint => 'Ex : CLAN-ABC12';

  @override
  String get authReferralValid => 'Code valide';

  @override
  String get authReferralInvalid => 'Code non trouvé ou inactif';
}
