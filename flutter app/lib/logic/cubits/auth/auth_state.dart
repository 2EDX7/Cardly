import 'package:equatable/equatable.dart';
import '../../../data/models/user.dart';

enum AuthStatus { unauthenticated, loading, authenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? message;

  const AuthState({
    required this.status,
    this.user,
    this.message,
  });

  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(User user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, message: message);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'user': user?.toMap(),
      'message': message,
    };
  }

  factory AuthState.fromMap(Map<String, dynamic> map) {
    final statusName = map['status'] as String?;
    final status = AuthStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => AuthStatus.unauthenticated,
    );

    return AuthState(
      status: status,
      user: map['user'] != null ? User.fromMap(Map<String, dynamic>.from(map['user'] as Map)) : null,
      message: map['message'] as String?,
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}
