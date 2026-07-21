import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  // Support contact info
  static const String supportEmail = 'soporte@clanship.cl';
  static const String supportPhone = '+56912345678';
  static const String supportWhatsApp = '56912345678'; // WhatsApp phone format without '+' or special chars

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'Soporte Técnico - ClanShip',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw Exception('No se encontró una aplicación de correo instalada.');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el correo.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$supportWhatsApp?text=Hola,%20necesito%20soporte%20con%20ClanShip.');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('No se pudo abrir WhatsApp.');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir WhatsApp.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _launchCall(BuildContext context) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: supportPhone,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw Exception('No se puede realizar llamadas en este dispositivo.');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo realizar la llamada.'),
            backgroundColor: AppColors.error,
          ),
        );
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
          'Soporte',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Support Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Tienes problemas?',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contáctanos y te ayudaremos a solucionarlo a la brevedad.',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Icon(
                      Icons.headset_mic_rounded,
                      size: 80,
                      color: theme.colorScheme.onPrimary.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Options title
            Text(
              'Opciones de contacto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 30),
            
            // Correo Button
            _buildContactButton(
              context: context,
              icon: Icon(Icons.mail_outline_rounded, size: 22, color: theme.colorScheme.onPrimary),
              label: 'Correo',
              onTap: () => _launchEmail(context),
              theme: theme,
            ),
            const SizedBox(height: 20),
            
            // WhatsApp Button
            _buildContactButton(
              context: context,
              icon: FaIcon(FontAwesomeIcons.whatsapp, size: 22, color: theme.colorScheme.onPrimary),
              label: 'WhatsApp',
              onTap: () => _launchWhatsApp(context),
              theme: theme,
            ),
            const SizedBox(height: 20),
            
            // Llamar Button
            _buildContactButton(
              context: context,
              icon: Icon(Icons.phone_in_talk_rounded, size: 22, color: theme.colorScheme.onPrimary),
              label: 'Llamar',
              onTap: () => _launchCall(context),
              theme: theme,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: icon,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
