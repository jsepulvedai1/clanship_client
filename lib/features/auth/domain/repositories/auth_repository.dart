import 'package:fpdart/fpdart.dart';
import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? address,
    String? avatarPath,
    double? latitude,
    double? longitude,
  });
  Future<Either<Failure, void>> requestPasswordReset(String email);
}
