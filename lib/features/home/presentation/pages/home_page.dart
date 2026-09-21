import 'dart:io';
import 'dart:convert';
import 'package:clanship_cliente/core/network/firebase_notification_helper.dart';
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
import 'package:clanship_cliente/core/services/specialties_cache_service.dart';
import 'package:clanship_cliente/core/services/ugc_safety_service.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/pages/professional_search_page.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/services_filter_sheet.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/home_tag_list.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/professional_card.dart';
import 'package:clanship_cliente/features/home/presentation/widgets/address_selection_dialog.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_event.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_state.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:clanship_cliente/features/jobs/presentation/pages/create_public_job_page.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_cliente/core/utils/image_cropper_helper.dart';
import 'dart:async';
import 'package:clanship_cliente/core/network/local_notification_service.dart';
import 'package:clanship_cliente/features/home/presentation/pages/help_webview_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clanship_cliente/core/theme/bloc/seasonal_theme_bloc.dart';
import 'package:clanship_cliente/core/theme/widgets/seasonal_logo_badge.dart';
import 'package:clanship_cliente/core/theme/widgets/seasonal_particles.dart';
import 'package:clanship_cliente/core/theme/widgets/seasonal_top_garland.dart';

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
  List<LocalNotificationItem> _localNotifications = [];
  bool _showAllNotifications = false;
  StreamSubscription? _notificationSubscription;
  bool _isOpeningFilter = false;
  bool _isUrgencyMode = false;

  VoidCallback? _blockedUsersListener;

  @override
  void initState() {
    super.initState();
    getIt<SpecialtiesCacheService>().preloadOrRefresh();
    _checkLocationPermission();
    FirebaseNotificationHelper.uploadFcmToken();
    _loadLocalNotifications();
    _notificationSubscription = LocalNotificationService.onNotificationAdded
        .listen((_) {
          _loadLocalNotifications();
        });
    _blockedUsersListener = () {
      if (mounted) setState(() {});
    };
    getIt<UgcSafetyService>().blockedUserIdsNotifier.addListener(_blockedUsersListener!);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    if (_blockedUsersListener != null) {
      getIt<UgcSafetyService>().blockedUserIdsNotifier.removeListener(_blockedUsersListener!);
    }
    super.dispose();
  }

  Future<void> _loadLocalNotifications() async {
    final list = await LocalNotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _localNotifications = list;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    // 1. Prioridad: Si el usuario ya tiene dirección configurada en su perfil, usamos esa ubicación
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      if (user.latitude != null && user.longitude != null) {
        if (mounted) {
          setState(() {
            if (user.address != null && user.address!.isNotEmpty) {
              _currentAddress = user.address!;
            }
          });
          context.read<HomeBloc>().add(
            FetchNearbyProfessionals(
              latitude: user.latitude!,
              longitude: user.longitude!,
            ),
          );
        }
        return;
      }
    }

    // 2. Si no tiene dirección guardada, usamos el GPS físico del dispositivo como fallback
    try {
      LocationPermission permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }

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
        _loadFallbackLocation();
      }
    } catch (e) {
      debugPrint('Error checking location: $e');
      _loadFallbackLocation();
    }
  }

  void _loadFallbackLocation() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      if (user.latitude != null && user.longitude != null) {
        setState(() {
          if (user.address != null && user.address!.isNotEmpty) {
            _currentAddress = user.address!;
          }
        });
        context.read<HomeBloc>().add(
          FetchNearbyProfessionals(
            latitude: user.latitude!,
            longitude: user.longitude!,
          ),
        );
      }
    }
  }

  /// Carga las especialidades de forma instantánea desde el caché local y abre el filtro.
  Future<void> _openFilterThenSearch(
    BuildContext context, {
    String? savedAddress,
    double? savedLat,
    double? savedLng,
  }) async {
    // Evitar múltiples aperturas si ya hay una en curso
    if (_isOpeningFilter) return;
    setState(() => _isOpeningFilter = true);

    // Fetch specialties from local cache instantly (0ms)
    final cacheService = getIt<SpecialtiesCacheService>();
    List<dynamic> specialties = cacheService.getSpecialties();

    if (specialties.isEmpty) {
      await cacheService.preloadOrRefresh();
      specialties = cacheService.getSpecialties();
    } else {
      // Trigger background refresh in parallel so future opens have fresh data if updated
      cacheService.preloadOrRefresh();
    }

    if (!context.mounted) {
      setState(() => _isOpeningFilter = false);
      return;
    }

    // Show filter sheet; on apply, navigate to search with selected filters
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ServicesFilterSheet(
          specialties: specialties,
          initialSelectedTagIds: const {},
          initialSelectedSubtagIds: const {},
          onApply: (selectedTagIds, selectedSubtagIds) {
            if (!context.mounted) return;
            final auth = context.read<AuthBloc>().state;
            double? targetLat = savedLat;
            double? targetLng = savedLng;
            String? targetAddr = savedAddress;
            if (auth is AuthAuthenticated) {
              targetLat ??= auth.user.latitude;
              targetLng ??= auth.user.longitude;
              targetAddr ??= auth.user.address;
            }
            targetLat ??= _currentPosition?.latitude;
            targetLng ??= _currentPosition?.longitude;
            targetAddr ??= _currentAddress;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfessionalSearchPage(
                  initialProfessionals: _currentProfessionals,
                  latitude: targetLat,
                  longitude: targetLng,
                  currentAddress: targetAddr,
                  initialSelectedTagIds: selectedTagIds,
                  initialSelectedSubtagIds: selectedSubtagIds,
                  initialUrgencyMode: _isUrgencyMode,
                ),
              ),
            );
          },
        );
      },
    );

    // Resetear el flag al cerrar el sheet (por cualquier motivo)
    if (mounted) setState(() => _isOpeningFilter = false);
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );

    if (image == null || !context.mounted) return;

    final croppedPath = await ImageCropperHelper.cropImage(
      imagePath: image.path,
      isSquare: true,
    );
    if (croppedPath == null || !context.mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final currentUser = authState.user;

      try {
        final bytes = await File(croppedPath).readAsBytes();
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
                result.data?['updateProfile']?['user'] as Map<String, dynamic>;
            final updatedUserModel = UserModel.fromJson(userData);
            final updatedUser = UserMapper.toEntity(updatedUserModel);

            if (context.mounted) {
              context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
            }
          }
        } else {
          debugPrint('Error uploading avatar: ${result.exception.toString()}');
        }
      } catch (e) {
        debugPrint('Error preparing avatar: $e');
      }
    }
  }

  // Mock Professionals Data (Will be replaced by Bloc state)
  List<Professional> get _currentProfessionals {
    final state = context.watch<HomeBloc>().state;
    if (state is HomeLoaded) {
      final blockedIds = getIt<UgcSafetyService>().getBlockedUserIds();
      return state.professionals.where((p) => !blockedIds.contains(p.id)).toList();
    }
    return []; // Return empty or show loading if preferred
  }

  // Filtering Logic
  List<Professional> get _filteredProfessionals {
    var list = List<Professional>.from(_currentProfessionals);
    if (list.isEmpty) return [];
    if (_isUrgencyMode) {
      list = list.where((p) => p.acceptsUrgency).toList();
    }
    if (_selectedTagIndex == 0) {
      list.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_selectedTagIndex == 1) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      // Filtrado por etiqueta destacada de festividad
      final seasonalState = context.read<SeasonalThemeBloc>().state;
      final featuredTags = seasonalState.campaign?.featuredTags ?? [];
      final tagOffset = _selectedTagIndex - 2;
      if (tagOffset >= 0 && tagOffset < featuredTags.length) {
        final targetTagName = featuredTags[tagOffset].name.toLowerCase();
        list = list.where((p) {
          final matchesSpecialty = p.specialty.toLowerCase().contains(targetTagName);
          final matchesTags = p.tags.any((t) => t.toLowerCase().contains(targetTagName));
          return matchesSpecialty || matchesTags;
        }).toList();
      }
    }
    return list;
  }

  Widget _buildNotificationsSection() {
    if (_localNotifications.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final displayedCount = _showAllNotifications
        ? _localNotifications.length
        : (_localNotifications.length > 3 ? 3 : _localNotifications.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notificaciones',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await LocalNotificationService.clearAll();
                  _loadLocalNotifications();
                },
                child: Text(
                  'Limpiar todo',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedCount,
            itemBuilder: (context, index) {
              final notif = _localNotifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    context.read<NavigationBloc>().add(const TabChanged(1));
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    notif.body,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    onPressed: () async {
                      await LocalNotificationService.deleteNotification(
                        notif.id,
                      );
                      _loadLocalNotifications();
                    },
                  ),
                ),
              );
            },
          ),
          if (_localNotifications.length > 3)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllNotifications = !_showAllNotifications;
                  });
                },
                child: Text(
                  _showAllNotifications
                      ? 'Ver menos'
                      : 'Ver todas (${_localNotifications.length})',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLocalNotificationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notificaciones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await LocalNotificationService.clearAll();
                          await _loadLocalNotifications();
                          setSheetState(() {});
                        },
                        child: Text(
                          'Limpiar todo',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_localNotifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No tienes nuevas notificaciones',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _localNotifications.length,
                        itemBuilder: (context, index) {
                          final notif = _localNotifications[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).pop();
                                context.read<NavigationBloc>().add(
                                  const TabChanged(1),
                                );
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                notif.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                notif.body,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await LocalNotificationService.deleteNotification(
                                    notif.id,
                                  );
                                  await _loadLocalNotifications();
                                  setSheetState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final seasonalState = context.watch<SeasonalThemeBloc>().state;

    final featuredTagNames = seasonalState.campaign?.featuredTags.map((t) => t.name).toList() ?? [];
    final tags = [l10n.homeTagNear, l10n.homeTagTopRated, ...featuredTagNames];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        flexibleSpace: seasonalState.showGarlandTop
            ? const SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SeasonalTopGarland(
                    height: 28,
                    slot: GarlandSlot.top,
                  ),
                ),
              )
            : null,
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String name = 'User';
            if (state is AuthAuthenticated) {
              name = state.user.name;
            }

            final greetingPrefix = seasonalState.campaign?.copy.greetingPrefix;
            final displayGreeting = (greetingPrefix != null && greetingPrefix.isNotEmpty)
                ? '$greetingPrefix $name'
                : l10n.homeGreeting(name);

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
                        displayGreeting,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => AddressSelectionDialog.show(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                (state is AuthAuthenticated &&
                                        state.user.address != null &&
                                        state.user.address!.isNotEmpty)
                                    ? state.user.address!
                                    : _currentAddress,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Help & Tips Icon (WebView / Offline Fallback)
                GestureDetector(
                  onTap: () => HelpWebViewPage.show(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Color(0xFF0D2B45),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Notification Bell Icon (Interactive)
                GestureDetector(
                  onTap: _showLocalNotificationsBottomSheet,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF0D2B45),
                          size: 22,
                        ),
                        if (_localNotifications.isNotEmpty)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00FF7F),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Profile Picture (Interactive with Seasonal Badge)
                SeasonalLogoBadge(
                  badgeSize: 29,
                  offset: const Offset(6, -6),
                  child: GestureDetector(
                    onTap: () => _pickImage(context),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (seasonalState.hasActiveCampaign
                                  ? seasonalState.accentColor
                                  : AppColors.primary)
                              .withValues(alpha: 0.2),
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
                        child:
                            !(state is AuthAuthenticated &&
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
                ),
              ],
            );
          },
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            if (user.address != null && user.address!.isNotEmpty) {
              setState(() {
                _currentAddress = user.address!;
              });
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated &&
                authState.user.latitude != null &&
                authState.user.longitude != null) {
              context.read<HomeBloc>().add(
                FetchNearbyProfessionals(
                  latitude: authState.user.latitude!,
                  longitude: authState.user.longitude!,
                ),
              );
              return;
            }

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
              _loadFallbackLocation();
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
                    vertical: 1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Prominente y Botones para Publicar y Ver Solicitudes Abiertas
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

                          // Primero mostrar el filtro; al aplicar, navegar con filtros seleccionados
                          _openFilterThenSearch(
                            context,
                            savedAddress: savedAddress,
                            savedLat: savedLat,
                            savedLng: savedLng,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: _isUrgencyMode
                                  ? AppColors.urgency
                                  : (seasonalState.hasActiveCampaign
                                      ? seasonalState.searchBarBorderColor
                                      : AppColors.primary),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _isUrgencyMode
                                    ? AppColors.urgency.withValues(alpha: 0.2)
                                    : (seasonalState.hasActiveCampaign
                                        ? seasonalState.searchBarBorderColor.withValues(alpha: 0.15)
                                        : theme.shadowColor.withValues(alpha: 0.05)),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isUrgencyMode
                                    ? Icons.bolt_rounded
                                    : Icons.search_rounded,
                                color: _isUrgencyMode
                                    ? AppColors.urgency
                                    : (seasonalState.hasActiveCampaign
                                        ? seasonalState.searchBarBorderColor
                                        : AppColors.primary),
                                size: 26,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.homeSearchNeed,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                height: 24,
                                width: 1,
                                color: theme.dividerColor.withValues(alpha: 0.2),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isUrgencyMode = !_isUrgencyMode;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.homeUrgency,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _isUrgencyMode
                                            ? AppColors.urgency
                                            : theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: _isUrgencyMode,
                                        onChanged: (val) {
                                          setState(() {
                                            _isUrgencyMode = val;
                                          });
                                        },
                                        activeColor: Colors.white,
                                        activeTrackColor: AppColors.urgency,
                                        inactiveThumbColor:
                                            Colors.grey.shade400,
                                        inactiveTrackColor:
                                            Colors.grey.shade200,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: seasonalState.hasActiveCampaign
                                ? seasonalState.headerGradient
                                : const [Color(0xFF0D2B45), Color(0xFF163E63)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: (seasonalState.hasActiveCampaign
                                      ? seasonalState.secondaryColor
                                      : const Color(0xFF0D2B45))
                                  .withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              // Si hay imagen de banner cargada desde el backend, usarla como fondo del card
                              if (seasonalState.campaign?.visuals.bannerImageUrl != null &&
                                  seasonalState.campaign!.visuals.bannerImageUrl!.isNotEmpty) ...[
                                Positioned.fill(
                                  child: CachedNetworkImage(
                                    imageUrl: seasonalState.campaign!.visuals.bannerImageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const SizedBox.shrink(),
                                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withValues(alpha: 0.65),
                                          Colors.black.withValues(alpha: 0.28),
                                          Colors.black.withValues(alpha: 0.05),
                                        ],
                                        stops: const [0.0, 0.55, 1.0],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (seasonalState.hasActiveCampaign) ...[
                                const Positioned.fill(
                                  child: SeasonalParticlesOverlay(height: 150),
                                ),
                                if (seasonalState.showGarlandBottom)
                                  const Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: SeasonalTopGarland(
                                      height: 28,
                                      slot: GarlandSlot.bottom,
                                    ),
                                  ),
                              ],
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            seasonalState.hasActiveCampaign
                                                ? Icons.celebration_rounded
                                                : Icons.campaign_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (seasonalState.campaign?.copy.promoBannerTitle != null &&
                                                        seasonalState.campaign!.copy.promoBannerTitle!.isNotEmpty)
                                                    ? seasonalState.campaign!.copy.promoBannerTitle!
                                                    : l10n.homeBannerTitle,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                (seasonalState.campaign?.copy.promoBannerSubtitle != null &&
                                                        seasonalState.campaign!.copy.promoBannerSubtitle!.isNotEmpty)
                                                    ? seasonalState.campaign!.copy.promoBannerSubtitle!
                                                    : l10n.homeBannerSubTitle,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: seasonalState.hasActiveCampaign
                                                  ? seasonalState.accentColor
                                                  : AppColors.primary,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () async {
                                              final copy = seasonalState.campaign?.copy;
                                              if (seasonalState.hasActiveCampaign &&
                                                  copy?.promoBannerActionType == 'SEARCH_TAG' &&
                                                  copy?.promoBannerActionValue != null &&
                                                  copy!.promoBannerActionValue!.isNotEmpty) {
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
                                                    builder: (_) => ProfessionalSearchPage(
                                                      initialProfessionals: _filteredProfessionals,
                                                      latitude: savedLat ?? _currentPosition?.latitude,
                                                      longitude: savedLng ?? _currentPosition?.longitude,
                                                      currentAddress: savedAddress ?? _currentAddress,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              final res = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const CreatePublicJobPage(),
                                                ),
                                              );
                                              if (res == true && mounted) {
                                                context.read<NavigationBloc>().add(
                                                  const TabChanged(1),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.add_rounded,
                                              size: 18,
                                            ),
                                            label: Text(
                                              (seasonalState.campaign?.copy.promoBannerCtaText != null &&
                                                      seasonalState.campaign!.copy.promoBannerCtaText!.isNotEmpty)
                                                  ? seasonalState.campaign!.copy.promoBannerCtaText!
                                                  : l10n.homeBtnRequest,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {
                                              context.read<NavigationBloc>().add(
                                                const TabChanged(1),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.list_alt_rounded,
                                              size: 18,
                                            ),
                                            label: Text(
                                              l10n.homeBtnMyRequests,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildNotificationsSection(),
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
      ),
    );
  }
}
