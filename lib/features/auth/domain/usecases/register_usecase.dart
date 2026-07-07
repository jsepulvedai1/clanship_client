import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/core/usecases/usecase.dart';
import 'package:clanship_cliente/features/auth/domain/entities/user.dart';
import 'package:clanship_cliente/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
      phoneNumber: params.phoneNumber,
      address: params.address,
      avatarPath: params.avatarPath,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? address;
  final String? avatarPath;
  final double? latitude;
  final double? longitude;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.address,
    this.avatarPath,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, phoneNumber, address, avatarPath, latitude, longitude];
}
