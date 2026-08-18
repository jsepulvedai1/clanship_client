import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';

class HelpWebViewPage extends StatefulWidget {
  final String helpUrl;

  const HelpWebViewPage({
    super.key,
    this.helpUrl = 'https://clanship.cl/ayuda-app', // URL administrable de clanship_page
  });

  static void show(BuildContext context, {String? url}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: HelpWebViewPage(
          helpUrl: url ?? 'https://clanship.cl/ayuda-app',
        ),
      ),
    );
  }

  @override
  State<HelpWebViewPage> createState() => _HelpWebViewPageState();
}

class _HelpWebViewPageState extends State<HelpWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.slate50)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Se activa cuando no hay conexión a internet o falla la carga del sitio
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.helpUrl));
  }

  void _retryLoad() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(widget.helpUrl));
  }

  void _loadOfflineFallback() {
    final offlineHtml = '''
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Ayuda Clanship</title>
      <style>
        body {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
          background-color: #F8FAFC;
          color: #0D2B45;
          margin: 0;
          padding: 20px;
          line-height: 1.6;
        }
        .card {
          background: white;
          padding: 20px;
          border-radius: 12px;
          box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
          margin-bottom: 16px;
        }
        h2 { color: #0B6E4F; margin-top: 0; }
        .step { margin-bottom: 12px; }
        .badge {
          background: #F28C28;
          color: white;
          padding: 2px 8px;
          border-radius: 12px;
          font-size: 12px;
          font-weight: bold;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <h2>💡 Guía rápida de uso <span class="badge">Offline</span></h2>
        <p>Parece que no tienes conexión a internet en este momento. Te dejamos unos consejos básicos:</p>
      </div>

      <div class="card">
        <h3>🔍 1. Buscar Profesionales</h3>
        <p>Utiliza la barra de búsqueda o filtra por categorías en la pantalla principal para encontrar especialistas cerca de tu ubicación.</p>
      </div>

      <div class="card">
        <h3>📋 2. Crear una Solicitud</h3>
        <p>¿Tienes un trabajo específico? Haz clic en "Publicar Trabajo" en el menú inferior para que los profesionales te envíen sus cotizaciones.</p>
      </div>

      <div class="card">
        <h3>💬 3. Chat y Presupuestos</h3>
        <p>Conversa directamente con los profesionales seleccionados para acordar detalles, fechas y presupuestos de forma segura.</p>
      </div>
    </body>
    </html>
    ''';

    _controller.loadHtmlString(offlineHtml);
    setState(() {
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.accent, size: 22),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Centro de Ayuda y Consejos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _retryLoad,
              tooltip: 'Recargar',
            ),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(4.0),
                  child: LinearProgressIndicator(
                    value: _loadingProgress > 0 ? _loadingProgress / 100 : null,
                    backgroundColor: AppColors.secondary,
                    color: AppColors.accent,
                  ),
                )
              : null,
        ),
        body: _hasError
            ? _buildErrorView()
            : WebViewWidget(
                controller: _controller,
                gestureRecognizers: {
                  Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer(),
                  ),
                },
              ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin conexión a Internet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No pudimos cargar la guía interactiva en línea. Puedes intentar conectarte nuevamente o revisar la guía básica sin conexión.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _loadOfflineFallback,
                  icon: const Icon(Icons.import_contacts, size: 18),
                  label: const Text('Guía Offline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _retryLoad,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
