import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cardly/data/models/card_info.dart';
import 'package:cardly/data/models/user.dart';

void main() {
  group('Integration Tests', () {
    test('CardInfo and User models integration', () {
      // Create a user
      final user = User(
        id: 'user-123',
        email: 'john@example.com',
        fullName: 'John Doe',
        passwordHash: 'hashed_password',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create a card for that user
      final card = CardInfo(
        name: 'John Doe',
        email: user.email,
        phone: '+1234567890',
        organization: 'Test Company',
        jobTitle: 'Developer',
        location: 'New York',
        about: 'Test about',
        website: 'https://test.com',
        userId: user.id,
      );

      // Verify the relationship
      expect(card.email, user.email);
      expect(card.userId, user.id);
      expect(card.name, user.fullName);
    });

    test('CardInfo serialization and deserialization', () {
      final originalCard = CardInfo(
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '+9876543210',
        organization: 'Tech Corp',
        jobTitle: 'Manager',
        location: 'San Francisco',
        about: 'Test about',
        website: 'https://test.com',
        category: 'Work',
      );

      // Serialize to JSON
      final json = originalCard.toJson();

      // Deserialize from JSON
      final deserializedCard = CardInfo.fromJson(json);

      // Verify all fields match
      expect(deserializedCard.name, originalCard.name);
      expect(deserializedCard.email, originalCard.email);
      expect(deserializedCard.phone, originalCard.phone);
      expect(deserializedCard.organization, originalCard.organization);
      expect(deserializedCard.jobTitle, originalCard.jobTitle);
      expect(deserializedCard.location, originalCard.location);
      expect(deserializedCard.category, originalCard.category);
    });

    test('Multiple cards with different categories', () {
      final cards = [
        CardInfo(
          name: 'Work Contact 1',
          email: 'work1@example.com',
          phone: '+1111111111',
          organization: 'Company A',
          jobTitle: 'Developer',
          location: 'NY',
          about: 'Test about',
          website: 'https://test.com',
          category: 'Work',
        ),
        CardInfo(
          name: 'Personal Contact 1',
          email: 'personal1@example.com',
          phone: '+2222222222',
          organization: 'N/A',
          jobTitle: 'Friend',
          location: 'CA',
          about: 'Test about',
          website: 'https://test.com',
          category: 'Personal',
        ),
        CardInfo(
          name: 'Work Contact 2',
          email: 'work2@example.com',
          phone: '+3333333333',
          organization: 'Company B',
          jobTitle: 'Manager',
          location: 'TX',
          about: 'Test about',
          website: 'https://test.com',
          category: 'Work',
        ),
      ];

      // Filter by category
      final workCards = cards.where((card) => card.category == 'Work').toList();
      final personalCards =
          cards.where((card) => card.category == 'Personal').toList();

      expect(workCards.length, 2);
      expect(personalCards.length, 1);
      expect(workCards[0].organization, 'Company A');
      expect(personalCards[0].jobTitle, 'Friend');
    });

    test('Card copyWith preserves original values', () {
      final originalCard = CardInfo(
        name: 'Original Name',
        email: 'original@example.com',
        phone: '+1234567890',
        organization: 'Original Org',
        jobTitle: 'Original Job',
        location: 'Original Location',
        about: 'Test about',
        website: 'https://test.com',
        category: 'Original Category',
      );

      final updatedCard = originalCard.copyWith(
        name: 'Updated Name',
        category: 'Updated Category',
      );

      // Check updated fields
      expect(updatedCard.name, 'Updated Name');
      expect(updatedCard.category, 'Updated Category');

      // Check preserved fields
      expect(updatedCard.email, originalCard.email);
      expect(updatedCard.phone, originalCard.phone);
      expect(updatedCard.organization, originalCard.organization);
      expect(updatedCard.jobTitle, originalCard.jobTitle);
      expect(updatedCard.location, originalCard.location);
    });
  });
}
