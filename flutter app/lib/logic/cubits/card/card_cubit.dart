import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/card_info.dart';
import '../../../data/repositories/card_repository.dart';
import '../../../data/api/api_exception.dart';
import 'card_state.dart';

/// Cubit for managing card state and business logic
class CardCubit extends Cubit<CardState> {
  final CardRepository _repository;
  String _userId;

  CardCubit({required CardRepository repository, String? initialUserId})
      : _repository = repository,
        _userId = initialUserId ?? '',
        super(CardInitial()) {
    if (_userId.isNotEmpty) {
      loadCards();
    }
  }

  /// Set current user context and reload cards
  void setUser(String? userId) {
    _userId = userId ?? '';
    if (_userId.isNotEmpty) {
      loadCards();
    }
  }

  /// Set current user context and reload cards asynchronously
  Future<void> setUserAsync(String? userId) async {
    _userId = userId ?? '';
    if (_userId.isNotEmpty) {
      await loadCards();
    }
  }

  /// Reset cubit to initial state
  void reset() {
    _userId = '';
    emit(CardInitial());
  }

  /// Load all cards from repository
  Future<void> loadCards() async {
    emit(CardLoading());

    try {
      final cards = await _repository.getAllCards(userId: _userId);
      emit(CardLoaded(cards: cards));
    } on NetworkException catch (e) {
      emit(CardError(e.message));
    } on ServerException catch (e) {
      emit(CardError(e.message));
    } on UnauthorizedException catch (e) {
      emit(CardError(e.message));
    } catch (e) {
      emit(CardError('Failed to load cards: ${e.toString()}'));
    }
  }

