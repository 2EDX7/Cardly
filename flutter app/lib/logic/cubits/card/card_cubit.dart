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
  Future<void> addCard(CardInfo card) async {
    emit(CardLoading());
    
    try {
      await _repository.addCard(card, userId: _userId);
      await loadCards();
    } on ValidationException catch (e) {
      emit(CardError(e.message));
      // Reload to show current state
      await loadCards();
    } on NetworkException catch (e) {
      emit(CardError(e.message));
      await loadCards();
    } catch (e) {
      emit(CardError('Failed to add card: ${e.toString()}'));
      await loadCards();
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

  /// Search cards
  Future<void> searchCards(String query) async {
    if (query.isEmpty) {
      await loadCards();
      return;
    }
    
    emit(CardLoading());
    
    try {
      final cards = await _repository.searchCards(query, userId: _userId);
      emit(CardLoaded(cards: cards));
    } on NetworkException catch (e) {
      emit(CardError(e.message));
    } catch (e) {
      emit(CardError('Search failed: ${e.toString()}'));
    }
  }

  /// Filter cards by category
  Future<void> filterByCategory(String category) async {
    emit(CardLoading());
    
    try {
      final cards = await _repository.getCardsByCategory(category, userId: _userId);
      emit(CardLoaded(cards: cards));
    } on NetworkException catch (e) {
      emit(CardError(e.message));
    } catch (e) {
      emit(CardError('Filter failed: ${e.toString()}'));
    }
  }

  /// Collect card via shareable ID (QR code or manual entry)
  /// Only works with ApiCardRepository
  Future<void> collectCardByShareableId(String shareableId) async {
    emit(CardLoading());
    
    try {
      if (_repository is dynamic && 
          _repository.runtimeType.toString().contains('ApiCardRepository')) {
        await (_repository as dynamic).collectCardByShareableId(shareableId);
        await loadCards();
      } else {
        throw UnimplementedError('Shareable ID collection requires API');
      }
    } on ValidationException catch (e) {
      emit(CardError(e.message));
      await loadCards();
    } on NotFoundException catch (e) {
      emit(CardError(e.message));
      await loadCards();
    } on NetworkException catch (e) {
      emit(CardError(e.message));
      await loadCards();
    } catch (e) {
      emit(CardError('Failed to collect card: ${e.toString()}'));
      await loadCards();
    }
  }
}
