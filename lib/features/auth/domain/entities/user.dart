import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarPath;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? address;
  final double? latitude;
  final double? longitude;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarPath,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
  });

  /// Creates a copy of this User with the given fields replaced by the new values.
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarPath,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    avatarPath,
    firstName,
    lastName,
    phoneNumber,
    address,
    latitude,
    longitude,
  ];
}
