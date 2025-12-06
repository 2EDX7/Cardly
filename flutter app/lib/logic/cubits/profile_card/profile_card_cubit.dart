import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/card_info.dart';
import '../../../data/models/user.dart';
import '../../../presentation/widgets/business_card/card_background.dart';
import '../../../data/repositories/profile_card_repository.dart';
import '../../../data/repositories/sqlite_profile_card_repository.dart';
import 'profile_card_state.dart';

class ProfileCardCubit extends Cubit<ProfileCardState> {
  final ProfileCardRepository _repository;
  String _userId;

  ProfileCardCubit({ProfileCardRepository? repository, String? initialUserId})
      : _repository = repository ?? SQLiteProfileCardRepository(),
        _userId = initialUserId ?? DatabaseHelper.defaultUserId,
        super(ProfileCardInitial()) {
    loadProfileCard();
  }

  void setUser(String? userId) {
    _userId = userId ?? DatabaseHelper.defaultUserId;
    loadProfileCard();
  }

  Future<void> setUserAsync(String? userId) async {
    _userId = userId ?? DatabaseHelper.defaultUserId;
    await loadProfileCard();
  }

  /// Load card from user object (used after login when card is already fetched)
  void loadCardFromUser(User user) {
    _userId = user.id;
    debugPrint('📦 loadCardFromUser called for user: ${user.id}');
    debugPrint('📦 Card data: name=${user.cardName}, org=${user.cardOrganization}, bg=${user.cardBackground}');
    if (user.cardName != null && user.cardName!.isNotEmpty) {
      // Reconstruct CardInfo from User's card fields
      final card = CardInfo(
        name: user.cardName ?? '',
        organization: user.cardOrganization ?? '',
        jobTitle: user.cardJobTitle ?? '',
        email: user.cardEmail ?? '',
        phone: user.cardPhone ?? '',
        location: user.cardLocation ?? '',
        about: user.cardAbout ?? '',
        website: user.cardWebsite ?? '',
        logoText: user.cardLogoText,
        category: user.cardCategory,
        background: _stringToBackground(user.cardBackground),
        userId: user.id,
        fontColor: _stringToColor(user.cardFontColor),
      );
      emit(ProfileCardLoaded(card: card));
    } else {
      emit(ProfileCardEmpty());
    }
  }

  /// Convert string to CardBackground
  CardBackground? _stringToBackground(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'gold':
        return CardBackground.gold;
      case 'green':
        return CardBackground.green;
      case 'grey':
        return CardBackground.grey;
      case 'purple':
        return CardBackground.purple;
      case 'blue':
        return CardBackground.blue;
      case 'goldsilver':
        return CardBackground.goldSilver;
      case 'purpleblue':
        return CardBackground.purpleBlue;
      case 'orangepink':
        return CardBackground.orangePink;
      case 'greenblue':
        return CardBackground.greenBlue;
      case 'sunset':
        return CardBackground.sunset;
      case 'defaultgradient':
        return CardBackground.defaultGradient;
      default:
        return null;
    }
  }

  /// Convert string to Color
  Color? _stringToColor(String? value) {
    if (value == null) return null;
    try {
      return Color(int.parse(value.replaceFirst('0x', ''), radix: 16));
    } catch (e) {
      return null;
    }
  }

  void reset() {
    _userId = DatabaseHelper.defaultUserId;
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
        emit(ProfileCardLoaded(card: card));
      }
    } catch (e) {
      debugPrint('📦 loadProfileCard error: $e');
      emit(ProfileCardError('Failed to load profile card: ${e.toString()}'));
    }
  }

  Future<void> saveProfileCard(CardInfo card) async {
    try {
      final withUser = card.copyWith(userId: _userId);
      debugPrint('💾 saveProfileCard for userId=$_userId, name=${withUser.name}, bg=${withUser.background}, fontColor=${withUser.fontColor}');
      await _repository.saveProfileCard(withUser, userId: _userId);
      emit(ProfileCardLoaded(card: withUser));
    } catch (e) {
      emit(ProfileCardError('Failed to save profile card: ${e.toString()}'));
    }
  }
}
