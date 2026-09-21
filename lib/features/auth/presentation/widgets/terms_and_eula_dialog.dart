import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';

class TermsAndEulaDialog extends StatelessWidget {
  final VoidCallback? onAccept;
  final bool showAcceptButton;

  const TermsAndEulaDialog({
    super.key,
    this.onAccept,
    this.showAcceptButton = false,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onAccept,
    bool showAcceptButton = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TermsAndEulaDialog(
        onAccept: onAccept,
        showAcceptButton: showAcceptButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final title = l10n?.eulaTitle ?? 'Términos y Condiciones (EULA)';
    final subtitle =
        l10n?.eulaSubtitle ?? 'Acuerdo de Licencia de Usuario Final y Moderación';
    final zeroToleranceTitle =
        l10n?.eulaZeroToleranceTitle ?? 'POLÍTICA DE CERO TOLERANCIA';
    final zeroToleranceBody = l10n?.eulaZeroToleranceBody ??
        'Clanship mantiene una política estricta de CERO TOLERANCIA frente a contenido objetable, ofensivo, discriminatorio, abusivo, sexual o spam, así como hacia usuarios que cometan conductas abusivas.';
    final section1Title =
        l10n?.eulaSection1Title ?? '1. Acuerdo de Licencia de Usuario Final (EULA)';
    final section1Body = l10n?.eulaSection1Body ??
        'Al descargar, instalar, registrarte o usar la aplicación Clanship, aceptas quedar vinculado por los presentes Términos de Servicio y Acuerdo de Licencia (EULA). Si no estás de acuerdo con estos términos, no debes utilizar la aplicación.';
    final section2Title =
        l10n?.eulaSection2Title ?? '2. Normas de la Comunidad y Contenido Prohibido';
    final section2Intro = l10n?.eulaSection2Intro ??
        'Como usuario, te comprometes a no cargar, publicar, enviar ni compartir:';
    final section2Bullet1 = l10n?.eulaSection2Bullet1 ??
        'Contenido sexualmente explícito, pornográfico o violento.';
    final section2Bullet2 = l10n?.eulaSection2Bullet2 ??
        'Lenguaje de odio, acoso, difamación, amenazas o discriminación por cualquier motivo.';
    final section2Bullet3 = l10n?.eulaSection2Bullet3 ??
        'Información falsa, fraudulenta, estafas o suplantación de identidad.';
    final section2Bullet4 = l10n?.eulaSection2Bullet4 ??
        'Contenido que infrinja la propiedad intelectual o derechos de terceros.';
    final section3Title =
        l10n?.eulaSection3Title ?? '3. Herramientas de Reporte y Bloqueo';
    final section3Intro = l10n?.eulaSection3Intro ??
        'Para proteger a nuestra comunidad, Clanship proporciona herramientas accesibles en toda la plataforma:';
    final section3Bullet1 = l10n?.eulaSection3Bullet1 ??
        'Bloquear usuarios abusivos: Puedes bloquear a cualquier profesional o usuario inmediatamente desde el chat o su perfil. Al bloquearlo, su contenido y mensajes desaparecerán instantáneamente de tu vista.';
    final section3Bullet2 = l10n?.eulaSection3Bullet2 ??
        'Reportar contenido o usuarios: Puedes denunciar cualquier mensaje, foto o perfil con el botón de reporte.';
    final section3Bullet3 = l10n?.eulaSection3Bullet3 ??
        'Compromiso de moderación en 24 horas: Nuestro equipo revisa cada reporte dentro de 24 horas. Todo contenido objetable será eliminado y los usuarios infractores serán expulsados y sancionados permanentemente.';
    final section4Title =
        l10n?.eulaSection4Title ?? '4. Naturaleza del Servicio y Responsabilidad';
    final section4Body = l10n?.eulaSection4Body ??
        'Clanship opera como una plataforma tecnológica de vinculación que conecta clientes con profesionales técnicos independientes. Cada servicio se acuerda directamente entre las partes.';
    final section5Title =
        l10n?.eulaSection5Title ?? '5. Privacidad y Seguridad';
    final section5Body = l10n?.eulaSection5Body ??
        'Tus datos personales y ubicación se procesan conforme a nuestra Política de Privacidad únicamente para la prestación de los servicios solicitados y fines de seguridad.';
    final webLink =
        l10n?.eulaWebLink ?? 'Ver términos completos en el sitio web oficial';
    final acceptBtn =
        l10n?.eulaAcceptButton ?? 'Acepto los Términos y Política EULA';
    final closeBtn = l10n?.eulaCloseButton ?? 'Entendido y Cerrar';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zero tolerance banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFC0C0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          color: Color(0xFFD32F2F),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                zeroToleranceTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                zeroToleranceBody,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5D1010),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle(section1Title),
                  _buildParagraph(section1Body),

                  _buildSectionTitle(section2Title),
                  _buildParagraph(section2Intro),
                  _buildBulletPoint(section2Bullet1),
                  _buildBulletPoint(section2Bullet2),
                  _buildBulletPoint(section2Bullet3),
                  _buildBulletPoint(section2Bullet4),

                  _buildSectionTitle(section3Title),
                  _buildParagraph(section3Intro),
                  _buildBulletPoint(section3Bullet1),
                  _buildBulletPoint(section3Bullet2),
                  _buildBulletPoint(section3Bullet3),

                  _buildSectionTitle(section4Title),
                  _buildParagraph(section4Body),

                  _buildSectionTitle(section5Title),
                  _buildParagraph(section5Body),

                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse(
                            'https://clanship.cl/terminos-y-condiciones');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: Text(
                        webLink,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Action
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onAccept != null) {
                      onAccept!();
                    }
                  },
                  child: Text(
                    showAcceptButton ? acceptBtn : closeBtn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  static Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[800],
          height: 1.4,
        ),
      ),
    );
  }

  static Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
