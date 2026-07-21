import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// ignore: implementation_imports
import 'package:flutter_google_places_hoc081098/src/google_maps_webservice/places.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/features/auth/data/mappers/user_mapper.dart';
import 'package:clanship_cliente/features/auth/data/models/user_model.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // REEMPLAZA ESTO POR TU API KEY REAL
  final String _googleApiKey = "AIzaSyB985z0U9nO1LXSrpnn4qwnbDAe-7opBHI";
  late GoogleMapsPlaces _places;
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _places = GoogleMapsPlaces(apiKey: _googleApiKey);
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: _googleApiKey,
      mode: Mode.fullscreen, // Cambiado de overlay a fullscreen
      language: "es",
      hint: "Escribe tu dirección...",
      components: [Component(Component.country, "cl")],
    );

    if (p != null && p.placeId != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
        p.placeId!,
      );

      if (detail.isOkay) {
        final lat = detail.result.geometry!.location.lat;
        final lng = detail.result.geometry!.location.lng;
        setState(() {
          _selectedLocation = LatLng(lat, lng);
          _controller.text = p.description ?? "";
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 16),
        );
      }
    }
  }

  Future<void> _saveAddress() async {
    if (_selectedLocation == null || _controller.text.isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      Navigator.pop(context, _selectedLocation);
      return;
    }

    final currentUser = authState.user;

    setState(() {
      _isLoading = true;
    });

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
      final client = getIt<GraphQLClient>();
      final MutationOptions options = MutationOptions(
        document: gql(updateProfileMutation),
        variables: {
          'firstName': currentUser.firstName ?? '',
          'lastName': currentUser.lastName ?? '',
          'email': currentUser.email,
          'phoneNumber': currentUser.phoneNumber,
          'address': _controller.text,
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final success =
          result.data?['updateProfile']?['success'] as bool? ?? false;
      if (success) {
        final userData =
            result.data?['updateProfile']?['user'] as Map<String, dynamic>;
        final updatedUserModel = UserModel.fromJson(userData);
        final updatedUser = UserMapper.toEntity(updatedUserModel);

        // Guardar en la lista local de SharedPreferences
        try {
          final prefs = getIt<SharedPreferences>();
          final String? jsonStr = prefs.getString('saved_user_addresses');
          List<Map<String, dynamic>> saved = [];
          if (jsonStr != null) {
            final List<dynamic> decoded = json.decode(jsonStr);
            saved = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          }

          final exists = saved.any((element) => element['address'] == _controller.text);
          if (!exists) {
            if (saved.length >= 3) {
              saved.removeAt(0); // Elimina la más antigua si supera las 3
            }
            saved.add({
              'address': _controller.text,
              'latitude': _selectedLocation!.latitude,
              'longitude': _selectedLocation!.longitude,
            });
            await prefs.setString('saved_user_addresses', json.encode(saved));
          }
        } catch (_) {}

        if (mounted) {
          context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
          Navigator.pop(context, _selectedLocation);
        }
      } else {
        throw Exception('Error al guardar la dirección');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lo sentimos, hubo un error al guardar la dirección.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Dirección")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: _handlePressButton,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _controller.text.isEmpty
                            ? "Buscar dirección..."
                            : _controller.text,
                        style: TextStyle(
                          color: _controller.text.isEmpty
                              ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6)
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.4489, -70.6693),
                zoom: 12,
              ),
              onMapCreated: (c) => _mapController = c,
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId("1"),
                        position: _selectedLocation!,
                      ),
                    }
                  : {},
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedLocation != null && !_isLoading)
                    ? _saveAddress
                    : null,
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : const Text("Guardar dirección"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
