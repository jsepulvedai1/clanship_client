import 'package:clanship_cliente/core/error/failures.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:fpdart/fpdart.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Professional>>> getNearbyProfessionals({
    required double latitude,
    required double longitude,
    double? radius,
  });

  Future<Either<Failure, List<Professional>>> searchProfessionals(String query);

  Future<Either<Failure, List<Professional>>> getFavoriteProfessionals();

  Future<Either<Failure, bool>> toggleFavorite(String professionalId);
}
