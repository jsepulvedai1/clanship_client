import 'dart:io';
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_bloc.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_event.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_state.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/pages/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_cliente/core/utils/image_cropper_helper.dart';
import 'personal_info_page.dart';
import 'support_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/features/auth/data/models/user_model.dart';
import 'package:clanship_cliente/features/auth/data/mappers/user_mapper.dart';
import 'package:clanship_cliente/features/auth/presentation/widgets/terms_and_eula_dialog.dart';
import 'package:clanship_cliente/core/services/ugc_safety_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAvatarLoading = false;
  String _appVersion = '1.0.3';
  String _buildNumber = '7';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
          _buildNumber = info.buildNumber;
        });
      }
    } catch (_) {}
  }

  /// Picks a new avatar from gallery, encodes to base64, and uploads to the backend.
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    if (image == null || !mounted) return;

    final croppedPath = await ImageCropperHelper.cropImage(
      imagePath: image.path,
      isSquare: true,
    );
    if (croppedPath == null || !mounted) return;

    setState(() {
      _isAvatarLoading = true;
    });

    try {
      final bytes = await File(croppedPath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final currentUser = authState.user;

        String firstName = currentUser.firstName ?? '';
        String lastName = currentUser.lastName ?? '';
        if (firstName.isEmpty && currentUser.name.isNotEmpty) {
          final parts = currentUser.name.trim().split(' ');
          firstName = parts.first;
          if (parts.length > 1) {
            lastName = parts.sublist(1).join(' ');
          }
        }
        if (firstName.isEmpty) firstName = 'Usuario';

        const String updateProfileMutation = r'''
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
                avatarUrl
              }
            }
          }
        ''';

        final client = getIt<GraphQLClient>();
        final MutationOptions options = MutationOptions(
          document: gql(updateProfileMutation),
          variables: {
            'firstName': firstName,
            'lastName': lastName,
            'email': currentUser.email,
            'avatarBase64': base64Image,
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

          if (mounted) {
            context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil actualizada con éxito'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          throw Exception('Error al subir la foto al servidor');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lo sentimos, no se pudo subir la foto. Por favor, intenta de nuevo.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAvatarLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final currentLocale = state.locale;
        final theme = Theme.of(context);

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          },
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,

              title: Text(
                l10n.settingsTitle,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(theme, context),
                  const SizedBox(height: 32),

                  _SettingsSection(
                    title: 'Cuenta',
                    items: [
                      _SettingsItem(
                        icon: Icons.person_outline_rounded,
                        title: l10n.settingsPersonalInfo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalInfoPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  _SettingsSection(
                    title: 'Preferencias',
                    items: [
                      // _SettingsItem(
                      //   icon: Icons.verified_user_outlined,
                      //   title: l10n.settingsVerificationStatus,
                      //   onTap: () {},
                      // ),
                      _SettingsItem(
                        icon: Icons.language_rounded,
                        title: l10n.settingsChooseLanguage,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentLocale.languageCode == 'es'
                                  ? 'Español'
                                  : 'English',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.24,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showLanguagePicker(
                          context,
                          currentLocale,
                          theme,
                          l10n,
                        ),
                      ),
                      // _SettingsItem(
                      //   icon: Icons.dark_mode_outlined,
                      //   title: l10n.settingsDarkMode,
                      //   trailing: Switch(
                      //     value: theme.brightness == Brightness.dark,
                      //     onChanged: (val) {
                      //       context.read<SettingsBloc>().add(
                      //         UpdateTheme(
                      //           val ? ThemeMode.dark : ThemeMode.light,
                      //         ),
                      //       );
                      //     },
                      //     activeColor: AppColors.primary,
                      //   ),
                      // ),
                      _SettingsItem(
                        icon: Icons.replay_circle_filled_outlined,
                        title: "Repetir Tutorial",

                        onTap: () async {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is! AuthAuthenticated) return;

                          final userId = authState.user.id;
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('hasSeenHomeTutorial_$userId');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Iniciando tutorial...'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Navigate back to the home tab to trigger tutorial listener
                            context.read<NavigationBloc>().add(
                              const TabChanged(0),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  _SettingsSection(
                    title: 'Otros y Seguridad',
                    items: [
                      _SettingsItem(
                        icon: Icons.support_agent_rounded,
                        title: l10n.settingsSupport,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupportPage(),
                            ),
                          );
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.flag_outlined,
                        title: 'Reportar contenido o usuario',
                        onTap: () => _showReportContentDialog(context),
                      ),
                      _SettingsItem(
                        icon: Icons.block_rounded,
                        title: 'Usuarios bloqueados',
                        onTap: () => _showBlockedUsersDialog(context),
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline_rounded,
                        title: 'Versión de la app',
                        trailing: Text(
                          'v$_appVersion ($_buildNumber)',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.logout_rounded,
                        title: 'Cerrar sesión',
                        onTap: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.delete_forever_outlined,
                        title: 'Eliminar cuenta',
                        color: Colors.redAccent,
                        onTap: () => _showDeleteAccountDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () => TermsAndEulaDialog.show(context),
                    child: Text(
                      'Términos de Servicio (EULA) y Tolerancia Cero',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clanship v$_appVersion (Build $_buildNumber)',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ThemeData theme, BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String displayName = 'Usuario';
    String? email;
    String? avatarPath;

    if (authState is AuthAuthenticated) {
      final user = authState.user;
      avatarPath = user.avatarPath;
      email = user.email;
      if (user.firstName != null && user.firstName!.isNotEmpty) {
        displayName = '${user.firstName} ${user.lastName ?? ''}'.trim();
      } else {
        displayName = user.name;
      }
    }

    // Resolve the image provider: local file if set, else placeholder
    ImageProvider? avatarImage;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      if (avatarPath.startsWith('http://') ||
          avatarPath.startsWith('https://')) {
        avatarImage = NetworkImage(avatarPath);
      } else {
        avatarImage = FileImage(File(avatarPath));
      }
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _isAvatarLoading ? null : _pickAvatar,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: avatarImage != null
                        ? AppColors.primary
                        : const Color(0xFFE2E8F0),
                    width: avatarImage != null ? 3 : 2,
                  ),
                  image: avatarImage != null
                      ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                      : null,
                ),
                child: avatarImage == null && !_isAvatarLoading
                    ? const Center(
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 52,
                          color: Color(0xFFBCC5D0),
                        ),
                      )
                    : _isAvatarLoading
                    ? Container(
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : null,
              ),
              // Camera badge
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (email != null) ...[
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
            ),
          ),
        ],
      ],
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    Locale currentLocale,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.settingsChooseLanguage,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(
                  context: context,
                  label: l10n.settingsSpanish,
                  isSelected: currentLocale.languageCode == 'es',
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const UpdateLocale(Locale('es')),
                    );
                    Navigator.pop(context);
                  },
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context: context,
                  label: l10n.settingsEnglish,
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const UpdateLocale(Locale('en')),
                    );
                    Navigator.pop(context);
                  },
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context: context,
                  label: l10n.settingsFrench,
                  isSelected: currentLocale.languageCode == 'fr',
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const UpdateLocale(Locale('fr')),
                    );
                    Navigator.pop(context);
                  },
                  theme: theme,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Eliminar Cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta?\n\n'
          'Esta acción es permanente e irreversible. Se borrarán tus datos personales, solicitudes e historial según nuestras políticas de privacidad.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tu cuenta ha sido eliminada con éxito.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
  }

  void _showBlockedUsersDialog(BuildContext context) {
    final ugcService = getIt<UgcSafetyService>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final blockedMap = ugcService.getBlockedUsersDetails();
            final blockedEntries = blockedMap.entries.toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(
                        Icons.block_rounded,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Usuarios Bloqueados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estos usuarios no pueden enviarte mensajes, propuestas ni aparecerán en tus resultados de búsqueda.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Expanded(
                    child: blockedEntries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No tienes usuarios bloqueados',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: blockedEntries.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 16),
                            itemBuilder: (context, idx) {
                              final entry = blockedEntries[idx];
                              final uId = entry.key;
                              final uData = entry.value;
                              final name = uData['name'] ?? 'Usuario';
                              final reason = uData['reason'] ?? '';

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Colors.redAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.person_off_rounded,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: reason.isNotEmpty
                                    ? Text(
                                        reason,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    : null,
                                trailing: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                  ),
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    await ugcService.unblockUser(uId);
                                    setModalState(() {});
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Has desbloqueado a $name.',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  },
                                  child: const Text('Desbloquear'),
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

  void _showReportContentDialog(BuildContext context) {
    final TextEditingController detailController = TextEditingController();
    String selectedReason = 'Contenido inapropiado u ofensivo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reportar Contenido o Usuario',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el motivo del reporte para que nuestro equipo lo revise dentro de 24 horas:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    'Contenido inapropiado u ofensivo',
                    'Spam o perfil falso',
                    'Foto o imagen no permitida',
                    'Violación de derechos de autor',
                    'Otro motivo',
                  ].map(
                    (reason) => RadioListTile<String>(
                      title: Text(reason, style: const TextStyle(fontSize: 14)),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedReason = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Detalles adicionales (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        await getIt<UgcSafetyService>().reportContent(
                          targetId: 'GENERAL',
                          targetName: 'General/Settings',
                          reason: selectedReason,
                          details: detailController.text.trim(),
                          targetType: 'GENERAL_REPORT',
                        );
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Reporte enviado con éxito. Nuestro equipo revisará la información dentro de 24 horas y removerá el contenido si infringe las políticas.',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: const Text(
                        'Enviar Reporte',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (theme.brightness == Brightness.light)
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemColor = color ?? AppColors.primary;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: itemColor),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color ?? theme.colorScheme.onSurface,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: (color ?? theme.colorScheme.onSurface).withValues(
                  alpha: 0.24,
                ),
              ),
        ),
      ],
    );
  }
}
