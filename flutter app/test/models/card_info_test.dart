import 'package:flutter_test/flutter_test.dart';
import 'package:cardly/data/models/card_info.dart';

void main() {
  group('CardInfo Model Tests', () {
    test('CardInfo creation with required fields', () {
      final card = CardInfo(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        organization: 'Test Company',
        jobTitle: 'Developer',
        location: 'New York',
        about: 'Test about',
        website: 'https://test.com',
      );

      expect(card.name, 'John Doe');
      expect(card.email, 'john@example.com');
      expect(card.phone, '+1234567890');
      expect(card.organization, 'Test Company');
    });

    test('CardInfo copyWith updates fields correctly', () {
      final card = CardInfo(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        organization: 'Test Company',
        jobTitle: 'Developer',
        location: 'New York',
        about: 'Test about',
        website: 'https://test.com',
      );

      final updatedCard = card.copyWith(
        name: 'Jane Doe',
        organization: 'New Company',
      );

      expect(updatedCard.name, 'Jane Doe');
      expect(updatedCard.organization, 'New Company');
      expect(updatedCard.email, 'john@example.com'); // unchanged
      expect(updatedCard.phone, '+1234567890'); // unchanged
    });

    test('CardInfo toJson and fromJson work correctly', () {
      final card = CardInfo(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        organization: 'Test Company',
        jobTitle: 'Developer',
        location: 'New York',
        about: 'Test about',
        website: 'https://test.com',
      );

      final json = card.toJson();
      final reconstructedCard = CardInfo.fromJson(json);

      expect(reconstructedCard.name, card.name);
      expect(reconstructedCard.email, card.email);
      expect(reconstructedCard.phone, card.phone);
      expect(reconstructedCard.organization, card.organization);
    });

    test('CardInfo with empty strings', () {
      final card = CardInfo(
        name: '',
        email: '',
        phone: '',
        organization: '',
        jobTitle: '',
        location: '',
        about: '',
        website: '',
      );

      expect(card.name, '');
      expect(card.email, '');
      expect(card.phone, '');
    });
  });
}
