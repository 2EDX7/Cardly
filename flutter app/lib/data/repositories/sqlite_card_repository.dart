import '../models/card_info.dart';
import '../database/database_helper.dart';
import 'card_repository.dart';

/// SQLite implementation of CardRepository
class SQLiteCardRepository implements CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<CardInfo>> getAllCards() async {
    return await _dbHelper.getAllCards();
  }

  @override
  Future<CardInfo?> getCardById(String id) async {
    return await _dbHelper.getCardByEmail(id);
  }

  @override
  Future<void> addCard(CardInfo card) async {
    await _dbHelper.insertCard(card);
  }

  @override
  Future<void> updateCard(CardInfo card) async {
    await _dbHelper.updateCard(card);
  }

  @override
  Future<void> deleteCard(String id) async {
    await _dbHelper.deleteCard(id);
  }

  @override
  Future<List<CardInfo>> searchCards(String query) async {
    return await _dbHelper.searchCards(query);
  }

  @override
  Future<List<CardInfo>> getCardsByCategory(String category) async {
    return await _dbHelper.getCardsByCategory(category);
  }
}
