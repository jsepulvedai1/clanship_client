import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentViewerPage extends StatefulWidget {
  final String url;
  final String title;
  final bool isPdf;

  const DocumentViewerPage({
    super.key,
    required this.url,
    required this.title,
    required this.isPdf,
  });

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Descargar o Compartir',
            onPressed: () async {
              try {
                final uri = Uri.parse(widget.url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo abrir externamente: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: widget.isPdf
          ? SfPdfViewer.network(widget.url)
          : Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  widget.url,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Error al cargar la imagen. Es posible que el enlace haya expirado.'),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
