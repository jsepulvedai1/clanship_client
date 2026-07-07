import 'package:clanship_cliente/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String errorMessage;
  const AuthFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class PasswordResetSuccess extends AuthState {
  final String message;
  const PasswordResetSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordResetFailure extends AuthState {
  final String errorMessage;
  const PasswordResetFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

