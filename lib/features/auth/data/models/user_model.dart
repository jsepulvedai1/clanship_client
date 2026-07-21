import 'package:clanship_cliente/features/auth/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarPath,
    super.firstName,
    super.lastName,
    super.phoneNumber,
    super.address,
    super.latitude,
    super.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);
    if (!data.containsKey('name') || data['name'] == null) {
      final firstName = data['firstName'] as String? ?? '';
      final lastName = data['lastName'] as String? ?? '';
      data['name'] = [firstName, lastName].where((e) => e.isNotEmpty).join(' ');
      if ((data['name'] as String).isEmpty) {
        data['name'] = data['username'] ?? data['email'] ?? 'Usuario';
      }
    }
    
    // Map avatarUrl from backend to avatarPath
    if (data.containsKey('avatarUrl') && data['avatarUrl'] != null) {
      data['avatarPath'] = data['avatarUrl'];
    }

    // Convertir latitude y longitude de String a num si vienen como String (Graphene DecimalField)
    if (data['latitude'] is String) {
      data['latitude'] = double.tryParse(data['latitude']);
    }
    if (data['longitude'] is String) {
      data['longitude'] = double.tryParse(data['longitude']);
    }
    
    return _$UserModelFromJson(data);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  UserModel copyWith({
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
    return UserModel(
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
}
