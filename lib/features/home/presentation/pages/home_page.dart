import 'dart:io';
import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_cliente/features/auth/data/models/user_model.dart';
import 'package:clanship_cliente/features/auth/data/mappers/user_mapper.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/location_service.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:clanship_cliente/core/network/firebase_notification_helper.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/pages/professional_search_page.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/home_tag_list.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/professional_card.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/address_selection_dialog.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_event.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_state.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTagIndex = 0;
  final LocationService _locationService = getIt<LocationService>();
  String _currentAddress = 'Calle 123, Villa Puerto, Puerto Montt';
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    FirebaseNotificationHelper.uploadFcmToken();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final permission = await _locationService.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await _locationService.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentAddress = 'Mi ubicación actual';
            _currentPosition = position;
          });
          context.read<HomeBloc>().add(
            FetchNearbyProfessionals(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          );
        }
      } else {
        await _locationService.requestPermission();
      }
    } catch (e) {
      debugPrint('Error checking location: $e');
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );

    if (image != null && context.mounted) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final currentUser = authState.user;

        try {
          final bytes = await image.readAsBytes();
          final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

          const String updateAvatarMutation = r'''
            mutation UpdateProfile($firstName: String!, $lastName: String!, $email: String!, $avatarBase64: String) {
              updateProfile(firstName: $firstName, lastName: $lastName, email: $email, avatarBase64: $avatarBase64) {
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

          final client = getIt<GraphQLService>().client;
          final MutationOptions options = MutationOptions(
            document: gql(updateAvatarMutation),
            variables: {
              'firstName': currentUser.firstName ?? '',
              'lastName': currentUser.lastName ?? '',
              'email': currentUser.email,
              'avatarBase64': base64Image,
            },
            fetchPolicy: FetchPolicy.networkOnly,
          );

          final QueryResult result = await client.mutate(options);

          if (!result.hasException) {
            final success =
                result.data?['updateProfile']?['success'] as bool? ?? false;
            if (success) {
              final userData =
                  result.data?['updateProfile']?['user']
                      as Map<String, dynamic>;
              final updatedUserModel = UserModel.fromJson(userData);
              final updatedUser = UserMapper.toEntity(updatedUserModel);

              if (context.mounted) {
                context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
              }
            }
          } else {
            debugPrint(
              'Error uploading avatar: ${result.exception.toString()}',
            );
          }
        } catch (e) {
          debugPrint('Error preparing avatar: $e');
        }
      }
    }
  }

  // Mock Professionals Data (Will be replaced by Bloc state)
  List<Professional> get _currentProfessionals {
    final state = context.watch<HomeBloc>().state;
    if (state is HomeLoaded) {
      return state.professionals;
    }
    return []; // Return empty or show loading if preferred
  }

  // Filtering Logic
  List<Professional> get _filteredProfessionals {
    var list = List<Professional>.from(_currentProfessionals);
    if (list.isEmpty) return [];
    if (_selectedTagIndex == 0) {
      list.sort((a, b) => a.distance.compareTo(b.distance));
    } else {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final tags = [l10n.homeTagNear, l10n.homeTagTopRated];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String name = 'User';
            if (state is AuthAuthenticated) {
              name = state.user.name;
            }

            return Row(
              children: [
                // Stylized Company Logo
                const SizedBox(width: 16),
                // Greeting and User Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.homeGreeting(name),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Profile Picture (Interactive)
                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (state is AuthAuthenticated &&
                              state.user.avatarPath != null &&
                              state.user.avatarPath!.isNotEmpty)
                          ? (state.user.avatarPath!.startsWith('http://') ||
                                    state.user.avatarPath!.startsWith(
                                      'https://',
                                    ))
                                ? NetworkImage(state.user.avatarPath!)
                                : FileImage(File(state.user.avatarPath!))
                                      as ImageProvider
                          : null,
                      child: !(state is AuthAuthenticated &&
                              state.user.avatarPath != null &&
                              state.user.avatarPath!.isNotEmpty)
                          ? const Icon(
                              Icons.person_outline_rounded,
                              size: 24,
                              color: Color(0xFFBCC5D0),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            final position = await _locationService.getCurrentPosition();
            if (mounted) {
              setState(() {
                _currentPosition = position;
              });
              context.read<HomeBloc>().add(
                FetchNearbyProfessionals(
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error refreshing: $e');
          }
        },
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Mi dirección:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                String displayAddress = _currentAddress;
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
                    GestureDetector(
                      onTap: () {
                        final authState = context.read<AuthBloc>().state;
                        String? savedAddress;
                        double? savedLat;
                        double? savedLng;
                        if (authState is AuthAuthenticated) {
                          savedAddress = authState.user.address;
                          savedLat = authState.user.latitude;
                          savedLng = authState.user.longitude;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfessionalSearchPage(
                              initialProfessionals: _currentProfessionals,
                              latitude: _currentPosition?.latitude ?? savedLat,
                              longitude:
                                  _currentPosition?.longitude ?? savedLng,
                              currentAddress:
                                  _currentAddress !=
                                      'Calle 123, Villa Puerto, Puerto Montt'
                                  ? _currentAddress
                                  : (savedAddress ?? _currentAddress),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
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
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '¿Qué servicio buscas?',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Banner Carousel
              // const HomeBannerCarousel(),
              // const SizedBox(height: 10),
              // Tag Selection (Chips)
              HomeTagList(
                tags: tags,
                selectedIndex: _selectedTagIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedTagIndex = index;
                  });
                },
                onViewAll: () {
                  // Future Implementation for All view
                },
              ),
              const SizedBox(height: 16),
              // Normal Grid View
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is HomeFailure) {
                      return Center(
                        child: Text('Error: ${state.errorMessage}'),
                      );
                    }

                    final pros = _filteredProfessionals;
                    if (pros.isEmpty) {
                      return const Center(
                        child: Text('No se encontraron profesionales cerca.'),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: pros.length,
                      itemBuilder: (context, index) {
                        return ProfessionalCard(professional: pros[index]);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
