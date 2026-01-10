import '../models/card_info.dart';
import 'profile_card_repository.dart';
import 'sqlite_profile_card_repository.dart';
import 'api_profile_card_repository.dart';
import '../services/connectivity_service.dart';
import 'package:flutter/foundation.dart';

/// Hybrid repository for profile card that works offline and syncs when online
class HybridProfileCardRepository implements ProfileCardRepository {
  final SQLiteProfileCardRepository _localRepo;
  final ApiProfileCardRepository _apiRepo;
  final ConnectivityService _connectivityService;

  HybridProfileCardRepository({
    required SQLiteProfileCardRepository localRepo,
    required ApiProfileCardRepository apiRepo,
    required ConnectivityService connectivityService,
  })  : _localRepo = localRepo,
        _apiRepo = apiRepo,
        _connectivityService = connectivityService;

  @override
  Future<CardInfo?> getProfileCard({required String userId}) async {
    // Always read from local first for fast access
    final localCard = await _localRepo.getProfileCard(userId: userId);

    // Try to sync with API in background if online
    if (_connectivityService.isConnected) {
      try {
        final apiCard = await _apiRepo.getProfileCard(userId: userId);
        if (apiCard != null) {
          // Save to local for offline access
          await _localRepo.saveProfileCard(apiCard, userId: userId);
          return apiCard;
        }
      } catch (e) {
        debugPrint('⚠️ Failed to fetch profile card from API, using local: $e');
      }
    }

    // Return local data
    return localCard;
  }

  @override
  Future<void> saveProfileCard(CardInfo card, {required String userId}) async {
    // Save locally immediately
    await _localRepo.saveProfileCard(card, userId: userId);
    debugPrint('✅ Profile card saved to local database');

    // Try to sync with backend if online
    if (_connectivityService.isConnected) {
      try {
        await _apiRepo.saveProfileCard(card, userId: userId);
        debugPrint('✅ Profile card synced to backend');

        // Fetch updated card from API to get shareable ID
        final updatedCard = await _apiRepo.getProfileCard(userId: userId);
        if (updatedCard != null) {
          await _localRepo.saveProfileCard(updatedCard, userId: userId);
          debugPrint('✅ Profile card updated with backend data');
        }
      } catch (e) {
        debugPrint(
            '⚠️ Failed to sync profile card to backend, will retry later: $e');
      }
    } else {
      debugPrint(
          '📴 Offline: Profile card saved locally, will sync when online');
    }
  }

  /// Get card by shareable ID - always from API
  Future<CardInfo> getCardByShareableId(String shareableId) async {
    return await _apiRepo.getCardByShareableId(shareableId);
  }
}
