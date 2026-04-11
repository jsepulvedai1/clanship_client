import 'package:clanship_cliente/features/auth/data/models/user_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GraphQLClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String email, String password) async {
    // Mocking successful login for development
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulate network latency
    return const UserModel(id: '1', email: 'dev@clanship.com', name: 'Javier');
  }
}
