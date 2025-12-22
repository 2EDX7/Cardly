library;

import '../models/card_info.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../helpers/card_info_api_helper.dart';
import 'profile_card_repository.dart';

/// API implementation for profile card management
/// Matches backend ProfileCard operations
class ApiProfileCardRepository implements ProfileCardRepository {
  final ApiClient apiClient;

  ApiProfileCardRepository({required this.apiClient});

  @override
  Future<CardInfo?> getProfileCard({required String userId}) async {
    // userId not needed - backend uses JWT
    try {
      final response = await apiClient.get(Endpoints.profileCard);
      return CardInfoApiHelper.fromJson(response['data']['profileCard']);
    } catch (e) {
      // Profile card doesn't exist yet
      return null;
    }
  }

  @override
  Future<void> saveProfileCard(CardInfo card, {required String userId}) async {
    // Create or update profile card
    await apiClient.put(
      Endpoints.profileCard,
      body: CardInfoApiHelper.toJsonForApi(card),
    );
  }

  /// Get public profile card by shareable ID (for QR scanning)
  Future<CardInfo> getCardByShareableId(String shareableId) async {
    final response = await apiClient.get(
      Endpoints.shareCard(shareableId),
    );
    return CardInfoApiHelper.fromJson(response['data']['profileCard']);
  }
}
