import 'package:flutter/material.dart';
import 'package:clanship_cliente/core/utils/currency_formatter.dart';
import 'package:clanship_cliente/features/chat/presentation/pages/chat_page.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/pages/document_viewer_page.dart';

class ProposalDetailPage extends StatelessWidget {
  final Map<String, dynamic> request;
  final Map<String, dynamic> proposal;
  final Function(int, String) onAccept;

  const ProposalDetailPage({
    super.key,
    required this.request,
    required this.proposal,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final profName = proposal['professionalName'] ?? 'Profesional';
    final rating = proposal['professionalRating']?.toString() ?? '0.0';
    final price = proposal['estimatedPrice'] ?? '0';
    final propStatus = proposal['status']?.toString();
    final reqStatus = request['status']?.toString() ?? 'OPEN';
    final pId = int.tryParse(proposal['id'].toString()) ?? 0;
    
    final attachments = proposal['attachments'] as List? ?? [];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cotización'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PERFIL DEL PROFESIONAL
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: proposal['professionalAvatarUrl'] != null 
                      ? NetworkImage(proposal['professionalAvatarUrl']) 
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: proposal['professionalAvatarUrl'] == null
                      ? const Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // PRECIO Y FECHA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Precio Total:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text(
                        formatCurrency(price),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blueGrey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Fecha propuesta: ${proposal['scheduledDate']}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blueGrey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Hora propuesta: ${proposal['scheduledTime']}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // MENSAJE / CONDICIONES
            if (proposal['message'] != null && proposal['message'].toString().isNotEmpty) ...[
              const Text('Mensaje y Condiciones:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  proposal['message'],
                  style: TextStyle(fontSize: 15, height: 1.5, color: Colors.blue.shade900),
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            // ADJUNTOS
            if (attachments.isNotEmpty) ...[
              const Text('Archivos Adjuntos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: attachments.map((att) {
                  final fileType = (att['fileType'] ?? '').toString().toLowerCase();
                  final rawUrl = (att['file'] ?? '').toString().trim();
                  String fullUrl = rawUrl;
                  if (fullUrl.isNotEmpty && !fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
                    if (fullUrl.startsWith('/media/')) {
                      fullUrl = 'https://api.clanship.cl$fullUrl';
                    } else if (fullUrl.startsWith('media/')) {
                      fullUrl = 'https://api.clanship.cl/$fullUrl';
                    } else if (fullUrl.startsWith('/')) {
                      fullUrl = 'https://api.clanship.cl/media$fullUrl';
                    } else {
                      fullUrl = 'https://api.clanship.cl/media/$fullUrl';
                    }
                  }
                  final isImage = fileType.contains('image') ||
                      fullUrl.toLowerCase().endsWith('.jpg') ||
                      fullUrl.toLowerCase().endsWith('.png') ||
                      fullUrl.toLowerCase().endsWith('.jpeg') ||
                      fullUrl.toLowerCase().endsWith('.webp');
                  final isPdf = fileType.contains('pdf') || fullUrl.toLowerCase().endsWith('.pdf');
                  final fileName = (att['fileName'] != null && att['fileName'].toString().isNotEmpty)
                      ? att['fileName'].toString()
                      : (isPdf ? 'Documento PDF' : (isImage ? 'Imagen Adjunta' : 'Archivo Adjunto'));
                  
                  return GestureDetector(
                    onTap: () {
                      if (fullUrl.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentViewerPage(
                              url: fullUrl,
                              title: fileName,
                              isPdf: !isImage,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isImage
                            ? Image.network(
                                fullUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                                    color: isPdf ? Colors.redAccent : Colors.blueGrey,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isPdf ? 'Ver PDF' : 'Ver Documento',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
      bottomNavigationBar: reqStatus == 'OPEN' && propStatus == 'PENDING' 
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final profId = proposal['professional']?['id']?.toString() ?? '';
                          if (profId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  professional: Professional(
                                    id: profId,
                                    name: profName,
                                    specialty: request['specialtyName'] ?? '',
                                    rating: double.tryParse(rating) ?? 0.0,
                                    distance: 0.0,
                                    imageUrl: proposal['professionalAvatarUrl'] ?? '',
                                    pricePerHour: 0.0,
                                    description: '',
                                    latitude: 0.0,
                                    longitude: 0.0,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Hablar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close detail page
                          onAccept(pId, profName); // Trigger accept from parent
                        },
                        child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : propStatus == 'ACCEPTED' 
              ? SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.green.shade50,
                    child: const Text(
                      '✅ Esta cotización fue aceptada',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                )
              : null,
    );
  }
}
