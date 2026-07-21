import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clanship_cliente/features/auth/data/models/user_model.dart';
import 'package:clanship_cliente/core/network/firebase_notification_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
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
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GraphQLClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String email, String password) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');

    const String loginMutation = r'''
      mutation TokenAuth($username: String!, $password: String!) {
        tokenAuth(username: $username, password: $password) {
          token
          refreshToken
        }
      }
    ''';

    const String meQuery = r'''
      query {
        me {
          id
          username
          email
          phoneNumber
          firstName
          lastName
          address
          latitude
          longitude
          avatarUrl
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(loginMutation),
      variables: {'username': email, 'password': password},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final token = result.data?['tokenAuth']?['token'];

    // Save token in flutter_secure_storage so AuthLink caxP use it securely
    if (token != null) {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt_token', value: token);
    }

    // Proceed to fetch 'me'
    final QueryOptions meOptions = QueryOptions(
      document: gql(meQuery),
      fetchPolicy: FetchPolicy.networkOnly,
      // If needed, we can pass context here to add the Authorization header manually for this specific request
      context: Context().withEntry(
        HttpLinkHeaders(headers: {'Authorization': 'JWT $token'}),
      ),
    );

    final QueryResult meResult = await client.query(meOptions);

    if (meResult.hasException) {
      throw Exception(meResult.exception.toString());
    }

    final userData = meResult.data?['me'] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception('Could not fetch user details');
    }

    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? address,
    String? avatarPath,
    double? latitude,
    double? longitude,
  }) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');

    const String registerMutation = r'''
      mutation RegisterUser($email: String!, $password: String!, $firstName: String!, $lastName: String!, $phoneNumber: String, $userType: String!) {
        registerUser(
          email: $email, 
          password: $password, 
          firstName: $firstName, 
          lastName: $lastName, 
          phoneNumber: $phoneNumber,
          userType: $userType
        ) {
          success
          user {
            id
            userType
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(registerMutation),
      variables: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'userType': 'CUSTOMER',
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['registerUser']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Registration failed');
    }

    // After successful registration, we login the user
    final userModel = await login(email, password);

    // If address or avatar path is provided, update the profile
    if ((address != null && address.isNotEmpty) ||
        (avatarPath != null && avatarPath.isNotEmpty)) {
      String? base64Image;
      if (avatarPath != null && avatarPath.isNotEmpty) {
        try {
          final file = File(avatarPath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            base64Image = base64Encode(bytes);
          }
        } catch (e) {
          print('Error encoding avatar image: $e');
        }
      }

      const String updateProfileMutation = r'''
        mutation UpdateProfile($firstName: String!, $lastName: String!, $email: String!, $phoneNumber: String, $address: String, $latitude: Float, $longitude: Float, $avatarBase64: String) {
          updateProfile(firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, address: $address, latitude: $latitude, longitude: $longitude, avatarBase64: $avatarBase64) {
            success
            user {
              id
              username
              email
              phoneNumber
              firstName
              lastName
              address
              latitude
              longitude
              avatarUrl
            }
          }
        }
      ''';

      final MutationOptions updateOptions = MutationOptions(
        document: gql(updateProfileMutation),
        variables: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'avatarBase64': base64Image,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult updateResult = await client.mutate(updateOptions);
      if (!updateResult.hasException) {
        final updateSuccess =
            updateResult.data?['updateProfile']?['success'] as bool? ?? false;
        if (updateSuccess) {
          final updatedUserData =
              updateResult.data?['updateProfile']?['user']
                  as Map<String, dynamic>?;
          if (updatedUserData != null) {
            final userWithUpdatedProfile = UserModel.fromJson(updatedUserData);
            if (avatarPath != null && avatarPath.isNotEmpty) {
              return userWithUpdatedProfile.copyWith(avatarPath: avatarPath);
            }
            return userWithUpdatedProfile;
          }
        }
      }
    }

    if (avatarPath != null && avatarPath.isNotEmpty) {
      return userModel.copyWith(avatarPath: avatarPath);
    }
    return userModel;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    const String meQuery = r'''
      query {
        me {
          id
          username
          email
          phoneNumber
          firstName
          lastName
          address
          latitude
          longitude
          avatarUrl
        }
      }
    ''';

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No saved token found');
    }

    final QueryOptions meOptions = QueryOptions(
      document: gql(meQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult meResult = await client.query(meOptions);

    if (meResult.hasException) {
      throw Exception(meResult.exception.toString());
    }

    final userData = meResult.data?['me'] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception('Could not fetch user details');
    }

    return UserModel.fromJson(userData);
  }

  @override
  Future<void> logout() async {
    try {
      await FirebaseNotificationHelper.deleteFcmToken();
    } catch (e) {
      // Ignorar errores de red para asegurar que el logout local ocurra de todos modos
    }
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    const String mutation = r'''
      mutation RequestPasswordReset($email: String!) {
        requestPasswordReset(email: $email) {
          success
          message
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'email': email},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['requestPasswordReset']?['success'] as bool? ?? false;
    final message = result.data?['requestPasswordReset']?['message'] as String?;
    if (!success) {
      throw Exception(message ?? 'Failed to request password reset');
    }
  }
}
