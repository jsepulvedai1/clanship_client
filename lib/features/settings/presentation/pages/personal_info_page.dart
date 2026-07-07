import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/auth/data/mappers/user_mapper.dart';
import 'package:clanship_cliente/features/auth/data/models/user_model.dart';
import 'package:clanship_cliente/features/auth/domain/entities/user.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Get current user details from AuthBloc
    final authState = context.read<AuthBloc>().state;
    User? currentUser;
    if (authState is AuthAuthenticated) {
      currentUser = authState.user;
    }

    String initialFirstName = currentUser?.firstName ?? '';
    String initialLastName = currentUser?.lastName ?? '';
    final String initialEmail = currentUser?.email ?? '';
    final String initialPhone = currentUser?.phoneNumber ?? '';

    // Smart fallback if first/last name are empty but full name is set
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
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    const String updateProfileMutation = r'''
      mutation UpdateProfile($firstName: String!, $lastName: String!, $email: String!, $phoneNumber: String) {
        updateProfile(firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber) {
          success
          user {
            id
            username
            email
            phoneNumber
            firstName
            lastName
          }
        }
      }
    ''';

    try {
      final client = getIt<GraphQLClient>();
      final MutationOptions options = MutationOptions(
        document: gql(updateProfileMutation),
        variables: {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final success = result.data?['updateProfile']?['success'] as bool? ?? false;
      if (success) {
        final userData = result.data?['updateProfile']?['user'] as Map<String, dynamic>;
        final updatedUserModel = UserModel.fromJson(userData);
        final updatedUser = UserMapper.toEntity(updatedUserModel);

        if (mounted) {
          // Update the user state globally in BLoC
          context.read<AuthBloc>().add(ProfileUpdated(updatedUser));
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Información personal actualizada con éxito'),
              backgroundColor: AppColors.success,
            ),
          );
          
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Error al actualizar el perfil en el servidor');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onSurface),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Mantén tus datos actualizados para que los profesionales de ClanShip puedan contactarte fácilmente.',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.54),
                ),
              ),
              const SizedBox(height: 30),
              
              // Inputs Container Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (theme.brightness == Brightness.light)
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    // Nombre
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Apellido
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Correo electrónico
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu correo electrónico';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Ingresa un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Teléfono
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Número de Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '+56 9 1234 5678',
                      ),
                      validator: (value) {
                        // Phone is optional but if entered, should be valid length
                        if (value != null && value.trim().isNotEmpty && value.trim().length < 8) {
                          return 'Ingresa un número de teléfono válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                        ),
                      )
                    : Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
