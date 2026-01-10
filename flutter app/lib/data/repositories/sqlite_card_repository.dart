import '../models/card_info.dart';
import '../database/database_helper.dart';
import 'card_repository.dart';

/// SQLite implementation of CardRepository
class SQLiteCardRepository implements CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<CardInfo>> getAllCards({required String userId}) async {
    return await _dbHelper.getAllCards(userId: userId);
  }

  @override
  Future<CardInfo?> getCardById(int id, {required String userId}) async {
    return await _dbHelper.getCardById(id, userId: userId);
  }

  @override
  Future<CardInfo?> getCardByIdGlobal(int id) async {
    return await _dbHelper.getCardByIdGlobal(id);
  }

  @override
  Future<void> addCard(CardInfo card, {required String userId}) async {
    await _dbHelper.insertCard(card, userId: userId);
  }

  @override
  Future<void> updateCard(CardInfo card, {required String userId}) async {
    await _dbHelper.updateCard(card, userId: userId);
  }

  @override
  Future<void> deleteCard(int id, {required String userId}) async {
    await _dbHelper.deleteCard(id, userId: userId);
  }

  @override
  Future<List<CardInfo>> searchCards(String query,
      {required String userId}) async {
    return await _dbHelper.searchCards(query, userId: userId);
  }

  @override
  Future<List<CardInfo>> getCardsByCategory(String category,
      {required String userId}) async {
    return await _dbHelper.getCardsByCategory(category, userId: userId);
  }

  /// Get cards that need to be synced with backend
  Future<List<CardInfo>> getCardsNeedingSync({required String userId}) async {
    final allCards = await getAllCards(userId: userId);
    return allCards.where((card) => card.needsSync).toList();
  }
}
