import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/card_info.dart';
import '../../../data/repositories/card_repository.dart';
import '../../../data/repositories/sqlite_card_repository.dart';
import 'card_state.dart';

/// Cubit for managing card state and business logic
class CardCubit extends Cubit<CardState> {
  final CardRepository _repository;

  CardCubit({CardRepository? repository})
      : _repository = repository ?? SQLiteCardRepository(),
        super(CardInitial()) {
    loadCards();
  }

  /// Load all cards from repository
  Future<void> loadCards() async {
    emit(CardLoading());
    
    try {
      final cards = await _repository.getAllCards();
      emit(CardLoaded(cards: cards));
    } catch (e) {
      emit(CardError('Failed to load cards: ${e.toString()}'));
    }
  }

  /// Add a new card
  Future<void> addCard(CardInfo card) async {
    try {
      await _repository.addCard(card);
      
      // Reload cards to get updated list
      final cards = await _repository.getAllCards();
      emit(CardLoaded(cards: cards));
      
      // Emit success state temporarily
      emit(CardAdded(card));
      
      // Return to loaded state
      emit(CardLoaded(cards: cards));
    } catch (e) {
      emit(CardError('Failed to add card: ${e.toString()}'));
    }
  }

  /// Update an existing card
  Future<void> updateCard(CardInfo card) async {
    try {
      await _repository.updateCard(card);
      
      // Reload cards to get updated list
      final cards = await _repository.getAllCards();
      emit(CardLoaded(cards: cards));
      
      // Emit success state temporarily
      emit(CardUpdated(card));
      
      // Return to loaded state
      emit(CardLoaded(cards: cards));
    } catch (e) {
      emit(CardError('Failed to update card: ${e.toString()}'));
    }
  }

  /// Delete a card
  Future<void> deleteCard(String id) async {
    try {
      await _repository.deleteCard(id);
      
      // Reload cards to get updated list
      final cards = await _repository.getAllCards();
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
      final cards = await _repository.searchCards(query);
      emit(CardLoaded(cards: cards, searchQuery: query));
    } catch (e) {
      emit(CardError('Failed to search cards: ${e.toString()}'));
    }
  }

  /// Get cards by category
  Future<void> getCardsByCategory(String category) async {
    try {
      final cards = await _repository.getCardsByCategory(category);
      emit(CardLoaded(cards: cards, selectedCategory: category));
    } catch (e) {
      emit(CardError('Failed to get cards by category: ${e.toString()}'));
    }
  }
}
