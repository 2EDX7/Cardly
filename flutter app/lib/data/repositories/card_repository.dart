import '../models/card_info.dart';

/// Repository interface for managing business card data
/// Implementations can use different storage solutions (SQLite, Hive, API, etc.)
abstract class CardRepository {
  /// Get all cards
  Future<List<CardInfo>> getAllCards();
  
  /// Get a single card by ID
  Future<CardInfo?> getCardById(String id);
  
  /// Add a new card
  Future<void> addCard(CardInfo card);
  
  /// Update an existing card
  Future<void> updateCard(CardInfo card);
  
  /// Delete a card
  Future<void> deleteCard(String id);
  
  /// Search cards by query
  Future<List<CardInfo>> searchCards(String query);
  
  /// Get cards by category
  Future<List<CardInfo>> getCardsByCategory(String category);
}
