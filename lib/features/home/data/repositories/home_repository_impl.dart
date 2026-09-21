import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/features/home/data/datasources/home_remote_data_source.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/domain/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import 'package:clanship_cliente/core/services/ugc_safety_service.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final UgcSafetyService ugcSafetyService;

  HomeRepositoryImpl(this.remoteDataSource, this.ugcSafetyService);

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
      final blockedIds = ugcSafetyService.getBlockedUserIds();
      final filtered = professionals.where((p) => !blockedIds.contains(p.id)).toList();
      return Right(filtered);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Professional>>> searchProfessionals(String query) async {
    try {
      final professionals = await remoteDataSource.searchProfessionals(query);
      final blockedIds = ugcSafetyService.getBlockedUserIds();
      final filtered = professionals.where((p) => !blockedIds.contains(p.id)).toList();
      return Right(filtered);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Professional>>> getFavoriteProfessionals() async {
    try {
      final professionals = await remoteDataSource.getFavoriteProfessionals();
      final blockedIds = ugcSafetyService.getBlockedUserIds();
      final filtered = professionals.where((p) => !blockedIds.contains(p.id)).toList();
      return Right(filtered);
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
