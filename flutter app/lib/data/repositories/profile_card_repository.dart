import '../models/card_info.dart';

/// Repository interface for managing a user's profile card (single card per user).
abstract class ProfileCardRepository {
  Future<CardInfo?> getProfileCard({required String userId});
  Future<void> saveProfileCard(CardInfo card, {required String userId});
}
