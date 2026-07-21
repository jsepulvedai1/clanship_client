import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_cliente/features/dashboard/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:clanship_cliente/features/auth/presentation/widgets/address_picker_page.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_cliente/core/utils/image_cropper_helper.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  String? _avatarPath;

  // Step 0 Controllers (Datos Personales)
  final _emailController = TextEditingController();
  final _repeatEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthdateController = TextEditingController();

  // Password visibility states
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  // Step 1 Controllers (Dirección y Contacto)
  final _addressController = TextEditingController();
  double? _latitude;
  double? _longitude;
  final _phoneController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _repeatEmailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthdateController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _openAddressPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddressPickerPage(initialAddress: _addressController.text),
      ),
    );

    if (result != null) {
      setState(() {
        _addressController.text = result['address'] ?? '';
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  // Date Picker for Birthdate
  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime eighteenYearsAgo = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D2B45),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E3135),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Step 0 Validation
  bool _validateStep0() {
    final email = _emailController.text.trim();
    final repeatEmail = _repeatEmailController.text.trim();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final birthdate = _birthdateController.text;

    if (email.isEmpty ||
        repeatEmail.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        birthdate.isEmpty) {
      _showError('Por favor completa todos los campos.');
      return false;
    }

    if (firstName.length > 30) {
      _showError('El nombre no puede superar los 30 caracteres.');
      return false;
    }

    if (lastName.length > 30) {
      _showError('El apellido no puede superar los 30 caracteres.');
      return false;
    }

    if (email != repeatEmail) {
      _showError('Los correos electrónicos no coinciden.');
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError('Por favor ingresa un correo electrónico válido.');
      return false;
    }

    if (password.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }

    if (password != repeatPassword) {
      _showError('Las contraseñas no coinciden.');
      return false;
    }

    return true;
  }

  // Step 1 Validation
  bool _isStep1FormValid() {
    final phone = _phoneController.text.trim();
    return _addressController.text.trim().isNotEmpty &&
        phone.length == 8 &&
        RegExp(r'^[0-9]{8}$').hasMatch(phone) &&
        _acceptedTerms &&
        _avatarPath != null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF5252),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Save the registered address to saved_user_addresses in SharedPreferences
            if (state.user.address != null && state.user.address!.isNotEmpty) {
              try {
                final prefs = getIt<SharedPreferences>();
                final String? jsonStr = prefs.getString('saved_user_addresses');
                List<Map<String, dynamic>> saved = [];
                if (jsonStr != null) {
                  final List<dynamic> decoded = json.decode(jsonStr);
                  saved = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
                }
                
                final bool exists = saved.any((element) => element['address'] == state.user.address);
                if (!exists) {
                  saved.add({
                    'name': 'Hogar',
                    'address': state.user.address,
                    'latitude': state.user.latitude ?? 0.0,
                    'longitude': state.user.longitude ?? 0.0,
                  });
                  prefs.setString('saved_user_addresses', json.encode(saved));
                }
              } catch (_) {}
            }

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainPage()),
              (route) => false,
            );
          } else if (state is AuthFailure) {
            _showError(state.errorMessage);
          }
        },
        child: Stack(
          children: [
            // Bottom-right decorative wave
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: CustomPaint(painter: BottomWavePainter()),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Page indicator dots & Header
                  _buildHeader(),
                  // Form view
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (page) {
                        setState(() {
                          _currentStep = page;
                        });
                      },
                      children: [
                        _buildStep0(), // Correo, Contraseña, Nombre, Fecha Nacimiento
                        _buildStep1(), // Dirección, Teléfono, Términos
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Color(0xFF0D2B45),
            ),
            onPressed: () {
              if (_currentStep == 0) {
                Navigator.of(context).pop();
              } else {
                _previousPage();
              }
            },
          ),
          // Page indicator dots
          Row(
            children: List.generate(2, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentStep == index
                      ? const Color(0xFF0D2B45)
                      : const Color(0xFF2E3135).withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset('assets/icon/app_icon.jpg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 1),
        const Text(
          'Registro',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D2B45),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Crea tu cuenta para comenzar',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3135),
          ),
        ),
      ],
    );
  }

  // STEP 0: DATOS PERSONALES
  Widget _buildStep0() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogoHeader(),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _emailController,
            hint: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _repeatEmailController,
            hint: 'Repite el correo',
            keyboardType: TextInputType.emailAddress,
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _passwordController,
            hint: 'Contraseña',
            obscureText: _obscurePassword,
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _repeatPasswordController,
            hint: 'Repite la contraseña',
            obscureText: _obscureRepeatPassword,
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRepeatPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureRepeatPassword = !_obscureRepeatPassword;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _firstNameController,
            hint: 'Nombre',
            keyboardType: TextInputType.name,
            icon: Icons.person_outline,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _lastNameController,
            hint: 'Apellido',
            keyboardType: TextInputType.name,
            icon: Icons.person_outline,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectBirthdate(context),
            child: AbsorbPointer(
              child: _buildTextField(
                controller: _birthdateController,
                hint: 'Fecha de Nacimiento',
                icon: Icons.calendar_month_outlined,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Siguiente Button
          SizedBox(
            width: 280,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_validateStep0()) {
                  _nextPage();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2B45),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Siguiente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'o regístrate con',
            style: TextStyle(
              color: Color(0xFF2E3135),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(
                FontAwesomeIcons.google,
                const Color(0xFFEA4335),
                () {
                  _showError('Registro con Google en desarrollo.');
                },
              ),
              const SizedBox(width: 24),
              _buildSocialIcon(FontAwesomeIcons.apple, Colors.black, () {
                _showError('Registro con Apple en desarrollo.');
              }),
            ],
          ),
          const SizedBox(height: 12),
          // Footer terms row with dialog.svg
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icon/icons_ F28C28/dialog.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0B6E4F),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Al registrarte aceptas nuestros\nTérminos y Condiciones y Política de Privacidad',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B6E4F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1: UBICACIÓN Y CONTACTO
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );

    if (image == null) return;

    final croppedPath = await ImageCropperHelper.cropImage(
      imagePath: image.path,
      isSquare: true,
    );
    if (croppedPath == null) return;

    setState(() {
      _avatarPath = croppedPath;
    });
  }

  Widget _buildStep1() {
    final bool isValid = _isStep1FormValid();

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Ubicación y Contacto',
            style: TextStyle(
              color: Color(0xFF0D2B45),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Completa tus datos de contacto para continuar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF2E3135), fontSize: 14),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF0D2B45).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _avatarPath != null
                        ? Image.file(
                            File(_avatarPath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 40,
                            color: Color(0xFFBCC5D0),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0D2B45),
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
          const Text(
            'Foto de perfil (Requerida)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3135),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _openAddressPicker,
            child: AbsorbPointer(
              child: _buildTextField(
                controller: _addressController,
                hint: 'Mi dirección',
                keyboardType: TextInputType.streetAddress,
                icon: Icons.location_on_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _showTermsDialog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (val) {
                    setState(() {
                      _acceptedTerms = val ?? false;
                    });
                  },
                  activeColor: const Color(0xFF0D2B45),
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF2E3135), width: 1.5),
                ),
                const Flexible(
                  child: Text(
                    'Lee los términos y condiciones de uso',
                    style: TextStyle(
                      color: Color(0xFF0D2B45),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const CircularProgressIndicator(
                  color: Color(0xFF0D2B45),
                );
              }

              return SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  onPressed: isValid
                      ? () {
                          context.read<AuthBloc>().add(
                            RegisterRequested(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              birthdate: _birthdateController.text,
                              address: _addressController.text.trim(),
                              phoneNumber:
                                  '+569${_phoneController.text.trim()}',
                              avatarPath: _avatarPath,
                              latitude: _latitude,
                              longitude: _longitude,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2B45),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF0D2B45,
                    ).withValues(alpha: 0.3),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.6,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Registrarme',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // HELPER WIDGETS
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14),
        cursorColor: const Color(0xFF0D2B45),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(
            color: const Color(0xFF2E3135).withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                  size: 20,
                )
              : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D2B45), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        maxLength: 8,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14),
        cursorColor: const Color(0xFF0D2B45),
        decoration: InputDecoration(
          labelText: 'Número de teléfono',
          labelStyle: TextStyle(
            color: const Color(0xFF2E3135).withValues(alpha: 0.6),
            fontSize: 14,
          ),
          counterText: '',
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.phone_outlined,
                color: const Color(0xFF2E3135).withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '+569',
                style: TextStyle(
                  color: Color(0xFF0D2B45),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFE2E8F0),
              ),
            ],
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D2B45), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: FaIcon(icon, color: color, size: 22),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Términos y Condiciones',
            style: TextStyle(
              color: Color(0xFF0D2B45),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Bienvenido a ClanShip. Al registrarte y utilizar nuestra plataforma de vinculación laboral y servicios técnicos a domicilio, aceptas cumplir los siguientes términos y condiciones:\n\n'
              '1. Uso del Servicio: ClanShip es un intermediario que conecta profesionales con clientes. No nos hacemos responsables de las disputas contractuales o de la calidad del servicio realizado por los maestros independientes.\n\n'
              '2. Registro y Privacidad: Garantizas que toda la información entregada es verídica y que cuentas con la mayoría de edad para contratar servicios.\n\n'
              '3. Cancelaciones y Tarifas: Las tarifas son pactadas directamente entre cliente y profesional, o bien calculadas por el sistema según disponibilidad de viaje.\n\n'
              'Al presionar "Aceptar", declaras conocer y aprobar estos términos de uso.',
              style: TextStyle(color: Color(0xFF2E3135)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     setState(() {
            //       _acceptedTerms = true;
            //     });
            //     Navigator.pop(context);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xFF0D2B45),
            //     foregroundColor: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: const Text('Aceptar'),
            // ),
          ],
        );
      },
    );
  }
}

// Background Wave Painter
class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D2B45)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.5, size.height)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.6,
        size.width,
        size.height * 0.4,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
