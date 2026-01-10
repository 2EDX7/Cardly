import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/card_info.dart';
import '../repositories/sqlite_card_repository.dart';
import '../repositories/api_card_repository.dart';
import 'connectivity_service.dart';

/// Service to synchronize data between local SQLite and remote MongoDB
class SyncService {
  final SQLiteCardRepository _localRepo;
  final ApiCardRepository _apiRepo;
  final ConnectivityService _connectivityService;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncService({
    required SQLiteCardRepository localRepo,
    required ApiCardRepository apiRepo,
    required ConnectivityService connectivityService,
  })  : _localRepo = localRepo,
        _apiRepo = apiRepo,
        _connectivityService = connectivityService {
    // Listen to connectivity changes and auto-sync when online
    _connectivityService.connectionStatus.listen((isConnected) {
      if (isConnected) {
        syncAll();
      }
    });
  }

  /// Sync all cards between local and remote
  Future<void> syncAll({String? userId}) async {
    if (_isSyncing || !_connectivityService.isConnected) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      userId ??= 'local-user'; // Default user for now

      // Step 1: Push local changes to backend
      await _pushLocalChanges(userId);

      // Step 2: Pull backend changes to local
      await _pullBackendChanges(userId);

      _lastSyncTime = DateTime.now();
      _syncStatusController.add(SyncStatus.success);
      debugPrint('✅ Sync completed successfully at $_lastSyncTime');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      debugPrint('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Push local changes that need sync to backend
  Future<void> _pushLocalChanges(String userId) async {
    final localCards = await _localRepo.getAllCards(userId: userId);
    final cardsNeedingSync =
        localCards.where((card) => card.needsSync).toList();

    debugPrint(
        '📤 Pushing ${cardsNeedingSync.length} local changes to backend');

    for (final card in cardsNeedingSync) {
      try {
        if (card.backendId == null || card.backendId!.isEmpty) {
          // New card - add to backend
          await _apiRepo.addCard(card, userId: userId);
          // Backend should return the created card with backendId, but we'll fetch it
          final backendCards = await _apiRepo.getAllCards(userId: userId);
          final matchingCard = backendCards.firstWhere(
            (c) => c.email == card.email,
            orElse: () => card,
          );

          if (matchingCard.backendId != null) {
            card.backendId = matchingCard.backendId;
            card.needsSync = false;
            card.lastSyncedAt = DateTime.now();
            await _localRepo.updateCard(card, userId: userId);
          }
        } else {
          // Existing card - update on backend
          await _apiRepo.updateCard(card, userId: userId);
          card.needsSync = false;
          card.lastSyncedAt = DateTime.now();
          await _localRepo.updateCard(card, userId: userId);
        }
      } catch (e) {
        debugPrint('❌ Failed to push card ${card.name}: $e');
        // Continue with other cards
      }
    }
  }

  /// Pull changes from backend to local
  Future<void> _pullBackendChanges(String userId) async {
    debugPrint('📥 Pulling changes from backend');

    try {
      final backendCards = await _apiRepo.getAllCards(userId: userId);
      final localCards = await _localRepo.getAllCards(userId: userId);

      // Create map of local cards by backendId for quick lookup
      final localCardMap = <String, CardInfo>{};
      for (final card in localCards) {
        if (card.backendId != null && card.backendId!.isNotEmpty) {
          localCardMap[card.backendId!] = card;
        }
      }

      // Process backend cards
      for (final backendCard in backendCards) {
        if (backendCard.backendId == null) continue;

        final localCard = localCardMap[backendCard.backendId!];

        if (localCard == null) {
          // New card from backend - add to local
          backendCard.needsSync = false;
          backendCard.lastSyncedAt = DateTime.now();
          await _localRepo.addCard(backendCard, userId: userId);
          debugPrint('➕ Added new card from backend: ${backendCard.name}');
        } else {
          // Card exists locally - check if backend is newer
          final backendUpdatedAt = backendCard.updatedAt ?? DateTime(2000);
          final localUpdatedAt = localCard.lastSyncedAt ?? DateTime(2000);

          if (backendUpdatedAt.isAfter(localUpdatedAt) &&
              !localCard.needsSync) {
            // Backend version is newer and local has no pending changes
            backendCard.id = localCard.id; // Preserve local ID
            backendCard.needsSync = false;
            backendCard.lastSyncedAt = DateTime.now();
            await _localRepo.updateCard(backendCard, userId: userId);
            debugPrint(
                '🔄 Updated local card from backend: ${backendCard.name}');
          }
        }
      }

      // Check for cards deleted on backend
      for (final localCard in localCards) {
        if (localCard.backendId == null || localCard.backendId!.isEmpty)
          continue;

        final existsOnBackend =
            backendCards.any((c) => c.backendId == localCard.backendId);
        if (!existsOnBackend && !localCard.needsSync) {
          // Card deleted on backend and no local changes - delete locally
          if (localCard.id != null) {
            await _localRepo.deleteCard(localCard.id!, userId: userId);
            debugPrint(
                '🗑️ Deleted card removed from backend: ${localCard.name}');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to pull backend changes: $e');
      rethrow;
    }
  }

  /// Save card with offline support
  Future<CardInfo> saveCardOffline(CardInfo card, String userId) async {
    // Mark card as needing sync
    card.needsSync = true;
    card.lastSyncedAt = DateTime.now();

    // Save to local database
    if (card.id == null) {
      await _localRepo.addCard(card, userId: userId);
    } else {
      await _localRepo.updateCard(card, userId: userId);
    }

    // Try to sync immediately if online
    if (_connectivityService.isConnected) {
      syncAll(userId: userId);
    }

    return card;
  }

  /// Delete card with offline support
  Future<void> deleteCardOffline(CardInfo card, String userId) async {
    // Delete locally
    if (card.id != null) {
      await _localRepo.deleteCard(card.id!, userId: userId);
    }

    // Try to delete on backend if online
    if (_connectivityService.isConnected && card.backendId != null) {
      try {
        await _apiRepo.deleteCardByBackendId(card.backendId!);
      } catch (e) {
        debugPrint('❌ Failed to delete card from backend: $e');
      }
    }
  }

  void dispose() {
    _syncStatusController.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}
