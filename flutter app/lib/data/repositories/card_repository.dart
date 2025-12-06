import '../models/card_info.dart';

/// Repository interface for managing business card data
/// Implementations can use different storage solutions (SQLite, Hive, API, etc.)
abstract class CardRepository {
  /// Get all cards
  Future<List<CardInfo>> getAllCards({required String userId});
  
  /// Get a single card by ID
  Future<CardInfo?> getCardById(int id, {required String userId});
  
  /// Get a single card by ID globally (across all users) for sharing
  Future<CardInfo?> getCardByIdGlobal(int id);
  
  /// Add a new card
  Future<void> addCard(CardInfo card, {required String userId});
  
  /// Update an existing card
  Future<void> updateCard(CardInfo card, {required String userId});
  
  /// Delete a card
  Future<void> deleteCard(int id, {required String userId});
  
  /// Search cards by query
  Future<List<CardInfo>> searchCards(String query, {required String userId});
  
  /// Get cards by category
  Future<List<CardInfo>> getCardsByCategory(String category, {required String userId});
}
