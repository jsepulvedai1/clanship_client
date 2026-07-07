import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsMyDocs),
        centerTitle: true,
      ),
      body: const Center(
        child: Icon(Icons.folder_open_rounded, size: 100, color: AppColors.primary),
      ),
    );
  }
}
