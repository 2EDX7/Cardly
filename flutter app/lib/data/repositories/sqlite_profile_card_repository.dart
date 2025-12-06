import '../database/database_helper.dart';
import '../models/card_info.dart';
import 'profile_card_repository.dart';

/// SQLite implementation that stores the single profile card in the user_cards table.
class SQLiteProfileCardRepository implements ProfileCardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<CardInfo?> getProfileCard({required String userId}) {
    return _dbHelper.getUserCard(userId: userId);
  }

  @override
  Future<void> saveProfileCard(CardInfo card, {required String userId}) async {
    final cardWithUser = card.copyWith(userId: userId);
    await _dbHelper.upsertUserCard(cardWithUser, userId: userId);
  }
}
