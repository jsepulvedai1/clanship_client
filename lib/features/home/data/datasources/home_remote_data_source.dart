import 'package:clanship_cliente/features/home/data/models/professional_model.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';

abstract class HomeRemoteDataSource {
  Future<List<Professional>> getNearbyProfessionals({
    required double latitude,
    required double longitude,
    double? radius,
  });

  Future<List<Professional>> searchProfessionals(String query);

  Future<List<Professional>> getFavoriteProfessionals();

  Future<bool> toggleFavorite(String professionalId);
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final GraphQLClient client;

  HomeRemoteDataSourceImpl(this.client);

  @override
  Future<List<Professional>> getNearbyProfessionals({
    required double latitude,
    required double longitude,
    double? radius,
  }) async {
    const String query = r'''
      query GetNearbyProfessionals($latitude: Float!, $longitude: Float!, $radiusKm: Float!) {
        nearbyProfessionals(
          latitude: $latitude, 
          longitude: $longitude, 
          radiusKm: $radiusKm
        ) {
          id
          username
          firstName
          lastName
          avatarUrl
          address
          isAvailable
          latitude
          longitude
          isFavorite
          professionalProfile {
            specialty {
              name
              iconUrl
            }
            hourlyRate
            rating
            bio
            facebookUrl
            instagramUrl
            tiktokUrl
            photos {
              id
              imageUrl
            }
            documents {
              id
              name
              fileUrl
              status
              rejectionReason
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radius ?? 10000000010.0,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> data = result.data?['nearbyProfessionals'] ?? [];
    return data
        .map((json) => ProfessionalModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<Professional>> searchProfessionals(String query) async {
    // TODO: Implement search query if available
    return [];
  }

  @override
  Future<List<Professional>> getFavoriteProfessionals() async {
    const String query = r'''
      query GetMyFavorites {
        myFavorites {
          id
          username
          firstName
          lastName
          avatarUrl
          address
          isAvailable
          latitude
          longitude
          isFavorite
          professionalProfile {
            specialty {
              name
              iconUrl
            }
            hourlyRate
            rating
            bio
            facebookUrl
            instagramUrl
            tiktokUrl
            photos {
              id
              imageUrl
            }
            documents {
              id
              name
              fileUrl
              status
              rejectionReason
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> data = result.data?['myFavorites'] ?? [];
    return data
        .map((json) => ProfessionalModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<bool> toggleFavorite(String professionalId) async {
    const String mutation = r'''
      mutation ToggleFavorite($professionalId: ID!) {
        toggleFavorite(professionalId: $professionalId) {
          success
          isFavorite
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'professionalId': professionalId,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final bool isFavorite = result.data?['toggleFavorite']?['isFavorite'] ?? false;
    return isFavorite;
  }
}
