import 'dart:async';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/professional_list_tile.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/address_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:clanship_cliente/features/home/data/models/professional_model.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';

class ProfessionalSearchPage extends StatefulWidget {
  final List<Professional> initialProfessionals;
  final double? latitude;
  final double? longitude;
  final bool initialUrgencyMode;
  final String? currentAddress;

  const ProfessionalSearchPage({
    super.key,
    required this.initialProfessionals,
    this.latitude,
    this.longitude,
    this.initialUrgencyMode = false,
    this.currentAddress,
  });

  @override
  State<ProfessionalSearchPage> createState() => _ProfessionalSearchPageState();
}

class _ProfessionalSearchPageState extends State<ProfessionalSearchPage> {
  late bool _isUrgencyMode;
  final TextEditingController _searchController = TextEditingController();
  List<Professional> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  double? _activeLatitude;
  double? _activeLongitude;

  @override
  void initState() {
    super.initState();
    _isUrgencyMode = widget.initialUrgencyMode;
    _searchResults = widget.initialProfessionals;

    final authState = context.read<AuthBloc>().state;
    double? fallbackLat;
    double? fallbackLng;
    if (authState is AuthAuthenticated) {
      fallbackLat = authState.user.latitude;
      fallbackLng = authState.user.longitude;
    }
    _activeLatitude = widget.latitude ?? fallbackLat;
    _activeLongitude = widget.longitude ?? fallbackLng;

    if (widget.latitude == null && _activeLatitude != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch('');
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<Professional> get _filteredProfessionals {
    var list = List<Professional>.from(_searchResults);
    if (_isUrgencyMode) {
      list = list.where((p) => p.acceptsUrgency).toList();
    }
    return list;
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(text);
    });
  }

  Future<void> _performSearch(String text) async {
    if (_activeLatitude == null || _activeLongitude == null) {
      if (mounted) {
        setState(() {
          final query = text.toLowerCase();
          _searchResults = widget.initialProfessionals
              .where((p) => p.name.toLowerCase().contains(query) || p.specialty.toLowerCase().contains(query))
              .toList();
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      const String searchQuery = r'''
        query SearchNearbyProfessionals($latitude: Float!, $longitude: Float!, $query: String) {
          nearbyProfessionals(
            latitude: $latitude, 
            longitude: $longitude, 
            query: $query
          ) {
            id
            username
            avatarUrl
            address
            isAvailable
            latitude
            longitude
            isFavorite
            professionalProfile {
              specialty {
                name
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

      final client = getIt<GraphQLService>().client;
      final result = await client.query(QueryOptions(
        document: gql(searchQuery),
        variables: {
          'latitude': _activeLatitude,
          'longitude': _activeLongitude,
          'query': text,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic> data = result.data?['nearbyProfessionals'] ?? [];
      final list = data
          .map((json) => ProfessionalModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      if (mounted) {
        setState(() {
          _searchResults = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error en la búsqueda GraphQL: $e');
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.latitude != null && state.user.longitude != null) {
            setState(() {
              _activeLatitude = state.user.latitude;
              _activeLongitude = state.user.longitude;
            });
            _performSearch(_searchController.text);
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Búsqueda'),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onSurface,
        ),
        body: Column(
          children: [
            // Unified Search Bar Design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Address Selector Row
                  GestureDetector(
                    onTap: () => AddressSelectionDialog.show(context),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mi dirección:', // I should use l10n here if possible, but keeping it simple for now as requested
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              String displayAddress = widget.currentAddress ?? 'Calle 123, Villa Puerto, Puerto Montt';
                              if (state is AuthAuthenticated &&
                                  state.user.address != null &&
                                  state.user.address!.isNotEmpty) {
                                displayAddress = state.user.address!;
                              }

                              return Text(
                                displayAddress,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Standalone Search Bar
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.transparent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      decoration: InputDecoration(
                        hintText: '¿Qué servicio buscas?',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontStyle: FontStyle.italic,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Urgency Toggle Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5271),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activa el modo Urgencia',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Si necesitas solución a la brevedad',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isUrgencyMode,
                          onChanged: (value) {
                            setState(() {
                              _isUrgencyMode = value;
                            });
                          },
                          activeColor: const Color(0xFF00FF7F),
                          activeTrackColor: Colors.white.withAlpha(100),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey.withAlpha(150),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // List of results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProfessionals.isEmpty
                      ? const Center(child: Text('No se encontraron profesionales.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _filteredProfessionals.length,
                          itemBuilder: (context, index) {
                            return ProfessionalListTile(
                              professional: _filteredProfessionals[index],
                              isUrgencyMode: _isUrgencyMode,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
