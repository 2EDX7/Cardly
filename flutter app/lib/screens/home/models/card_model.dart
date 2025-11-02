import '../../../widgets/business_card/card_background.dart';

class CardModel {
  final String name;
  final String organization;
  final String jobTitle;
  final CardBackground background;
  final String category;

  CardModel({
    required this.name,
    required this.organization,
    required this.jobTitle,
    required this.background,
    required this.category,
  });

  // Convert to Map for compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'organization': organization,
      'jobTitle': jobTitle,
      'background': background,
      'category': category,
    };
  }

  // Create from Map
  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      name: map['name'],
      organization: map['organization'],
      jobTitle: map['jobTitle'],
      background: map['background'],
      category: map['category'],
    );
  }
}
