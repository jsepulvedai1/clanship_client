import 'dart:io';
import 'dart:convert';
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAvatarLoading = false;

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
            content: Text('Lo sentimos, no se pudo subir la foto. Por favor, intenta de nuevo.'),
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
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.24,
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
                      _SettingsItem(
                        icon: Icons.dark_mode_outlined,
                        title: l10n.settingsDarkMode,
                        trailing: Switch(
                          value: theme.brightness == Brightness.dark,
                          onChanged: (val) {
                            context.read<SettingsBloc>().add(
                              UpdateTheme(
                                val ? ThemeMode.dark : ThemeMode.light,
                              ),
                            );
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  _SettingsSection(
                    title: 'Otros',
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
                        icon: Icons.logout_rounded,
                        title: 'Cerrar sesión',
                        onTap: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      l10n.settingsTerms,
                      style: const TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                  border: Border.all(color: avatarImage != null ? AppColors.primary : const Color(0xFFE2E8F0), width: avatarImage != null ? 3 : 2),
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
                  decoration: const BoxDecoration(
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
              color: theme.colorScheme.onSurface.withOpacity(0.54),
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
                const SizedBox(height: 16),
              ],
            ),
          ),
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
              ? AppColors.primary.withOpacity(0.05)
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
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
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
              color: theme.colorScheme.onSurface.withOpacity(0.38),
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
                  color: theme.shadowColor.withOpacity(0.05),
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

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.24),
              ),
        ),
      ],
    );
  }
}
