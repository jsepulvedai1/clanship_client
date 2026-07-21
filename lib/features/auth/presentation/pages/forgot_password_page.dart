import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:clanship_cliente/core/config/env_config.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password, 4: Success
  bool _isLoading = false;
  String _errorMessage = '';

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _resetToken = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  /// Direct HTTP POST to the GraphQL endpoint, bypassing graphql_flutter entirely.
  Future<Map<String, dynamic>?> _graphqlPost(String query, Map<String, dynamic> variables) async {
    final url = Uri.parse(EnvConfig.instance.baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'variables': variables}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error del servidor: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body.containsKey('errors') && (body['errors'] as List).isNotEmpty) {
      final firstError = (body['errors'] as List).first;
      throw Exception(firstError['message'] ?? 'Error desconocido.');
    }
    return body['data'] as Map<String, dynamic>?;
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Por favor, ingresa tu correo electrónico.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _graphqlPost(
        r'''
          mutation RequestPasswordReset($email: String!) {
            requestPasswordReset(email: $email) {
              success
              message
            }
          }
        ''',
        {'email': email},
      );

      final success = data?['requestPasswordReset']?['success'] as bool? ?? false;
      final msg = data?['requestPasswordReset']?['message'] as String? ?? 'Código enviado.';

      if (success) {
        setState(() {
          _currentStep = 2;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: const Color(0xFF0B6E4F)),
          );
        }
      } else {
        _showError(msg);
      }
    } catch (e) {
      _showError('No se pudo conectar con el servidor. Verifica tu conexión.');
    }
  }

  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('Por favor, ingresa el código de 6 dígitos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _graphqlPost(
        r'''
          mutation VerifyPasswordResetOtp($email: String!, $otpCode: String!) {
            verifyPasswordResetOtp(email: $email, otpCode: $otpCode) {
              success
              message
              resetToken
            }
          }
        ''',
        {'email': email, 'otpCode': otp},
      );

      final success = data?['verifyPasswordResetOtp']?['success'] as bool? ?? false;
      final msg = data?['verifyPasswordResetOtp']?['message'] as String? ?? '';
      final token = data?['verifyPasswordResetOtp']?['resetToken'] as String? ?? '';

      if (success && token.isNotEmpty) {
        setState(() {
          _resetToken = token;
          _currentStep = 3;
          _isLoading = false;
        });
      } else {
        _showError(msg.isNotEmpty ? msg : 'El código no es válido.');
      }
    } catch (e) {
      _showError('No se pudo verificar el código. Inténtalo de nuevo.');
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _graphqlPost(
        r'''
          mutation ResetPasswordWithOtp($email: String!, $resetToken: String!, $newPassword: String!) {
            resetPasswordWithOtp(email: $email, resetToken: $resetToken, newPassword: $newPassword) {
              success
              message
            }
          }
        ''',
        {
          'email': email,
          'resetToken': _resetToken,
          'newPassword': password,
        },
      );

      final success = data?['resetPasswordWithOtp']?['success'] as bool? ?? false;
      final msg = data?['resetPasswordWithOtp']?['message'] as String? ?? '';

      if (success) {
        setState(() {
          _currentStep = 4;
          _isLoading = false;
        });
      } else {
        _showError(msg.isNotEmpty ? msg : 'Error al cambiar contraseña.');
      }
    } catch (e) {
      _showError('No se pudo actualizar la contraseña. Inténtalo de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep < 4
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0D2B45)),
                onPressed: () {
                  if (_currentStep > 1) {
                    setState(() {
                      _currentStep--;
                      _errorMessage = '';
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        title: Text(
          _currentStep == 4 ? 'Contraseña Restablecida' : 'Recuperar Contraseña',
          style: const TextStyle(
            color: Color(0xFF0D2B45),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentStep < 4) ...[
                Row(
                  children: List.generate(3, (index) {
                    final isActive = index + 1 <= _currentStep;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF0D2B45) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],

              if (_errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCCCC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFFF5252)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Color(0xFFFF5252), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_currentStep == 1) _buildEmailStep(),
              if (_currentStep == 2) _buildOtpStep(),
              if (_currentStep == 3) _buildPasswordStep(),
              if (_currentStep == 4) _buildSuccessStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Color(0xFF0D2B45),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tu correo electrónico y te enviaremos un código temporal de 6 dígitos para restablecer tu cuenta.',
          style: TextStyle(color: Color(0xFF2E3135), fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.mail_outline, size: 20),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2B45),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Text(
                  'Enviar código',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verificar código',
          style: TextStyle(
            color: Color(0xFF0D2B45),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hemos enviado un código de seguridad de 6 dígitos a ${_emailController.text}.',
          style: const TextStyle(color: Color(0xFF2E3135), fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0D2B45),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            labelText: 'Código de 6 dígitos',
            counterText: '',
            prefixIcon: Icon(Icons.lock_clock_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2B45),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Text(
                  'Verificar código',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _sendOtp,
            child: const Text(
              'Reenviar código',
              style: TextStyle(
                color: Color.fromARGB(255, 71, 169, 255),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nueva contraseña',
          style: TextStyle(
            color: Color(0xFF0D2B45),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Escribe una nueva contraseña para tu cuenta. Asegúrate de que tenga al menos 6 caracteres.',
          style: TextStyle(color: Color(0xFF2E3135), fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Contraseña nueva',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirmar contraseña',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2B45),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Text(
                  'Guardar contraseña',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEEFBF7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF0B6E4F),
              size: 80,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            '¡Contraseña Cambiada!',
            style: TextStyle(
              color: Color(0xFF0D2B45),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Tu contraseña ha sido restablecida con éxito. Ya puedes iniciar sesión con tu nueva contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF2E3135), fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2B45),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Volver al inicio',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
