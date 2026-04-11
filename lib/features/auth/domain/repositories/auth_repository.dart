import 'package:fpdart/fpdart.dart';
import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
