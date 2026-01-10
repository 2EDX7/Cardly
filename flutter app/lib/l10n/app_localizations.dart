import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
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
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Cardly'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Sign in to your\nAccount'**
  String get signInToAccount;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to log in'**
  String get enterEmailPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUpNow.
  ///
  /// In en, this message translates to:
  /// **'Sign up now'**
  String get signUpNow;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your\nAccount'**
  String get createAccount;

  /// No description provided for @enterDetailsToSignUp.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to sign up'**
  String get enterDetailsToSignUp;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signInNow.
  ///
  /// In en, this message translates to:
  /// **'Sign in now'**
  String get signInNow;

  /// Add card screen title
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @enterCardId.
  ///
  /// In en, this message translates to:
  /// **'Enter the Card ID'**
  String get enterCardId;

  /// No description provided for @cardRegisteredInApp.
  ///
  /// In en, this message translates to:
  /// **'If the business card is registered in our app'**
  String get cardRegisteredInApp;

  /// No description provided for @cardlyCardId.
  ///
  /// In en, this message translates to:
  /// **'Cardly Card ID'**
  String get cardlyCardId;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @fillCardManually.
  ///
  /// In en, this message translates to:
  /// **'Fill The Card Manually'**
  String get fillCardManually;

  /// No description provided for @fillManually.
  ///
  /// In en, this message translates to:
  /// **'Fill Manually'**
  String get fillManually;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @scanCard.
  ///
  /// In en, this message translates to:
  /// **'Scan Card'**
  String get scanCard;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @pointCameraAtCard.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a business card or QR code'**
  String get pointCameraAtCard;

  /// No description provided for @fillCardInformations.
  ///
  /// In en, this message translates to:
  /// **'Fill Card Informations'**
  String get fillCardInformations;

  /// No description provided for @addCardInformations.
  ///
  /// In en, this message translates to:
  /// **'Add Card Informations'**
  String get addCardInformations;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @previewCard.
  ///
  /// In en, this message translates to:
  /// **'Preview Card'**
  String get previewCard;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myCard.
  ///
  /// In en, this message translates to:
  /// **'My Card'**
  String get myCard;

  /// No description provided for @previewYourCard.
  ///
  /// In en, this message translates to:
  /// **'Preview Card'**
  String get previewYourCard;

  /// No description provided for @cardCustomization.
  ///
  /// In en, this message translates to:
  /// **'Card Customization'**
  String get cardCustomization;

  /// No description provided for @fontColor.
  ///
  /// In en, this message translates to:
  /// **'Font Color'**
  String get fontColor;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @selectBackground.
  ///
  /// In en, this message translates to:
  /// **'Select Background'**
  String get selectBackground;

  /// No description provided for @flipCard.
  ///
  /// In en, this message translates to:
  /// **'Flip Card'**
  String get flipCard;

  /// No description provided for @editInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get editInformation;

  /// No description provided for @shareCard.
  ///
  /// In en, this message translates to:
  /// **'Share Card'**
  String get shareCard;

  /// No description provided for @downloadQr.
  ///
  /// In en, this message translates to:
  /// **'Download QR'**
  String get downloadQr;

  /// No description provided for @editCardInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit Card Information'**
  String get editCardInformation;

  /// No description provided for @updateCard.
  ///
  /// In en, this message translates to:
  /// **'Update Card'**
  String get updateCard;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get discardChanges;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordsDontMatch;

  /// No description provided for @errorEmptyField.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty.'**
  String get errorEmptyField;

  /// No description provided for @errorCardIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Card ID'**
  String get errorCardIdEmpty;

  /// No description provided for @successCardAdded.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully!'**
  String get successCardAdded;

  /// No description provided for @successCardUpdated.
  ///
  /// In en, this message translates to:
  /// **'Card updated successfully!'**
  String get successCardUpdated;

  /// No description provided for @successCardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Card deleted successfully!'**
  String get successCardDeleted;

  /// Message shown when an image is selected
  ///
  /// In en, this message translates to:
  /// **'Image selected: {fileName}'**
  String imageSelected(String fileName);

  /// No description provided for @ocrProcessingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'OCR processing coming soon!'**
  String get ocrProcessingComingSoon;

  /// Message shown when a photo is captured
  ///
  /// In en, this message translates to:
  /// **'Photo captured: {fileName}'**
  String photoCaptured(String fileName);

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// No description provided for @errorTakingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error taking photo: {error}'**
  String errorTakingPhoto(String error);

  /// No description provided for @lookingUpCardId.
  ///
  /// In en, this message translates to:
  /// **'Looking up card ID: {cardId}...'**
  String lookingUpCardId(String cardId);

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon!'**
  String get featureComingSoon;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @noCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get noCardsYet;

  /// No description provided for @addYourFirstCard.
  ///
  /// In en, this message translates to:
  /// **'Add your first card to get started'**
  String get addYourFirstCard;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetails;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInfo;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get orLoginWith;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @enterYourJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your job title'**
  String get enterYourJobTitle;

  /// No description provided for @organizationName.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get organizationName;

  /// No description provided for @enterOrganizationName.
  ///
  /// In en, this message translates to:
  /// **'Enter organization name'**
  String get enterOrganizationName;

  /// No description provided for @logoText.
  ///
  /// In en, this message translates to:
  /// **'Logo Text'**
  String get logoText;

  /// No description provided for @enterLogoText.
  ///
  /// In en, this message translates to:
  /// **'Enter logo text (abbreviation)'**
  String get enterLogoText;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhone;

  /// No description provided for @enterYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter your location'**
  String get enterYourLocation;

  /// No description provided for @enterYourWebsite.
  ///
  /// In en, this message translates to:
  /// **'Enter your website'**
  String get enterYourWebsite;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @myCards.
  ///
  /// In en, this message translates to:
  /// **'My Cards'**
  String get myCards;

  /// No description provided for @showCategories.
  ///
  /// In en, this message translates to:
  /// **'Show Categories'**
  String get showCategories;

  /// No description provided for @noCardsFound.
  ///
  /// In en, this message translates to:
  /// **'No cards found'**
  String get noCardsFound;

  /// No description provided for @noCardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No cards available'**
  String get noCardsAvailable;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// No description provided for @areYouSureDeleteCard.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {cardName}\'s card?'**
  String areYouSureDeleteCard(String cardName);

  /// No description provided for @cardDeleted.
  ///
  /// In en, this message translates to:
  /// **'{cardName}\'s card deleted'**
  String cardDeleted(String cardName);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @personalInformationCaps.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFORMATION'**
  String get personalInformationCaps;

  /// No description provided for @contactInformationCaps.
  ///
  /// In en, this message translates to:
  /// **'CONTACT INFORMATION'**
  String get contactInformationCaps;

  /// No description provided for @additionalInformationCaps.
  ///
  /// In en, this message translates to:
  /// **'ADDITIONAL INFORMATION'**
  String get additionalInformationCaps;

  /// No description provided for @cardPreview.
  ///
  /// In en, this message translates to:
  /// **'CARD PREVIEW'**
  String get cardPreview;

  /// No description provided for @tapToFlip.
  ///
  /// In en, this message translates to:
  /// **'tap to flip'**
  String get tapToFlip;

  /// No description provided for @swipeToFlip.
  ///
  /// In en, this message translates to:
  /// **'swipe to flip'**
  String get swipeToFlip;

  /// No description provided for @changeFontColor.
  ///
  /// In en, this message translates to:
  /// **'CHANGE FONT COLOR'**
  String get changeFontColor;

  /// No description provided for @changeBackground.
  ///
  /// In en, this message translates to:
  /// **'CHANGE BACKGROUND'**
  String get changeBackground;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Cardly'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Digital Business Cards,\nReimagined'**
  String get splashSubtitle;

  /// No description provided for @splashDescription.
  ///
  /// In en, this message translates to:
  /// **'Create stunning digital business cards that make lasting impressions. Share your contact information instantly with anyone, anywhere.'**
  String get splashDescription;

  /// No description provided for @shareInstantly.
  ///
  /// In en, this message translates to:
  /// **'Share Instantly'**
  String get shareInstantly;

  /// No description provided for @connectWithTap.
  ///
  /// In en, this message translates to:
  /// **'Connect with a Tap'**
  String get connectWithTap;

  /// No description provided for @shareInstantlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Share your contact info with a simple QR code scan or tap. No more fumbling with paper cards or typing details manually.'**
  String get shareInstantlyDescription;

  /// No description provided for @ecoFriendly.
  ///
  /// In en, this message translates to:
  /// **'Eco-Friendly'**
  String get ecoFriendly;

  /// No description provided for @goGreenGoDigital.
  ///
  /// In en, this message translates to:
  /// **'Go Green, Go Digital'**
  String get goGreenGoDigital;

  /// No description provided for @ecoFriendlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Save trees and reduce waste by going paperless. Join thousands making environmentally conscious networking choices.'**
  String get ecoFriendlyDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @searchForCard.
  ///
  /// In en, this message translates to:
  /// **'Search for a card'**
  String get searchForCard;

  /// No description provided for @categoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Category (Optional)'**
  String get categoryOptional;

  /// No description provided for @cardAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully!'**
  String get cardAddedSuccessfully;

  /// No description provided for @cardInformationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Card information updated!'**
  String get cardInformationUpdated;

  /// No description provided for @cardSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Card saved successfully!'**
  String get cardSavedSuccessfully;

  /// No description provided for @pleaseFillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillAllRequiredFields;

  /// No description provided for @couldNotLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunch(String url);

  /// No description provided for @errorOpeningWebsite.
  ///
  /// In en, this message translates to:
  /// **'Error opening website: {error}'**
  String errorOpeningWebsite(String error);

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @yourTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Title'**
  String get yourTitle;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @yourCompany.
  ///
  /// In en, this message translates to:
  /// **'Your Company'**
  String get yourCompany;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get yourEmail;

  /// No description provided for @yourPhone.
  ///
  /// In en, this message translates to:
  /// **'0000000000'**
  String get yourPhone;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @exampleWebsite.
  ///
  /// In en, this message translates to:
  /// **'www.example.com'**
  String get exampleWebsite;

  /// No description provided for @customBackgroundPicker.
  ///
  /// In en, this message translates to:
  /// **'Custom background picker - To be implemented'**
  String get customBackgroundPicker;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @chooseCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Custom Color'**
  String get chooseCustomColor;

  /// No description provided for @lookingUpCardIdFeature.
  ///
  /// In en, this message translates to:
  /// **'Looking up card ID: {cardId}...\nFeature coming soon!'**
  String lookingUpCardIdFeature(String cardId);

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @useSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Use System Theme'**
  String get useSystemTheme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @receiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive Notifications'**
  String get receiveNotifications;

  /// No description provided for @receiveNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone collects your card'**
  String get receiveNotificationsDesc;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFORMATION'**
  String get personalInformation;

  /// No description provided for @pleaseEnterYourJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your job title'**
  String get pleaseEnterYourJobTitle;

  /// No description provided for @organizationSection.
  ///
  /// In en, this message translates to:
  /// **'ORGANIZATION'**
  String get organizationSection;

  /// No description provided for @pleaseEnterOrganizationName.
  ///
  /// In en, this message translates to:
  /// **'Please enter organization name'**
  String get pleaseEnterOrganizationName;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'CONTACT INFORMATION'**
  String get contactInformation;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get aboutSection;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Button text to create first card on home page
  ///
  /// In en, this message translates to:
  /// **'Create Your First Card'**
  String get createYourFirstCard;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
