import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/card_info.dart';
import '../../../data/repositories/card_repository.dart';
import '../../../data/repositories/sqlite_card_repository.dart';
import '../../../data/database/database_helper.dart';
import 'card_state.dart';

/// Cubit for managing card state and business logic
class CardCubit extends Cubit<CardState> {
  final CardRepository _repository;
  String _userId;

  CardCubit({CardRepository? repository, String? initialUserId})
      : _repository = repository ?? SQLiteCardRepository(),
        _userId = initialUserId ?? DatabaseHelper.defaultUserId,
        super(CardInitial()) {
    loadCards();
  }

  /// Set current user context and reload cards
  void setUser(String? userId) {
    _userId = userId ?? DatabaseHelper.defaultUserId;
    loadCards();
  }

  /// Set current user context and reload cards asynchronously
  Future<void> setUserAsync(String? userId) async {
    _userId = userId ?? DatabaseHelper.defaultUserId;
    await loadCards();
  }

  /// Reset cubit to initial state
  void reset() {
    _userId = DatabaseHelper.defaultUserId;
    emit(CardInitial());
  }

  /// Load all cards from repository
  Future<void> loadCards() async {
    emit(CardLoading());
    
    try {
      final cards = await _repository.getAllCards(userId: _userId);
      emit(CardLoaded(cards: cards));
    } catch (e) {
      emit(CardError('Failed to load cards: ${e.toString()}'));
    }
  }

  /// Add a new card
  Future<void> addCard(CardInfo card) async {
    try {
      final cardWithUser = card.copyWith(userId: _userId);
      await _repository.addCard(cardWithUser, userId: _userId);
      
      // Reload cards to get updated list
      final cards = await _repository.getAllCards(userId: _userId);
      emit(CardLoaded(cards: cards));
      
      // Emit success state temporarily
      emit(CardAdded(cardWithUser));
      
      // Return to loaded state
      emit(CardLoaded(cards: cards));
    } catch (e) {
      emit(CardError('Failed to add card: ${e.toString()}'));
    }
  }

  /// Update an existing card
  Future<void> updateCard(CardInfo card) async {
    try {
      final cardWithUser = card.copyWith(userId: _userId);
      await _repository.updateCard(cardWithUser, userId: _userId);
      
      // Reload cards to get updated list
      final cards = await _repository.getAllCards(userId: _userId);
      emit(CardLoaded(cards: cards));
      
      // Emit success state temporarily
      emit(CardUpdated(cardWithUser));
      
      // Return to loaded state
      emit(CardLoaded(cards: cards));
    } catch (e) {
      emit(CardError('Failed to update card: ${e.toString()}'));
    }
  }

  /// Delete a card
  Future<void> deleteCard(int id) async {
    try {
      await _repository.deleteCard(id, userId: _userId);
      
      // Reload cards to get updated list
      final cards = await _repository.getAllCards(userId: _userId);
      emit(CardLoaded(cards: cards));
      
      // Emit success state temporarily
      emit(CardDeleted(id));
      
      // Return to loaded state
      emit(CardLoaded(cards: cards));
    } catch (e) {
      emit(CardError('Failed to delete card: ${e.toString()}'));
    }
  }

  /// Set search query filter
  void setSearchQuery(String query) {
    final currentState = state;
    if (currentState is CardLoaded) {
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  /// Set category filter
  void setCategory(String? category) {
    final currentState = state;
    if (currentState is CardLoaded) {
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  /// Clear all filters
  void clearFilters() {
    final currentState = state;
    if (currentState is CardLoaded) {
      emit(currentState.copyWith(
        searchQuery: '',
        clearCategory: true,
      ));
    }
  }

  /// Search cards by query
  Future<void> searchCards(String query) async {
    try {
      final cards = await _repository.searchCards(query, userId: _userId);
      emit(CardLoaded(cards: cards, searchQuery: query));
    } catch (e) {
      emit(CardError('Failed to search cards: ${e.toString()}'));
    }
  }

  /// Get cards by category
  Future<void> getCardsByCategory(String category) async {
    try {
      final cards = await _repository.getCardsByCategory(category, userId: _userId);
      emit(CardLoaded(cards: cards, selectedCategory: category));
    } catch (e) {
      emit(CardError('Failed to get cards by category: ${e.toString()}'));
    }
  }
}
