import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/core/usecases/usecase.dart';
import 'package:clanship_cliente/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RequestPasswordResetUseCase implements UseCase<void, String> {
  final AuthRepository repository;

  RequestPasswordResetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await repository.requestPasswordReset(email);
  }
}
