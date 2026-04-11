import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ExternalLibsModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  GraphQLClient get graphqlClient {
    final HttpLink httpLink = HttpLink(
      'https://api.antigravity.job/graphql', // Placeholder endpoint
    );

    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(), // Using memory cache by default, can be HiveStore later
    );
  }
}
