import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:restart_app/restart_app.dart';

class ShorebirdUpdateManager {
  static final _shorebirdUpdater = ShorebirdUpdater();
  static bool _isChecking = false;

  /// Verifica si hay actualizaciones en Shorebird.
  /// Puedes llamar a este método desde el Splash, al reanudar la app,
  /// o cuando recibes un evento del backend.
  static Future<void> checkForUpdate(BuildContext context, {bool isMandatory = false}) async {
    if (_isChecking) return;
    
    try {
      _isChecking = true;
      final status = await _shorebirdUpdater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        if (isMandatory && context.mounted) {
          // Mostrar pop-up bloqueante
          _showUpdateDialog(context);
        } else {
          // Descarga silenciosa en segundo plano
          await _shorebirdUpdater.update();
        }
      }
    } catch (e) {
      debugPrint('Error checking for shorebird update: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Método exclusivo de desarrollo para ver cómo luce el diálogo.
  static void showTestUpdateDialog(BuildContext context) {
    _showUpdateDialog(context);
  }

  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDownloading = false;
        bool isReady = false;

        return StatefulBuilder(
          builder: (context, setState) {
            String title = 'Actualización Requerida';
            String subtitle =
                'Hemos lanzado mejoras importantes para la aplicación. ¡Por favor, actualiza para disfrutar de una mejor experiencia!';
            String buttonText = 'Descargar Ahora';
            IconData mainIcon = Icons.system_update_rounded;
            Color iconColor = const Color(0xFF0D2B45);

            if (isDownloading) {
              title = 'Descargando...';
              subtitle = 'Por favor espera mientras obtenemos la última versión.';
              buttonText = 'Descargando...';
              mainIcon = Icons.cloud_download_rounded;
              iconColor = Colors.blue;
            } else if (isReady) {
              title = '¡Todo Listo!';
              subtitle =
                  'La actualización se descargó correctamente. Reinicia la app para aplicar los cambios.';
              buttonText = 'Reiniciar Ahora';
              mainIcon = Icons.check_circle_rounded;
              iconColor = Colors.green;
            }

            return PopScope(
              canPop: false,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.white,
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ilustración superior
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: Icon(
                                mainIcon,
                                size: 55,
                                color: iconColor,
                              ),
                            ),
                            if (!isDownloading && !isReady) ...[
                              Positioned(
                                bottom: 15,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 15,
                                left: 10,
                                child: Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD54F), size: 18),
                              ),
                              const Positioned(
                                top: 35,
                                right: 5,
                                child: Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD54F), size: 28),
                              ),
                              const Positioned(
                                bottom: 25,
                                left: 15,
                                child: Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD54F), size: 14),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F), // Rojo vibrante como en la imagen
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isDownloading
                              ? null
                              : () async {
                                  if (isReady) {
                                    Restart.restartApp();
                                    return;
                                  }

                                  setState(() {
                                    isDownloading = true;
                                  });

                                  try {
                                    await _shorebirdUpdater.update();
                                    setState(() {
                                      isDownloading = false;
                                      isReady = true;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      isDownloading = false;
                                    });
                                  }
                                },
                          child: isDownloading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  buttonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
