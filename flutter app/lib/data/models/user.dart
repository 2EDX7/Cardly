import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the app with optional card info.
/// We use email as the stable identifier for now.
class User extends Equatable {
  final String id; // mirrors email as primary key
  final String fullName;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String themeMode; // 'system', 'light', 'dark'
  final String language; // 'en', 'fr', 'ar'
  
  // Profile card info (loaded with user)
  final String? cardName;
  final String? cardOrganization;
  final String? cardJobTitle;
  final String? cardEmail;
  final String? cardPhone;
  final String? cardLocation;
  final String? cardAbout;
  final String? cardWebsite;
  final String? cardLogoText;
  final String? cardCategory;
  final String? cardBackground; // serialized background
  final String? cardFontColor; // serialized color

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
    this.themeMode = 'system',
    this.language = 'en',
    this.cardName,
    this.cardOrganization,
    this.cardJobTitle,
    this.cardEmail,
    this.cardPhone,
    this.cardLocation,
    this.cardAbout,
    this.cardWebsite,
    this.cardLogoText,
    this.cardCategory,
    this.cardBackground,
    this.cardFontColor,
  });

  factory User.create({
    required String fullName,
    required String email,
    required String passwordHash,
  }) {
    final now = DateTime.now();
    return User(
      id: email,
      fullName: fullName,
      email: email,
      passwordHash: passwordHash,
      createdAt: now,
      updatedAt: now,
    );
  }

  User copyWith({
    String? fullName,
    String? passwordHash,
    DateTime? updatedAt,
    String? themeMode,
    String? language,
    String? cardName,
    String? cardOrganization,
    String? cardJobTitle,
    String? cardEmail,
    String? cardPhone,
    String? cardLocation,
    String? cardAbout,
    String? cardWebsite,
    String? cardLogoText,
    String? cardCategory,
    String? cardBackground,
    String? cardFontColor,
  }) {
    return User(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      cardName: cardName ?? this.cardName,
      cardOrganization: cardOrganization ?? this.cardOrganization,
      cardJobTitle: cardJobTitle ?? this.cardJobTitle,
      cardEmail: cardEmail ?? this.cardEmail,
      cardPhone: cardPhone ?? this.cardPhone,
      cardLocation: cardLocation ?? this.cardLocation,
      cardAbout: cardAbout ?? this.cardAbout,
      cardWebsite: cardWebsite ?? this.cardWebsite,
      cardLogoText: cardLogoText ?? this.cardLogoText,
      cardCategory: cardCategory ?? this.cardCategory,
      cardBackground: cardBackground ?? this.cardBackground,
      cardFontColor: cardFontColor ?? this.cardFontColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'themeMode': themeMode,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cardName': cardName,
      'cardOrganization': cardOrganization,
      'cardJobTitle': cardJobTitle,
      'cardEmail': cardEmail,
      'cardPhone': cardPhone,
      'cardLocation': cardLocation,
      'cardAbout': cardAbout,
      'cardWebsite': cardWebsite,
      'cardLogoText': cardLogoText,
      'cardCategory': cardCategory,
      'cardBackground': cardBackground,
      'cardFontColor': cardFontColor,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      themeMode: (map['themeMode'] as String?) ?? 'system',
      language: (map['language'] as String?) ?? 'en',
      // Card info fields from joined user_cards table
      cardName: map['cardName'] as String?,
      cardOrganization: map['cardOrganization'] as String?,
      cardJobTitle: map['cardJobTitle'] as String?,
      cardEmail: map['cardEmail'] as String?,
      cardPhone: map['cardPhone'] as String?,
      cardLocation: map['cardLocation'] as String?,
      cardAbout: map['cardAbout'] as String?,
      cardWebsite: map['cardWebsite'] as String?,
      cardLogoText: map['cardLogoText'] as String?,
      cardCategory: map['cardCategory'] as String?,
      cardBackground: map['cardBackground'] as String?,
      cardFontColor: map['cardFontColor'] as String?,
    );
  }

  /// Create User from JSON (for API responses)
  factory User.fromJson(Map<String, dynamic> json) {
    final preferences = json['preferences'] as Map<String, dynamic>?;
    
    return User(
      id: json['_id'] as String, // Backend uses _id
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      passwordHash: '', // Password not returned from backend
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      themeMode: preferences?['themeMode'] as String? ?? 'system',
      language: preferences?['language'] as String? ?? 'en',
    );
  }

  @override
  List<Object?> get props => [
    id, fullName, email, passwordHash, createdAt, updatedAt, themeMode, language,
    cardName, cardOrganization, cardJobTitle, cardEmail, cardPhone, cardLocation,
    cardAbout, cardWebsite, cardLogoText, cardCategory, cardBackground, cardFontColor,
  ];
}
