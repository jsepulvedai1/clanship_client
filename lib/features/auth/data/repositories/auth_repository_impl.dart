import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:clanship_cliente/features/auth/data/mappers/user_mapper.dart';
import 'package:clanship_cliente/features/auth/domain/entities/user.dart';
import 'package:clanship_cliente/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return Right(UserMapper.toEntity(userModel));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
    String? referralCode,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
        avatarPath: avatarPath,
        latitude: latitude,
        longitude: longitude,
        referralCode: referralCode,
      );
      return Right(UserMapper.toEntity(userModel));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(UserMapper.toEntity(userModel));
    } catch (e) {
      final lower = e.toString().toLowerCase();
      if (lower.contains('no saved token') ||
          lower.contains('signature') ||
          lower.contains('session_invalidated') ||
          lower.contains('token is invalid') ||
          lower.contains('token_expired')) {
        return Left(AuthFailure(e.toString()));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await remoteDataSource.requestPasswordReset(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateReferralCode(String code) async {
    try {
      final res = await remoteDataSource.validateReferralCode(code);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getReferralProgramContent({String? language}) async {
    try {
      final res = await remoteDataSource.getReferralProgramContent(language: language);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
