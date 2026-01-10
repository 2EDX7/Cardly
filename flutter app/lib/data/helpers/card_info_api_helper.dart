library;

import '../models/card_info.dart';
import '../../presentation/widgets/business_card/card_background.dart';
import 'package:flutter/material.dart';

/// Helper methods for CardInfo serialization to/from backend API
class CardInfoApiHelper {
  /// Create CardInfo from JSON (backend API response)
  static CardInfo fromJson(Map<String, dynamic> json) {
    return CardInfo(
      backendId: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      about: json['about'] as String? ?? '',
      website: json['website'] as String? ?? '',
      logoText: json['logoText'] as String?,
      category: json['category'] as String?,
      userId: json['ownerId'] as String?, // Backend uses ownerId
      // Backend-specific fields
      shareableId: json['shareableId'] as String?,
      isProfileCard: json['isProfileCard'] as bool?,
      isPublic: json['isPublic'] as bool?,
      collectedAt: json['collectedAt'] != null
          ? DateTime.parse(json['collectedAt'] as String)
          : null,
      customCategory: json['customCategory'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      notes: json['notes'] as String?,
      sourceCardId: json['sourceCardId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      // Parse background from string
      background: json['background'] != null
          ? _parseCardBackground(json['background'])
          : null,
      fontColor: json['fontColor'] != null
          ? _parseColor(json['fontColor'] as String?)
          : null,
    );
  }

  /// Convert CardInfo to JSON for API requests
  static Map<String, dynamic> toJsonForApi(CardInfo card) {
    return {
      if (card.backendId != null) '_id': card.backendId,
      'name': card.name,
      'organization': card.organization,
      'jobTitle': card.jobTitle,
      'email': card.email,
      'phone': card.phone,
      'location': card.location,
      'about': card.about,
      'website': card.website,
      if (card.logoText != null) 'logoText': card.logoText,
      if (card.category != null) 'category': card.category,
      if (card.background != null)
        'background': card.background!.getBackgroundName(),
      if (card.fontColor != null)
        'fontColor':
            '#${(card.fontColor!.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      // Backend-specific fields for updates
      if (card.customCategory != null) 'customCategory': card.customCategory,
      if (card.tags != null) 'tags': card.tags,
      if (card.notes != null) 'notes': card.notes,
      if (card.isPublic != null) 'isPublic': card.isPublic,
    };
  }

  static CardBackground? _parseCardBackground(dynamic value) {
    if (value == null) return null;
    // Handle string representation - you may need to implement proper parsing
    if (value is String) {
      // Default to a gradient for now
      if (value == 'gold') return CardBackground.gold;
      if (value == 'green') return CardBackground.green;
      if (value == 'grey') return CardBackground.grey;
      if (value == 'purple') return CardBackground.purple;
      if (value == 'blue') return CardBackground.blue;
      if (value == 'goldSilver') return CardBackground.goldSilver;

      // Gradient matching
      if (value == 'defaultGradient') return CardBackground.defaultGradient;
      if (value == 'purpleBlue') return CardBackground.purpleBlue;
      if (value == 'orangePink') return CardBackground.orangePink;
      if (value == 'greenBlue') return CardBackground.greenBlue;
      if (value == 'sunset') return CardBackground.sunset;

      // Color matching
      if (value == 'primarySolid') return CardBackground.primarySolid;
      if (value == 'secondarySolid') return CardBackground.secondarySolid;
      if (value == 'darkSolid') return CardBackground.darkSolid;
      if (value == 'blueSolid') return CardBackground.blueSolid;
      if (value == 'blackSolid') return CardBackground.blackSolid;

      return CardBackground.defaultGradient;
    }
    return value as CardBackground?;
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final hexColor = hex.replaceFirst('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return null;
    }
  }
}