  /// Fetch card by ID globally (for sharing via ID)
  Future<CardInfo?> getCardByIdGlobal(int id) async {
    try {
      return await _repository.getCardByIdGlobal(id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new card
  Future<bool> addCard(CardInfo card) async {
    emit(CardLoading());

    try {
      await _repository.addCard(card, userId: _userId);
      emit(CardAdded(card));
      await loadCards();
      return true;
    } on ValidationException catch (e) {
      emit(CardError(e.message));
      await loadCards();
      return false;
    } on NetworkException catch (e) {
      emit(CardError(e.message));
      await loadCards();
      return false;
    } catch (e) {
      emit(CardError('Failed to add card: ${e.toString()}'));
      await loadCards();
      return false;
    }
  }

  /// Update an existing card
  Future<void> updateCard(CardInfo card) async {
    emit(CardLoading());

    try {
      await _repository.updateCard(card, userId: _userId);
      await loadCards();
    } on ValidationException catch (e) {
      emit(CardError(e.message));
      await loadCards();
    } on NetworkException catch (e) {
      emit(CardError(e.message));
      await loadCards();
    } catch (e) {
      emit(CardError('Failed to update card: ${e.toString()}'));
      await loadCards();
    }
  }

  /// Remove card from UI state only (for optimistic deletion)
  void removeCardFromState(String cardKey) {
    if (state is CardLoaded) {
      final currentCards = List<CardInfo>.from((state as CardLoaded).cards);
      currentCards.removeWhere(
          (c) => (c.backendId ?? c.id?.toString() ?? c.email) == cardKey);
      emit(CardLoaded(cards: currentCards));
    }
  }

  /// Re-add card to UI state (for undo)
  void addCardToState(CardInfo card) {
    if (state is CardLoaded) {
      final currentCards = List<CardInfo>.from((state as CardLoaded).cards);
      currentCards.add(card);
      emit(CardLoaded(cards: currentCards));
    }
  }

  /// Delete a card
  Future<void> deleteCard(int id) async {
    emit(CardLoading());

    try {
      await _repository.deleteCard(id, userId: _userId);
      await loadCards();
    } on NetworkException catch (e) {
      emit(CardError(e.message));
      await loadCards();
    } catch (e) {
      emit(CardError('Failed to delete card: ${e.toString()}'));
      await loadCards();
    }
  }

  /// Delete a card by backend ID (MongoDB _id)
  /// Only works with ApiCardRepository
  Future<void> deleteCardByBackendId(String backendId) async {
    emit(CardLoading());

    try {
      if (_repository is dynamic &&
          _repository.runtimeType.toString().contains('ApiCardRepository')) {
        await (_repository as dynamic).deleteCardByBackendId(backendId);
        await loadCards();
      } else {
        throw UnimplementedError('Backend deletion requires API repository');
      }
    } on NetworkException catch (e) {
      emit(CardError(e.message));
      await loadCards();
    } catch (e) {
      emit(CardError('Failed to delete card: ${e.toString()}'));
      await loadCards();
    }
  }

  /// Delete a card silently in the background without showing loading state
  /// Does not reload cards - UI already removed it
  Future<void> deleteCardSilently(int id) async {
    try {
      await _repository.deleteCard(id, userId: _userId);
    } catch (e) {
      debugPrint('Error deleting card in background: $e');
    }
  }

  /// Delete a card by backend ID silently in the background without showing loading state
  /// Does not reload cards - UI already removed it
  Future<void> deleteCardByBackendIdSilently(String backendId) async {
    try {
      if (_repository is dynamic &&
          _repository.runtimeType.toString().contains('ApiCardRepository')) {
        await (_repository as dynamic).deleteCardByBackendId(backendId);
      }
    } catch (e) {
      debugPrint('Error deleting card in background: $e');
    }
  }

  /// Search cards
  Future<void> searchCards(String query) async {
    // If state is already loaded, just update search query
    if (state is CardLoaded) {
      final currentState = state as CardLoaded;
      emit(CardLoaded(
        cards: currentState.cards,
        searchQuery: query,
        selectedCategory: currentState.selectedCategory,
      ));
      return;
    }

    // Otherwise load all cards with search query
    if (query.isEmpty) {
      await loadCards();
      return;
    }

    emit(CardLoading());

    try {
      final cards = await _repository.searchCards(query, userId: _userId);
      emit(CardLoaded(cards: cards, searchQuery: query));
    } on NetworkException catch (e) {
      emit(CardError(e.message));
    } catch (e) {
      emit(CardError('Search failed: ${e.toString()}'));
    }
  }

  /// Filter cards by category
  Future<void> filterByCategory(String? category) async {
    // If no category selected, load all cards
    if (category == null) {
      await loadCards();
      return;
    }

    // Otherwise, filter client-side from current state
    if (state is CardLoaded) {
      final currentState = state as CardLoaded;
      emit(CardLoaded(
        cards: currentState.cards,
        searchQuery: currentState.searchQuery,
        selectedCategory: category,
      ));
    } else {
      // If not in loaded state, load all cards first then filter
      emit(CardLoading());
      try {
        final cards = await _repository.getAllCards(userId: _userId);
        emit(CardLoaded(
          cards: cards,
          selectedCategory: category,
        ));
      } catch (e) {
        emit(CardError('Failed to filter cards: ${e.toString()}'));
      }
    }
  }

  /// Collect card via shareable ID (QR code or manual entry)
  /// Only works with ApiCardRepository
  Future<CardInfo?> collectCardByShareableId(String shareableId) async {
    emit(CardLoading());

    try {
      if (_repository is dynamic &&
          _repository.runtimeType.toString().contains('ApiCardRepository')) {
        final CardInfo card = await (_repository as dynamic)
            .collectCardByShareableId(shareableId);
        emit(CardAdded(card));
        await loadCards();
        return card;
      } else {
        throw UnimplementedError('Shareable ID collection requires API');
      }
    } on ValidationException catch (e) {
      emit(CardError(e.message));
      await loadCards();
      return null;
    } on NotFoundException catch (e) {
      emit(CardError(e.message));
      await loadCards();
      return null;
    } on NetworkException catch (e) {
      emit(CardError(e.message));
      await loadCards();
      return null;
    } catch (e) {
      emit(CardError('Failed to collect card: ${e.toString()}'));
      await loadCards();
      return null;
    }
  }
}
