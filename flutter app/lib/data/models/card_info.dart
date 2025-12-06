import 'package:flutter/material.dart';
import '../../../presentation/widgets/business_card/card_background.dart';

/// Model class representing a business card with all its information
class CardInfo {
  int? id;
  String name;
  String organization;
  String jobTitle;
  String email;
  String phone;
  String location;
  String about;
  String website;
  String? logoText;
  String? category;
  CardBackground? background;
  String? userId;
  Color? fontColor;

  CardInfo({
    this.id,
    required this.name,
    required this.organization,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.location,
    required this.about,
    required this.website,
    this.logoText,
    this.category,
    this.background,
    this.userId,
    this.fontColor,
  });

  /// Create a copy of this card with some fields updated
  CardInfo copyWith({
    int? id,
    String? name,
    String? organization,
    String? jobTitle,
    String? email,
    String? phone,
    String? location,
    String? about,
    String? website,
    String? logoText,
    String? category,
    CardBackground? background,
    String? userId,
    Color? fontColor,
  }) {
    return CardInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      organization: organization ?? this.organization,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      about: about ?? this.about,
      website: website ?? this.website,
      logoText: logoText ?? this.logoText,
      category: category ?? this.category,
      background: background ?? this.background,
      userId: userId ?? this.userId,
      fontColor: fontColor ?? this.fontColor,
    );
  }

  /// Convert to Map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'about': about,
      'website': website,
      'logoText': logoText,
      'category': category,
      'background': background?.toString(),
      'userId': userId,
      'fontColor': fontColor != null ? '#${fontColor!.value.toRadixString(16).padLeft(8, '0')}' : null,
    };
  }

  /// Convert to JSON for QR code generation
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'organization': organization,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'about': about,
      'website': website,
      'logoText': logoText,
      'category': category,
    };
  }

  /// Create from JSON (for QR code scanning)
  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      name: json['name'] ?? '',
      organization: json['organization'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      about: json['about'] ?? '',
      website: json['website'] ?? '',
      logoText: json['logoText'],
      category: json['category'],
    );
  }

  /// Create from Map for deserialization
  factory CardInfo.fromMap(Map<String, dynamic> map) {
    return CardInfo(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      organization: map['organization'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      about: map['about'] ?? '',
      website: map['website'] ?? '',
      logoText: map['logoText'],
      category: map['category'],
      background: map['background'] != null 
          ? _parseCardBackground(map['background']) 
          : null,
      userId: map['userId'],
      fontColor: map['fontColor'] != null ? _parseColor(map['fontColor']) : null,
    );
  }

  static CardBackground? _parseCardBackground(dynamic value) {
    if (value == null) return null;
    // Handle string representation
    if (value is String) {
      // You can implement string-to-CardBackground parsing here
      return CardBackground.defaultGradient;
    }
    return value as CardBackground?;
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final hexColor = hex.replaceFirst('#', '');
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Create an empty card
  factory CardInfo.empty() {
    return CardInfo(
      id: null,
      name: '',
      organization: '',
      jobTitle: '',
      email: '',
      phone: '',
      location: '',
      about: '',
      website: '',
      userId: null,
    );
  }
}
