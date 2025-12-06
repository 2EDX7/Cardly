import '../../../data/models/card_info.dart';

abstract class ProfileCardState {}

class ProfileCardInitial extends ProfileCardState {}

class ProfileCardLoading extends ProfileCardState {}

class ProfileCardEmpty extends ProfileCardState {}

class ProfileCardLoaded extends ProfileCardState {
  final CardInfo card;
  ProfileCardLoaded({required this.card});
}

class ProfileCardError extends ProfileCardState {
  final String message;
  ProfileCardError(this.message);
}
