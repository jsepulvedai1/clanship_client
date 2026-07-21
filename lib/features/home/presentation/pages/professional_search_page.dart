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
import 'package:clanship_cliente/features/home/presentation/widgets/services_filter_sheet.dart';

class ProfessionalSearchPage extends StatefulWidget {
  final List<Professional> initialProfessionals;
  final double? latitude;
  final double? longitude;
  final bool initialUrgencyMode;
  final String? currentAddress;
  final Set<int> initialSelectedTagIds;
  final Set<int> initialSelectedSubtagIds;

  const ProfessionalSearchPage({
    super.key,
    required this.initialProfessionals,
    this.latitude,
    this.longitude,
    this.initialUrgencyMode = false,
    this.currentAddress,
    this.initialSelectedTagIds = const {},
    this.initialSelectedSubtagIds = const {},
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

  final Set<int> _selectedTagIds = {};
  final Set<int> _selectedSubtagIds = {};
  List<dynamic> _specialties = [];

  Future<void> _fetchSpecialties() async {
    try {
      const String specialtiesQuery = r'''
        query GetSpecialtiesTagsAndSubTags {
          specialties {
            id
            name
            color
            tags {
              id
              name
              subtags {
                id
                name
              }
            }
          }
        }
      ''';

      final client = getIt<GraphQLService>().client;
      final result = await client.query(
        QueryOptions(
          document: gql(specialtiesQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (!result.hasException && result.data != null) {
        if (mounted) {
          setState(() {
            _specialties = result.data?['specialties'] as List<dynamic>? ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching specialties for filter: $e');
    }
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ServicesFilterSheet(
          specialties: _specialties,
          initialSelectedTagIds: _selectedTagIds,
          initialSelectedSubtagIds: _selectedSubtagIds,
          onApply: (selectedTagIds, selectedSubtagIds) {
            setState(() {
              _selectedTagIds.clear();
              _selectedTagIds.addAll(selectedTagIds);
              _selectedSubtagIds.clear();
              _selectedSubtagIds.addAll(selectedSubtagIds);
            });
            _performSearch(_searchController.text);
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  List<Map<String, dynamic>> _resolveSelectedFilterPaths() {
    final List<Map<String, dynamic>> paths = [];
    for (final spec in _specialties) {
      final specName = spec['name'] as String;
      final tags = spec['tags'] as List<dynamic>? ?? [];
      for (final tag in tags) {
        final tagId = int.parse(tag['id'].toString());
        final tagName = tag['name'] as String;
        final subtags = tag['subtags'] as List<dynamic>? ?? [];

        if (subtags.isEmpty) {
          if (_selectedTagIds.contains(tagId)) {
            paths.add({
              'type': 'tag',
              'id': tagId,
              'text': '$specName > $tagName',
            });
          }
        } else {
          for (final subtag in subtags) {
            final subtagId = int.parse(subtag['id'].toString());
            final subname = subtag['name'] as String;
            if (_selectedSubtagIds.contains(subtagId)) {
              paths.add({
                'type': 'subtag',
                'id': subtagId,
                'text': '$specName > $tagName > $subname',
              });
            }
          }
        }
      }
    }
    return paths;
  }

  @override
  void initState() {
    super.initState();
    _isUrgencyMode = widget.initialUrgencyMode;
    _searchResults = widget.initialProfessionals;

    // Pre-load filters passed from the home filter sheet
    _selectedTagIds.addAll(widget.initialSelectedTagIds);
    _selectedSubtagIds.addAll(widget.initialSelectedSubtagIds);

    _fetchSpecialties();

    final authState = context.read<AuthBloc>().state;
    double? fallbackLat;
    double? fallbackLng;
    if (authState is AuthAuthenticated) {
      fallbackLat = authState.user.latitude;
      fallbackLng = authState.user.longitude;
    }
    _activeLatitude = widget.latitude ?? fallbackLat;
    _activeLongitude = widget.longitude ?? fallbackLng;

    // If filters are pre-selected or we have a location, trigger search immediately
    if (_activeLatitude != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch('');
      });
    } else if (widget.latitude == null && _activeLatitude != null) {
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

  Future<void> _performSearch(String text) async {
    if (_activeLatitude == null || _activeLongitude == null) {
      if (mounted) {
        setState(() {
          final query = text.toLowerCase();

          final List<String> matchingParentTags = [];
          for (final spec in _specialties) {
            final tags = spec['tags'] as List<dynamic>? ?? [];
            for (final tag in tags) {
              final tagName = tag['name'] as String;
              final subtags = tag['subtags'] as List<dynamic>? ?? [];
              for (final subtag in subtags) {
                final subtagName = (subtag['name'] as String).toLowerCase();
                if (subtagName.contains(query)) {
                  matchingParentTags.add(tagName.toLowerCase());
                }
              }
            }
          }

          _searchResults = widget.initialProfessionals
              .where(
                (p) =>
                    p.name.toLowerCase().contains(query) ||
                    p.specialty.toLowerCase().contains(query) ||
                    p.tags.any((tag) => tag.toLowerCase().contains(query)) ||
                    p.synonyms.any(
                      (syn) => syn.toLowerCase().contains(query),
                    ) ||
                    p.tags.any((t) {
                      final cleanTag = t.toLowerCase().split('|')[0];
                      return matchingParentTags.contains(cleanTag);
                    }),
              )
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
        query SearchNearbyProfessionals($latitude: Float!, $longitude: Float!, $query: String, $tagIds: [Int], $subtagIds: [Int]) {
          nearbyProfessionals(
            latitude: $latitude, 
            longitude: $longitude, 
            query: $query,
            tagIds: $tagIds,
            subtagIds: $subtagIds
          ) {
            id
            username
            firstName
            lastName
            avatarUrl
            address
            isAvailable
            isEmergency
            latitude
            longitude
            isFavorite
            distance
            professionalProfile {
              specialty {
                name
                iconUrl
                color
                synonyms
              }
              hourlyRate
              rating
              bio
              facebookUrl
              instagramUrl
              tiktokUrl
              tags {
                id
                name
                color
              }
              subtags {
                id
                name
                color
              }
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
      final result = await client.query(
        QueryOptions(
          document: gql(searchQuery),
          variables: {
            'latitude': _activeLatitude,
            'longitude': _activeLongitude,
            'query': text,
            'tagIds': _selectedTagIds.toList(),
            'subtagIds': _selectedSubtagIds.toList(),
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic> data = result.data?['nearbyProfessionals'] ?? [];
      final list = data
          .map(
            (json) => ProfessionalModel.fromJson(
              json as Map<String, dynamic>,
            ).toEntity(),
          )
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
          foregroundColor:
              theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onSurface,
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
                              String displayAddress =
                                  widget.currentAddress ??
                                  'Calle 123, Villa Puerto, Puerto Montt';
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
                  // Search Bar → abre el modal de filtro al tocar
                  GestureDetector(
                    onTap: _showFiltersBottomSheet,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        border:
                            (_selectedTagIds.isNotEmpty ||
                                _selectedSubtagIds.isNotEmpty)
                            ? Border.all(color: AppColors.primary, width: 1.5)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (_selectedTagIds.isNotEmpty ||
                                      _selectedSubtagIds.isNotEmpty)
                                  ? '${_selectedTagIds.length + _selectedSubtagIds.length} filtro(s) activo(s)'
                                  : '¿Qué servicio buscas?',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color:
                                    (_selectedTagIds.isNotEmpty ||
                                        _selectedSubtagIds.isNotEmpty)
                                    ? AppColors.primary
                                    : theme.colorScheme.onSurface.withOpacity(
                                        0.4,
                                      ),
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                fontWeight:
                                    (_selectedTagIds.isNotEmpty ||
                                        _selectedSubtagIds.isNotEmpty)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Botón tune integrado en el bar
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color:
                                  (_selectedTagIds.isNotEmpty ||
                                      _selectedSubtagIds.isNotEmpty)
                                  ? AppColors.primary
                                  : theme.colorScheme.onSurface.withOpacity(
                                      0.08,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color:
                                  (_selectedTagIds.isNotEmpty ||
                                      _selectedSubtagIds.isNotEmpty)
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedTagIds.isNotEmpty ||
                      _selectedSubtagIds.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Resumen de selección',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTagIds.clear();
                                    _selectedSubtagIds.clear();
                                  });
                                  _performSearch(_searchController.text);
                                },
                                child: const Text(
                                  'Limpiar todo',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _resolveSelectedFilterPaths().map((path) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        path['text'] as String,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          final id = path['id'] as int;
                                          if (path['type'] == 'tag') {
                                            _selectedTagIds.remove(id);
                                          } else {
                                            _selectedSubtagIds.remove(id);
                                          }
                                        });
                                        _performSearch(_searchController.text);
                                      },
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          activeColor: const Color.fromARGB(255, 255, 255, 255),
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
                  ? const Center(
                      child: Text('No se encontraron profesionales.'),
                    )
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
