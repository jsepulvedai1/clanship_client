import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/features/home/data/datasources/home_remote_data_source.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/domain/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Professional>>> getNearbyProfessionals({
    required double latitude,
    required double longitude,
    double? radius,
  }) async {
    try {
      final professionals = await remoteDataSource.getNearbyProfessionals(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      return Right(professionals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Professional>>> searchProfessionals(String query) async {
    try {
      final professionals = await remoteDataSource.searchProfessionals(query);
      return Right(professionals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Professional>>> getFavoriteProfessionals() async {
    try {
      final professionals = await remoteDataSource.getFavoriteProfessionals();
      return Right(professionals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String professionalId) async {
    try {
      final isFavorite = await remoteDataSource.toggleFavorite(professionalId);
      return Right(isFavorite);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
