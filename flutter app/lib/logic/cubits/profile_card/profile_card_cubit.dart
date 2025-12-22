import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/card_info.dart';
import '../../../data/repositories/profile_card_repository.dart';
import '../../../data/api/api_exception.dart';
import 'profile_card_state.dart';

class ProfileCardCubit extends Cubit<ProfileCardState> {
  final ProfileCardRepository _repository;
  String _userId;

  ProfileCardCubit({required ProfileCardRepository repository, String? initialUserId})
      : _repository = repository,
        _userId = initialUserId ?? '',
        super(ProfileCardInitial()) {
    if (_userId.isNotEmpty) {
      loadProfileCard();
    }
  }

 void setUser(String? userId) {
    _userId = userId ?? '';
    if (_userId.isNotEmpty) {
      loadProfileCard();
    }
  }

  Future<void> setUserAsync(String? userId) async {
    _userId = userId ?? '';
    if (_userId.isNotEmpty) {
      await loadProfileCard();
    }
  }

  void reset() {
    _userId = '';
    emit(ProfileCardInitial());
  }

  Future<void> loadProfileCard() async {
    debugPrint('📦 loadProfileCard called for userId=$_userId');
    emit(ProfileCardLoading());
    
    try {
      final card = await _repository.getProfileCard(userId: _userId);
      debugPrint('📦 loadProfileCard: repository returned card: ${card?.name}');
      
      if (card == null || (card.name.isEmpty && card.organization.isEmpty)) {
        emit(ProfileCardEmpty());
      } else {
        debugPrint('📦 loadProfileCard: emitting ProfileCardLoaded');
        debugPrint('📦 Shareable ID: ${card.shareableId}');
        emit(ProfileCardLoaded(card: card));
      }
    } on UnauthorizedException catch (e) {
      debugPrint('📦 loadProfileCard unauthorized: $e');
      emit(ProfileCardError(e.message));
    } on NetworkException catch (e) {
      debugPrint('📦 loadProfileCard network error: $e');
      emit(ProfileCardError(e.message));
    } on ServerException catch (e) {
      debugPrint('📦 loadProfileCard server error: $e');
      emit(ProfileCardError(e.message));
    } catch (e) {
      debugPrint('📦 loadProfileCard error: $e');
      emit(ProfileCardError('Failed to load profile card: ${e.toString()}'));
    }
  }

  Future<void> saveProfileCard(CardInfo card) async {
    try {
      final withUser = card.copyWith(userId: _userId);
      debugPrint('💾 saveProfileCard for userId=$_userId, name=${withUser.name}');
      
      await _repository.saveProfileCard(withUser, userId: _userId);
      
      // Reload to get shareable ID from backend
      await loadProfileCard();
    } on ValidationException catch (e) {
      emit(ProfileCardError(e.message));
    } on NetworkException catch (e) {
      emit(ProfileCardError(e.message));
    } on ServerException catch (e) {
      emit(ProfileCardError(e.message));
    } catch (e) {
      emit(ProfileCardError('Failed to save profile card: ${e.toString()}'));
    }
  }

  /// Get shareable ID for QR code generation
  String? get shareableId {
    if (state is ProfileCardLoaded) {
      return (state as ProfileCardLoaded).card.shareableId;
    }
    return null;
  }

  /// Get shareable link for profile card
  String? get shareableLink {
    final id = shareableId;
    if (id != null) {
      // You can configure the base URL
      return 'https://cardly.app/card/$id'; // Or use your actual domain
    }
    return null;
  }

  /// Get card by shareable ID (for viewing shared cards)
  /// Only works with ApiProfileCardRepository
  Future<CardInfo?> getCardByShareableId(String shareableId) async {
    try {
      if (_repository is dynamic && 
          _repository.runtimeType.toString().contains('ApiProfileCardRepository')) {
        return await (_repository as dynamic).getCardByShareableId(shareableId);
      }
      throw UnimplementedError('Shareable ID requires API');
    } on NotFoundException catch (e) {
      debugPrint('Card not found: $e');
      return null;
    } catch (e) {
      debugPrint('Error getting card by shareable ID: $e');
      return null;
    }
  }
}
