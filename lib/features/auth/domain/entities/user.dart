import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarPath;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarPath,
  });

  /// Creates a copy of this User with the given fields replaced by the new values.
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarPath,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  List<Object?> get props => [id, email, name, avatarPath];
}
