import 'package:clanship_cliente/features/auth/domain/entities/user.dart';
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

class UserAuthenticated extends AuthEvent {
  final User user;

  const UserAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Event to update the user's profile picture.
class AvatarUpdated extends AuthEvent {
  final String avatarPath;

  const AvatarUpdated(this.avatarPath);

  @override
  List<Object> get props => [avatarPath];
}

class ProfileUpdated extends AuthEvent {
  final User user;

  const ProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String birthdate;
  final String address;
  final String phoneNumber;
  final String? avatarPath;
  final double? latitude;
  final double? longitude;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.birthdate,
    required this.address,
    required this.phoneNumber,
    this.avatarPath,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object> get props => [
        email,
        password,
        name,
        birthdate,
        address,
        phoneNumber,
        avatarPath ?? '',
        latitude ?? 0.0,
        longitude ?? 0.0,
      ];
}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object> get props => [email];
}

