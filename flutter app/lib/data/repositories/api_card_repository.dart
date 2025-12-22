library;

import '../models/card_info.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../helpers/card_info_api_helper.dart';
import 'card_repository.dart';

/// API implementation of CardRepository for collected cards
/// Matches backend CardRepository pattern
class ApiCardRepository implements CardRepository {
  final ApiClient apiClient;

  ApiCardRepository({required this.apiClient});

  @override
  Future<List<CardInfo>> getAllCards({required String userId}) async {
    // userId not needed for API - backend uses JWT token
    final response = await apiClient.get(Endpoints.cards);
    final cards = (response['data']['cards'] as List)
        .map((json) => CardInfoApiHelper.fromJson(json))
        .toList();
    return cards;
  }

  @override
  Future<CardInfo?> getCardById(int id, {required String userId}) async {
    // For API, we don't use local int ID - this method is for SQLite compatibility
    throw UnimplementedError(
      'getCardById with int ID is not supported in API. Use getCardByBackendId instead.',
    );
  }

  /// Get card by backend ID (MongoDB _id)
  Future<CardInfo?> getCardByBackendId(String cardId) async {
    try {
      final response = await apiClient.get(Endpoints.card(cardId));
      return CardInfoApiHelper.fromJson(response['data']['card']);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CardInfo?> getCardByIdGlobal(int id) async {
    // Not applicable for API
    throw UnimplementedError(
      'getCardByIdGlobal is not supported in API implementation',
    );
  }

  @override
  Future<void> addCard(CardInfo card, {required String userId}) async {
    await apiClient.post(
      Endpoints.cards,
      body: CardInfoApiHelper.toJsonForApi(card),
    );
  }

  /// Collect card by shareable ID (QR code or manual entry)
  Future<CardInfo> collectCardByShareableId(String shareableId) async {
    final response = await apiClient.post(
      Endpoints.collectCard(shareableId),
    );
    return CardInfoApiHelper.fromJson(response['data']['card']);
  }

  @override
  Future<void> updateCard(CardInfo card, {required String userId}) async {
    if (card.backendId == null) {
      throw Exception('Cannot update card without backend ID');
    }

    await apiClient.put(
      Endpoints.card(card.backendId!),
      body: CardInfoApiHelper.toJsonForApi(card),
    );
  }

  @override
  Future<void> deleteCard(int id, {required String userId}) async {
    // For API, we need backend ID, not local ID
    throw UnimplementedError(
      'deleteCard with int ID is not supported. Use deleteCardByBackendId instead.',
    );
  }

  ///Delete card by backend ID
  Future<void> deleteCardByBackendId(String cardId) async {
    await apiClient.delete(Endpoints.card(cardId));
  }

  @override
  Future<List<CardInfo>> searchCards(String query, {required String userId}) async {
    final response = await apiClient.get(
      Endpoints.cards,
      queryParameters: {'search': query},
    );
    
    final cards = (response['data']['cards'] as List)
        .map((json) => CardInfoApiHelper.fromJson(json))
        .toList();
    return cards;
  }

  @override
  Future<List<CardInfo>> getCardsByCategory(
    String category, {
    required String userId,
  }) async {
    final response = await apiClient.get(
      Endpoints.cards,
      queryParameters: {'category': category},
    );
    
    final cards = (response['data']['cards'] as List)
        .map((json) => CardInfoApiHelper.fromJson(json))
        .toList();
    return cards;
  }

  /// Get card statistics
  Future<Map<String, dynamic>> getCardStats() async {
    final response = await apiClient.get(Endpoints.cardStats);
    return response['data'] as Map<String, dynamic>;
  }
}
