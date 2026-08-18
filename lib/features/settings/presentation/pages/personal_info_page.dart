import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/auth/domain/entities/user.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    User? currentUser;
    if (authState is AuthAuthenticated) {
      currentUser = authState.user;
    }

    String initialFirstName = currentUser?.firstName ?? '';
    String initialLastName = currentUser?.lastName ?? '';
    final String initialEmail = currentUser?.email ?? '';
    final String initialPhone = currentUser?.phoneNumber ?? '';
    final String initialAddress = currentUser?.address ?? '';

    if (initialFirstName.isEmpty && currentUser != null && currentUser.name.isNotEmpty) {
      final parts = currentUser.name.trim().split(' ');
      initialFirstName = parts.first;
      if (parts.length > 1) {
        initialLastName = parts.sublist(1).join(' ');
      }
    }

    _firstNameController = TextEditingController(text: initialFirstName);
    _lastNameController = TextEditingController(text: initialLastName);
    _emailController = TextEditingController(text: initialEmail);
    _phoneController = TextEditingController(text: initialPhone);
    _addressController = TextEditingController(text: initialAddress);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildReadOnlyField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    String? hintText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(prefixIcon, color: AppColors.primary),
            hintText: hintText,
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.04),
            suffixIcon: const Tooltip(
              message: 'Este campo no puede ser modificado',
              child: Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Información Personal',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Consulta tus datos personales registrados. Todos los campos están bloqueados por seguridad.',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            
            // Inputs Container Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                children: [
                  _buildReadOnlyField(
                    context: context,
                    label: 'Nombre',
                    controller: _firstNameController,
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 18),
                  _buildReadOnlyField(
                    context: context,
                    label: 'Apellido',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 18),
                  _buildReadOnlyField(
                    context: context,
                    label: 'Correo Electrónico',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 18),
                  _buildReadOnlyField(
                    context: context,
                    label: 'Número de Teléfono',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    hintText: 'No registrado',
                  ),
                  const SizedBox(height: 18),
                  _buildReadOnlyField(
                    context: context,
                    label: 'Dirección',
                    controller: _addressController,
                    prefixIcon: Icons.location_on_outlined,
                    hintText: 'No registrada',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Security Info Notice Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Tus datos personales no pueden ser editados directamente. Si necesitas cambiar algún dato, por favor contacta al equipo de soporte.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
