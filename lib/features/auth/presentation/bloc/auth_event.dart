import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

/// Event to update the user's profile picture.
class AvatarUpdated extends AuthEvent {
  final String avatarPath;

  const AvatarUpdated(this.avatarPath);

  @override
  List<Object> get props => [avatarPath];
}
