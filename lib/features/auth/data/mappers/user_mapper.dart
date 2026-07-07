import 'package:clanship_cliente/features/auth/data/models/user_model.dart';
import 'package:clanship_cliente/features/auth/domain/entities/user.dart';

class UserMapper {
  static User toEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      name: model.name,
      avatarPath: model.avatarPath,
      firstName: model.firstName,
      lastName: model.lastName,
      phoneNumber: model.phoneNumber,
      address: model.address,
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }

  static UserModel fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}
