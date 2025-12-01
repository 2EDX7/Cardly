import '../../../presentation/widgets/business_card/card_background.dart';

/// Model class representing a business card with all its information
class CardInfo {
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

  CardInfo({
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
  });

  /// Create a copy of this card with some fields updated
  CardInfo copyWith({
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
  }) {
    return CardInfo(
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
    );
  }

  /// Convert to Map for storage/serialization
  Map<String, dynamic> toMap() {
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
      'background': background?.toString(),
    };
  }

  /// Create from Map for deserialization
  factory CardInfo.fromMap(Map<String, dynamic> map) {
    return CardInfo(
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

  /// Create an empty card
  factory CardInfo.empty() {
    return CardInfo(
      name: '',
      organization: '',
      jobTitle: '',
      email: '',
      phone: '',
      location: '',
      about: '',
      website: '',
    );
  }
}
