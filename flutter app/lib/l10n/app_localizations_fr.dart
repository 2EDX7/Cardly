// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cardly';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get done => 'Terminé';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get close => 'Fermer';

  @override
  String get call => 'Appeler';

  @override
  String get email => 'Email';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get confirm => 'Confirmer';

  @override
  String get search => 'Rechercher';

  @override
  String get loading => 'Chargement...';

  @override
  String get retry => 'Réessayer';

  @override
  String get share => 'Partager';

  @override
  String get signInToAccount => 'Connectez-vous à votre\ncompte';

  @override
  String get enterEmailPassword =>
      'Entrez votre email et mot de passe pour vous connecter';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get or => 'OU';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte?';

  @override
  String get signUpNow => 'Inscrivez-vous maintenant';

  @override
  String get createAccount => 'Créez votre\ncompte';

  @override
  String get enterDetailsToSignUp => 'Entrez vos détails pour vous inscrire';

  @override
  String get fullName => 'Nom complet';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte?';

  @override
  String get signInNow => 'Connectez-vous maintenant';

  @override
  String get addCard => 'Ajouter une carte';

  @override
  String get enterCardId => 'Entrez l\'ID de la carte';

  @override
  String get cardRegisteredInApp =>
      'Si la carte de visite est enregistrée dans notre application';

  @override
  String get cardlyCardId => 'ID de carte Cardly';

  @override
  String get enter => 'Entrer';

  @override
  String get fillCardManually => 'Remplir la carte manuellement';

  @override
  String get fillManually => 'Remplir manuellement';

  @override
  String get scanQrCode => 'Scanner le code QR';

  @override
  String get scanCard => 'Scanner la carte';

  @override
  String get scan => 'Scanner';

  @override
  String get scanning => 'Numérisation...';

  @override
  String get pointCameraAtCard =>
      'Pointez votre appareil photo sur une carte de visite ou un code QR';

  @override
  String get fillCardInformations => 'Remplir les informations de la carte';

  @override
  String get addCardInformations => 'Ajouter les informations de la carte';

  @override
  String get phone => 'Téléphone';

  @override
  String get company => 'Entreprise';

  @override
  String get jobTitle => 'Titre du poste';

  @override
  String get location => 'Emplacement';

  @override
  String get website => 'Site web';

  @override
  String get about => 'À propos';

  @override
  String get previewCard => 'Aperçu de la carte';

  @override
  String get profile => 'Profil';

  @override
  String get cards => 'Cartes';

  @override
  String get settings => 'Paramètres';

  @override
  String get myCard => 'Ma carte';

  @override
  String get previewYourCard => 'Aperçu de la carte';

  @override
  String get cardCustomization => 'Personnalisation de la carte';

  @override
  String get fontColor => 'Couleur de la police';

  @override
  String get background => 'Arrière-plan';

  @override
  String get customColor => 'Couleur personnalisée';

  @override
  String get selectColor => 'Sélectionner une couleur';

  @override
  String get selectBackground => 'Sélectionner un arrière-plan';

  @override
  String get flipCard => 'Retourner la carte';

  @override
  String get editInformation => 'Modifier les informations';

  @override
  String get shareCard => 'Partager la carte';

  @override
  String get downloadQr => 'Télécharger le QR';

  @override
  String get editCardInformation => 'Modifier les informations de la carte';

  @override
  String get updateCard => 'Mettre à jour la carte';

  @override
  String get discardChanges => 'Annuler les modifications';

  @override
  String get errorGeneric => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get errorNetwork =>
      'Erreur réseau. Veuillez vérifier votre connexion.';

  @override
  String get errorInvalidEmail => 'Veuillez entrer une adresse email valide.';

  @override
  String get errorPasswordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get errorPasswordsDontMatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get errorEmptyField => 'Ce champ ne peut pas être vide.';

  @override
  String get errorCardIdEmpty => 'Veuillez entrer un ID de carte';

  @override
  String get successCardAdded => 'Carte ajoutée avec succès!';

  @override
  String get successCardUpdated => 'Carte mise à jour avec succès!';

  @override
  String get successCardDeleted => 'Carte supprimée avec succès!';

  @override
  String imageSelected(String fileName) {
    return 'Image sélectionnée: $fileName';
  }

  @override
  String get ocrProcessingComingSoon => 'Traitement OCR bientôt disponible!';

  @override
  String photoCaptured(String fileName) {
    return 'Photo capturée: $fileName';
  }

  @override
  String errorPickingImage(String error) {
    return 'Erreur lors de la sélection de l\'image: $error';
  }

  @override
  String errorTakingPhoto(String error) {
    return 'Erreur lors de la prise de photo: $error';
  }

  @override
  String lookingUpCardId(String cardId) {
    return 'Recherche de l\'ID de carte: $cardId...';
  }

  @override
  String get featureComingSoon => 'Fonctionnalité bientôt disponible!';

  @override
  String get language => 'Langue';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get theme => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirmation => 'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get noCardsYet => 'Pas encore de cartes';

  @override
  String get addYourFirstCard => 'Ajoutez votre première carte pour commencer';

  @override
  String get cardDetails => 'Détails de la carte';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get contactInfo => 'Informations de contact';

  @override
  String get additionalInfo => 'Informations supplémentaires';

  @override
  String get logIn => 'Se connecter';

  @override
  String get orLoginWith => 'Ou se connecter avec';

  @override
  String get enterYourFullName => 'Entrez votre nom complet';

  @override
  String get enterYourJobTitle => 'Entrez votre titre de poste';

  @override
  String get organizationName => 'Nom de l\'organisation';

  @override
  String get enterOrganizationName => 'Entrez le nom de l\'organisation';

  @override
  String get logoText => 'Texte du logo';

  @override
  String get enterLogoText => 'Entrez le texte du logo (abréviation)';

  @override
  String get enterYourEmail => 'Entrez votre email';

  @override
  String get enterYourPhone => 'Entrez votre numéro de téléphone';

  @override
  String get enterYourLocation => 'Entrez votre emplacement';

  @override
  String get enterYourWebsite => 'Entrez votre site web';

  @override
  String get tellUsAboutYourself => 'Parlez-nous de vous';

  @override
  String get pleaseEnterYourName => 'Veuillez entrer votre nom';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer votre email';

  @override
  String get pleaseEnterPhone => 'Veuillez entrer votre numéro de téléphone';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get alreadyHaveAnAccount => 'Vous avez déjà un compte?';

  @override
  String get myCards => 'Mes cartes';

  @override
  String get showCategories => 'Afficher les catégories';

  @override
  String get noCardsFound => 'Aucune carte trouvée';

  @override
  String get noCardsAvailable => 'Aucune carte disponible';

  @override
  String get deleteCard => 'Supprimer la carte';

  @override
  String areYouSureDeleteCard(String cardName) {
    return 'Êtes-vous sûr de vouloir supprimer la carte de $cardName?';
  }

  @override
  String cardDeleted(String cardName) {
    return 'Carte de $cardName supprimée';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get noCategoriesFound => 'Aucune catégorie trouvée';

  @override
  String get editCard => 'Modifier la carte';

  @override
  String get personalInformationCaps => 'INFORMATIONS PERSONNELLES';

  @override
  String get contactInformationCaps => 'INFORMATIONS DE CONTACT';

  @override
  String get additionalInformationCaps => 'INFORMATIONS SUPPLÉMENTAIRES';

  @override
  String get cardPreview => 'APERÇU DE LA CARTE';

  @override
  String get tapToFlip => 'appuyez pour retourner';

  @override
  String get swipeToFlip => 'glissez pour retourner';

  @override
  String get changeFontColor => 'CHANGER LA COULEUR DE LA POLICE';

  @override
  String get changeBackground => 'CHANGER L\'ARRIÈRE-PLAN';

  @override
  String get red => 'Rouge';

  @override
  String get green => 'Vert';

  @override
  String get blue => 'Bleu';

  @override
  String get splashTitle => 'Cardly';

  @override
  String get splashSubtitle => 'Vos cartes de visite numériques,\nRéinventées';

  @override
  String get splashDescription =>
      'Créez de superbes cartes de visite numériques qui laissent des impressions durables. Partagez vos informations de contact instantanément avec n\'importe qui, n\'importe où.';

  @override
  String get shareInstantly => 'Partage instantané';

  @override
  String get connectWithTap => 'Connectez-vous d\'un simple toucher';

  @override
  String get shareInstantlyDescription =>
      'Partagez vos informations de contact avec un simple scan de code QR ou un toucher. Plus besoin de chercher des cartes papier ou de saisir les détails manuellement.';

  @override
  String get ecoFriendly => 'Écologique';

  @override
  String get goGreenGoDigital => 'Passez au vert, passez au numérique';

  @override
  String get ecoFriendlyDescription =>
      'Sauvez les arbres et réduisez les déchets en passant au sans papier. Rejoignez des milliers de personnes qui font des choix de réseautage respectueux de l\'environnement.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get skip => 'Passer';

  @override
  String get searchForCard => 'Rechercher une carte';

  @override
  String get categoryOptional => 'Catégorie (Optionnel)';

  @override
  String get cardAddedSuccessfully => 'Carte ajoutée avec succès!';

  @override
  String get cardInformationUpdated => 'Informations de la carte mises à jour!';

  @override
  String get cardSavedSuccessfully => 'Carte enregistrée avec succès!';

  @override
  String get pleaseFillAllRequiredFields =>
      'Veuillez remplir tous les champs obligatoires';

  @override
  String couldNotLaunch(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String errorOpeningWebsite(String error) {
    return 'Erreur lors de l\'ouverture du site web: $error';
  }

  @override
  String get name => 'Nom';

  @override
  String get organization => 'Organisation';

  @override
  String get category => 'Catégorie';

  @override
  String get uncategorized => 'Non catégorisé';

  @override
  String get yourTitle => 'Votre titre';

  @override
  String get yourName => 'Your Name';

  @override
  String get yourCompany => 'Your Company';

  @override
  String get yourEmail => 'your.email@example.com';

  @override
  String get yourPhone => '0000000000';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get exampleWebsite => 'www.example.com';

  @override
  String get customBackgroundPicker =>
      'Sélecteur d\'arrière-plan personnalisé - À implémenter';

  @override
  String get apply => 'Appliquer';

  @override
  String get chooseCustomColor => 'Choisir une couleur personnalisée';

  @override
  String lookingUpCardIdFeature(String cardId) {
    return 'Recherche de l\'ID de carte: $cardId...\nFonctionnalité bientôt disponible!';
  }

  @override
  String get appTheme => 'Thème de l\'application';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get useSystemTheme => 'Utiliser le thème du système';

  @override
  String get notifications => 'Notifications';

  @override
  String get receiveNotifications => 'Recevoir des notifications';

  @override
  String get receiveNotificationsDesc =>
      'Soyez informé lorsque quelqu\'un collecte votre carte';

  @override
  String get personalInformation => 'INFORMATIONS PERSONNELLES';

  @override
  String get pleaseEnterYourJobTitle => 'Veuillez entrer votre titre de poste';

  @override
  String get organizationSection => 'ORGANISATION';

  @override
  String get pleaseEnterOrganizationName =>
      'Veuillez entrer le nom de l\'organisation';

  @override
  String get contactInformation => 'INFORMATIONS DE CONTACT';

  @override
  String get pleaseEnterValidEmail => 'Veuillez entrer un email valide';

  @override
  String get pleaseEnterYourPhoneNumber =>
      'Veuillez entrer votre numéro de téléphone';

  @override
  String get aboutSection => 'À PROPOS';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get createYourFirstCard => 'Créez votre première carte';
}
