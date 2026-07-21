import 'dart:convert';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/add_address_screen.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_cliente/features/auth/data/models/user_model.dart';
import 'package:clanship_cliente/features/auth/data/mappers/user_mapper.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_event.dart';

class AddressSelectionDialog extends StatefulWidget {
  const AddressSelectionDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddressSelectionDialog(),
    );
  }

  @override
  State<AddressSelectionDialog> createState() => _AddressSelectionDialogState();
}

class _AddressSelectionDialogState extends State<AddressSelectionDialog> {
  List<Map<String, dynamic>> _savedAddresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final String? jsonStr = prefs.getString('saved_user_addresses');
      if (jsonStr != null) {
        final List<dynamic> decoded = json.decode(jsonStr);
        setState(() {
          _savedAddresses = decoded
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      }
    } catch (_) {}
    setState(() {
      _loading = false;
    });
  }

  Future<void> _deleteAddress(int index) async {
    setState(() {
      _savedAddresses.removeAt(index);
    });
    final prefs = getIt<SharedPreferences>();
    await prefs.setString('saved_user_addresses', json.encode(_savedAddresses));
  }

  Future<void> _selectAddress(Map<String, dynamic> addr) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      _loading = true;
    });

    final currentUser = authState.user;
    const String updateProfileMutation = r'''
      mutation UpdateProfile($firstName: String!, $lastName: String!, $email: String!, $phoneNumber: String, $address: String, $latitude: Float, $longitude: Float) {
        updateProfile(firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, address: $address, latitude: $latitude, longitude: $longitude) {
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
          }
        }
      }
    ''';

    try {
      final client = getIt<GraphQLService>().client;
      final MutationOptions options = MutationOptions(
        document: gql(updateProfileMutation),
        variables: {
          'firstName': currentUser.firstName ?? '',
          'lastName': currentUser.lastName ?? '',
          'email': currentUser.email,
          'phoneNumber': currentUser.phoneNumber,
          'address': addr['address'],
          'latitude': addr['latitude'],
          'longitude': addr['longitude'],
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.mutate(options);
      if (!result.hasException) {
        final success =
            result.data?['updateProfile']?['success'] as bool? ?? false;
        if (success) {
          final userData =
              result.data?['updateProfile']?['user'] as Map<String, dynamic>;
          final updatedUserModel = UserModel.fromJson(userData);
          final updatedUser = UserMapper.toEntity(updatedUserModel);

          if (mounted) {
            context.read<AuthBloc>().add(ProfileUpdated(updatedUser));

            context.read<HomeBloc>().add(
              FetchNearbyProfessionals(
                latitude: addr['latitude'],
                longitude: addr['longitude'],
              ),
            );

            Navigator.pop(context);
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.addressDialogTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            else ...[
              // Saved Addresses List
              if (_savedAddresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Text(
                    'No tienes direcciones guardadas.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _savedAddresses.length,
                    itemBuilder: (context, index) {
                      final addr = _savedAddresses[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          addr['address'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteAddress(index),
                        ),
                        onTap: () => _selectAddress(addr),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // Add new address
              if (_savedAddresses.length < 3)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAddressScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.addressDialogAdd,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    'Límite de 3 direcciones alcanzado.',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
