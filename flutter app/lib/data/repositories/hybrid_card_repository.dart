import '../models/card_info.dart';
import '../repositories/card_repository.dart';
import '../repositories/sqlite_card_repository.dart';
import '../repositories/api_card_repository.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import 'package:flutter/foundation.dart';

/// Hybrid repository that uses local SQLite when offline and syncs with API when online
class HybridCardRepository implements CardRepository {
  final SQLiteCardRepository _localRepo;
  final ApiCardRepository _apiRepo;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  HybridCardRepository({
    required SQLiteCardRepository localRepo,
    required ApiCardRepository apiRepo,
    required ConnectivityService connectivityService,
    required SyncService syncService,
  })  : _localRepo = localRepo,
        _apiRepo = apiRepo,
        _connectivityService = connectivityService,
        _syncService = syncService;

  @override
  Future<List<CardInfo>> getAllCards({required String userId}) async {
    // If online, fetch from API and save to local
    if (_connectivityService.isConnected) {
      try {
        final apiCards = await _apiRepo.getAllCards(userId: userId);

        // Save all API cards to local database
        for (final card in apiCards) {
          final existingCard =
              await _localRepo.getCardById(card.id ?? 0, userId: userId);
          if (existingCard == null) {
            await _localRepo.addCard(card, userId: userId);
          } else {
            await _localRepo.updateCard(card, userId: userId);
          }
        }

        debugPrint('✅ Saved ${apiCards.length} cards to local database');

        // Trigger background sync for any pending local changes
        if (!_syncService.isSyncing) {
          _syncService.syncAll(userId: userId).catchError((e) {
            debugPrint('Background sync failed: $e');
          });
        }

        return apiCards;
      } catch (e) {
        debugPrint('⚠️ Failed to fetch from API, using local data: $e');
      }
    }

    // Fallback to local data (offline or API failed)
    return await _localRepo.getAllCards(userId: userId);
  }

  @override
  Future<CardInfo?> getCardById(int id, {required String userId}) async {
    return await _localRepo.getCardById(id, userId: userId);
  }

  @override
  Future<CardInfo?> getCardByIdGlobal(int id) async {
    return await _localRepo.getCardByIdGlobal(id);
  }

  @override
  Future<void> addCard(CardInfo card, {required String userId}) async {
    // Add to local immediately
    await _localRepo.addCard(card, userId: userId);

    // Mark as needing sync
    card.needsSync = true;
    await _localRepo.updateCard(card, userId: userId);

    // Try to sync with backend if online
    if (_connectivityService.isConnected) {
      try {
        await _apiRepo.addCard(card, userId: userId);

        // Fetch the created card to get backendId
        final backendCards = await _apiRepo.getAllCards(userId: userId);
        final createdCard = backendCards.firstWhere(
          (c) => c.email == card.email,
          orElse: () => card,
        );

        if (createdCard.backendId != null) {
          card.backendId = createdCard.backendId;
          card.needsSync = false;
          card.lastSyncedAt = DateTime.now();
          await _localRepo.updateCard(card, userId: userId);
        }
      } catch (e) {
        debugPrint(
            '⚠️ Failed to sync new card to backend, will retry later: $e');
      }
    }
  }

  @override
  Future<void> updateCard(CardInfo card, {required String userId}) async {
    // Mark as needing sync and update locally immediately
    card.needsSync = true;
    card.lastSyncedAt = DateTime.now();
    await _localRepo.updateCard(card, userId: userId);

    // Try to sync with backend if online
    if (_connectivityService.isConnected && card.backendId != null) {
      try {
        await _apiRepo.updateCard(card, userId: userId);
        card.needsSync = false;
        card.lastSyncedAt = DateTime.now();
        await _localRepo.updateCard(card, userId: userId);
        debugPrint('✅ Card update synced to backend');
      } catch (e) {
        debugPrint(
            '⚠️ Failed to sync card update to backend, will retry later: $e');
      }
    } else {
      debugPrint(
          '📴 Offline: Card update saved locally, will sync when online');
    }
  }

  @override
  Future<void> deleteCard(int id, {required String userId}) async {
    // Get card info before deleting
    final card = await _localRepo.getCardById(id, userId: userId);

    // Delete locally immediately
    await _localRepo.deleteCard(id, userId: userId);

    // Try to delete on backend if online
    if (_connectivityService.isConnected && card?.backendId != null) {
      try {
        await _apiRepo.deleteCardByBackendId(card!.backendId!);
      } catch (e) {
        debugPrint('⚠️ Failed to delete card from backend: $e');
      }
    }
  }

  @override
  Future<List<CardInfo>> searchCards(String query,
      {required String userId}) async {
    return await _localRepo.searchCards(query, userId: userId);
  }

  @override
  Future<List<CardInfo>> getCardsByCategory(String category,
      {required String userId}) async {
    return await _localRepo.getCardsByCategory(category, userId: userId);
  }

  /// Delete card by backend ID (for API compatibility)
  Future<void> deleteCardByBackendId(String backendId,
      {required String userId}) async {
    // Find local card with this backendId
    final allCards = await _localRepo.getAllCards(userId: userId);
    final card = allCards.firstWhere(
      (c) => c.backendId == backendId,
      orElse: () => throw Exception('Card not found'),
    );

    if (card.id != null) {
      await deleteCard(card.id!, userId: userId);
    }
  }

  /// Collect card by shareable ID (for QR code scanning)
  Future<CardInfo> collectCardByShareableId(String shareableId,
      {required String userId}) async {
    if (!_connectivityService.isConnected) {
      throw Exception('Cannot collect cards while offline');
    }

    // Collect from backend
    final card = await _apiRepo.collectCardByShareableId(shareableId);

    // Save to local
    card.needsSync = false;
    card.lastSyncedAt = DateTime.now();
    await _localRepo.addCard(card, userId: userId);

    return card;
  }

  /// Force a full sync
  Future<void> forceSync({required String userId}) async {
    await _syncService.syncAll(userId: userId);
  }
}
