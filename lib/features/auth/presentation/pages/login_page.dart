import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_event.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_cliente/core/config/shorebird_update_manager.dart';
import 'package:clanship_cliente/core/utils/lower_case_text_formatter.dart';
import 'package:clanship_cliente/features/dashboard/presentation/pages/main_page.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_bloc.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_event.dart';
import 'package:clanship_cliente/core/settings/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'package:clanship_cliente/features/auth/presentation/widgets/terms_and_eula_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainPage()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.loginInvalidCredentials)),
            );
          } else if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF0B6E4F),
              ),
            );
          } else if (state is PasswordResetFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: const Color(0xFFFF5252),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // Top-left soft decorative wave
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 160,
                child: CustomPaint(painter: TopWavePainter()),
              ),
              // Bottom-right deep blue decorative wave
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 160,
                child: CustomPaint(painter: BottomWavePainter()),
              ),
              // Main content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxHeight < 720;

                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8),
                                // Top Action Bar (Terms & EULA on Left, Language on Right)
                                _buildTopBar(context, l10n),
                                SizedBox(height: isCompact ? 10 : 16),

                                // Logotipo (Sección 1)
                                _buildLogoHeader(l10n, isCompact),
                                SizedBox(height: isCompact ? 12 : 18),

                                // Conceptos (Sección 2)
                                _buildConceptsRow(l10n, isCompact),
                                SizedBox(height: isCompact ? 14 : 22),

                                // Formulario de Inicio de Sesión
                                _buildLoginForm(theme, l10n, isCompact),
                                SizedBox(height: isCompact ? 14 : 20),

                                // Beneficios (Sección Inferior)
                                _buildBenefitsRow(l10n, isCompact),

                                // Footer ("¿No tienes una cuenta? Regístrate aquí")
                                const SizedBox(height: 70),
                                _buildFooter(l10n),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Terms & EULA Pill Button
        GestureDetector(
          onTap: () => TermsAndEulaDialog.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.gavel_rounded,
                  size: 16,
                  color: Color(0xFF0D2B45),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.authTermsAndEula,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D2B45),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Language Selector Dropdown
        _buildLanguageSelector(context),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final currentLocale = state.locale.languageCode;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentLocale,
              icon: const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.language_rounded,
                  size: 18,
                  color: Color(0xFF0D2B45),
                ),
              ),
              isDense: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D2B45),
              ),
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  context.read<SettingsBloc>().add(
                    UpdateLocale(Locale(newLanguage)),
                  );
                }
              },
              items: const [
                DropdownMenuItem(value: 'es', child: Text('🇪🇸 Español')),
                DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                DropdownMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoHeader(AppLocalizations l10n, bool isCompact) {
    final double logoSize = isCompact ? 68 : 78;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset('assets/icon/app_icon.jpg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Clanship',
          style: TextStyle(
            fontFamily: 'RymanEco',
            fontSize: isCompact ? 32 : 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D2B45),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isCompact ? 12 : 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
            children: [
              TextSpan(
                text: l10n.loginTaglinePart1,
                style: const TextStyle(color: Color(0xFF0D2B45)),
              ),
              TextSpan(
                text: l10n.loginTaglinePart2,
                style: const TextStyle(color: Color(0xFFF28C28)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConceptsRow(AppLocalizations l10n, bool isCompact) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConceptColumn(
            'assets/icon/icons_ 0D2B45/shield-check.svg',
            l10n.loginConceptTrustTitle,
            l10n.loginConceptTrustSubtitle,
            const Color.fromARGB(255, 104, 173, 233),
            isCompact,
          ),
          _buildConceptColumn(
            'assets/icon/icons_ 0B6E4F/siren.svg',
            l10n.loginConceptSpeedTitle,
            l10n.loginConceptSpeedSubtitle,
            const Color(0xFF0B6E4F),
            isCompact,
          ),
          _buildConceptColumn(
            'assets/icon/icons_ F28C28/dialog.svg',
            l10n.loginConceptConnectionTitle,
            l10n.loginConceptConnectionSubtitle,
            const Color(0xFFF28C28),
            isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildConceptColumn(
    String svgAsset,
    String title,
    String subtitle,
    Color accentColor,
    bool isCompact,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              svgAsset,
              width: isCompact ? 21 : 24,
              height: isCompact ? 21 : 24,
              colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3135),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF2E3135),
              height: 1.18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(
    ThemeData theme,
    AppLocalizations l10n,
    bool isCompact,
  ) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          inputFormatters: [LowerCaseTextFormatter()],
          style: const TextStyle(fontSize: 14.5),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isCompact ? 12 : 14,
            ),
            labelText: l10n.loginEmailLabel,
            labelStyle: const TextStyle(fontSize: 13.5),
            prefixIcon: const Icon(Icons.mail_outline, size: 20),
          ),
        ),
        SizedBox(height: isCompact ? 10 : 14),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 14.5),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isCompact ? 12 : 14,
            ),
            labelText: l10n.loginPasswordLabel,
            labelStyle: const TextStyle(fontSize: 13.5),
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage(),
                ),
              );
            },
            child: Text(
              l10n.authForgotPassword,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 71, 169, 255),
              ),
            ),
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        SizedBox(
          width: double.infinity,
          height: isCompact ? 48 : 52,
          child: ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                LoginRequested(
                  _emailController.text.trim().toLowerCase(),
                  _passwordController.text,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D2B45),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.loginSignInButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsRow(AppLocalizations l10n, bool isCompact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBenefitItem(
          'assets/icon/icons_ 0B6E4F/shield-check.svg',
          l10n.loginBenefitVerified,
          const Color(0xFF0B6E4F),
          isCompact,
        ),
        _buildBenefitItem(
          'assets/icon/icons_ F28C28/star.svg',
          l10n.loginBenefitRatings,
          const Color(0xFFF28C28),
          isCompact,
        ),
        _buildBenefitItem(
          'assets/icon/icons_ 0B6E4F/map-point.svg',
          l10n.loginBenefitTracking,
          const Color(0xFF0B6E4F),
          isCompact,
        ),
      ],
    );
  }

  Widget _buildBenefitItem(
    String svgAsset,
    String text,
    Color color,
    bool isCompact,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgAsset,
          width: isCompact ? 20 : 22,
          height: isCompact ? 20 : 22,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: isCompact ? 9 : 9.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E3135),
            height: 1.15,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authNoAccount,
          style: const TextStyle(
            color: Color(0xFF2E3135),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.authRegisterHere,
                style: const TextStyle(
                  color: Color(0xFF0D2B45),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF0D2B45),
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // BOTÓN TEMPORAL DE PRUEBA SHOREBIRD
        TextButton.icon(
          icon: const Icon(Icons.bug_report, size: 16),
          label: const Text('PROBAR POPUP SHOREBIRD'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            ShorebirdUpdateManager.showTestUpdateDialog(context);
          },
        ),
      ],
    );
  }
}

// Background Wave Painters
class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D2B45).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.4, 0)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.4,
        0,
        size.height * 0.6,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
