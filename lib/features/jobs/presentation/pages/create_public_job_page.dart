import 'dart:convert';
import 'dart:io';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:clanship_cliente/core/network/location_service.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_cliente/features/auth/presentation/widgets/address_picker_page.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:clanship_cliente/l10n/app_localizations.dart';

class CreatePublicJobPage extends StatefulWidget {

  const CreatePublicJobPage({super.key});

  @override
  State<CreatePublicJobPage> createState() => _CreatePublicJobPageState();
}

class _CreatePublicJobPageState extends State<CreatePublicJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();
  final _customSpecialtyController = TextEditingController();

  int? _selectedSpecialtyId;
  String _selectedSpecialtyName = 'Seleccionar especialidad...';
  bool _isCustomSpecialty = false;
  bool _isUrgent = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _specialties = [];
  bool _loadingSpecialties = true;

  DateTime? _desiredDate;
  final List<File> _selectedPhotos = [];

  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _initUserAddressAndLocation();
    _loadSpecialties();
  }

  void _initUserAddressAndLocation() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.address != null && authState.user.address!.isNotEmpty) {
        _addressController.text = authState.user.address!;
      }
      _latitude = authState.user.latitude;
      _longitude = authState.user.longitude;
    }

    if (_latitude == null || _longitude == null) {
      try {
        final loc = getIt<LocationService>();
        final pos = await loc.getCurrentPosition();
        if (mounted) {
          setState(() {
            _latitude = pos.latitude;
            _longitude = pos.longitude;
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _openAddressPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressPickerPage(initialAddress: _addressController.text),
      ),
    );

    if (result != null) {
      setState(() {
        _addressController.text = result['address'] ?? '';
        if (result['latitude'] != null) {
          _latitude = (result['latitude'] as num).toDouble();
        }
        if (result['longitude'] != null) {
          _longitude = (result['longitude'] as num).toDouble();
        }
      });
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_selectedPhotos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 4 fotos por solicitud.')),
      );
      return;
    }
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 75,
      );
      if (image != null) {
        setState(() {
          _selectedPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Elegir de Galería'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    _customSpecialtyController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialties() async {
    try {
      final gqlService = getIt<GraphQLService>();
      const String query = r'''
        query Specialties {
          specialties {
            id
            name
            iconUrl
          }
        }
      ''';
      final res = await gqlService.client.query(
        QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly),
      );
      if (!res.hasException && res.data?['specialties'] != null) {
        final List list = res.data!['specialties'];
        final parsed = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (mounted) {
          setState(() {
            _specialties = parsed;
            if (_specialties.isNotEmpty) {
              _selectedSpecialtyId = int.tryParse(_specialties.first['id'].toString());
              _selectedSpecialtyName = _specialties.first['name'] ?? 'Seleccionar especialidad...';
              _isCustomSpecialty = false;
            } else {
              _isCustomSpecialty = true;
              _selectedSpecialtyName = '✏️ Otra (Personalizada)';
            }
            _loadingSpecialties = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingSpecialties = false;
            _isCustomSpecialty = true;
            _selectedSpecialtyName = '✏️ Otra (Personalizada)';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingSpecialties = false;
          _isCustomSpecialty = true;
          _selectedSpecialtyName = '✏️ Otra (Personalizada)';
        });
      }
    }
  }

  void _showSpecialtySelectorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Seleccionar Especialidad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: _isCustomSpecialty ? AppColors.primary.withOpacity(0.12) : Colors.grey.shade100,
                  leading: Icon(
                    _isCustomSpecialty ? Icons.check_circle : Icons.edit_note_rounded,
                    color: _isCustomSpecialty ? AppColors.primary : Colors.grey.shade700,
                  ),
                  title: const Text(
                    '✏️ Otra (Escribir personalizada...)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  onTap: () {
                    setState(() {
                      _isCustomSpecialty = true;
                      _selectedSpecialtyId = null;
                      _selectedSpecialtyName = '✏️ Otra (Personalizada)';
                    });
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    itemCount: _specialties.length,
                    itemBuilder: (context, index) {
                      final s = _specialties[index];
                      final sId = int.tryParse(s['id'].toString());
                      final name = s['name'] ?? '';
                      final isSelected = !_isCustomSpecialty && _selectedSpecialtyId == sId;
                      return ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? AppColors.primary : Colors.grey,
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedSpecialtyId = sId;
                            _selectedSpecialtyName = name;
                            _isCustomSpecialty = false;
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isCustomSpecialty && _selectedSpecialtyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona o ingresa una especialidad requerida.')),
      );
      return;
    }

    if (_isCustomSpecialty && _customSpecialtyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre de la especialidad personalizada.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = getIt<JobRepository>();
      final double? budgetVal = double.tryParse(_budgetController.text.trim());

      List<String>? photosBase64;
      if (_selectedPhotos.isNotEmpty) {
        photosBase64 = [];
        for (final photoFile in _selectedPhotos) {
          final bytes = await photoFile.readAsBytes();
          photosBase64.add('data:image/jpeg;base64,${base64Encode(bytes)}');
        }
      }

      String? desiredDateStr;
      if (_desiredDate != null) {
        desiredDateStr = DateFormat('yyyy-MM-dd').format(_desiredDate!);
      }

      final success = await repo.createPublicJobRequest(
        specialtyId: _isCustomSpecialty ? null : _selectedSpecialtyId,
        customSpecialty: _isCustomSpecialty ? _customSpecialtyController.text.trim() : null,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        budget: budgetVal,
        isUrgent: _isUrgent,
        desiredDate: desiredDateStr,
        photosBase64: photosBase64,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Solicitud abierta creada exitosamente! Los maestros de la zona podrán cotizar tu servicio.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo publicar la solicitud. Intenta nuevamente.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(

      appBar: AppBar(
        title: const Text('Publicar Solicitud Abierta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loadingSpecialties
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Los profesionales de tu zona recibirán tu necesidad y te enviarán sus mejores cotizaciones.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Especialidad Requerida *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showSpecialtySelectorSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedSpecialtyName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: _isCustomSpecialty ? FontWeight.bold : FontWeight.normal,
                                  color: _isCustomSpecialty ? AppColors.primary : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey, size: 28),
                          ],
                        ),
                      ),
                    ),
                    if (_isCustomSpecialty) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customSpecialtyController,
                        decoration: InputDecoration(
                          hintText: 'Escribe el oficio / especialidad (Ej. Técnico en Aire Acondicionado)',
                          prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (_isCustomSpecialty && (val == null || val.trim().isEmpty)) {
                            return 'Ingresa el nombre de la especialidad';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('Título del Servicio *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Ej. Fuga de agua en baño principal',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un título' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Descripción Detallada *', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe el problema con el mayor detalle posible...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa una descripción' : null,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.jobAddressVisitRequired, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _openAddressPicker,
                      borderRadius: BorderRadius.circular(12),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: l10n.jobAddressGoogleMapsHint,
                            prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search_rounded, color: AppColors.primary),
                              onPressed: _openAddressPicker,
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? l10n.jobAddressValidation : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Fecha Deseada del Trabajo (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _desiredDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 180)),
                        );
                        if (date != null) {
                          setState(() => _desiredDate = date);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _desiredDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_desiredDate!)
                                    : 'Seleccionar fecha (Lo antes posible)',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _desiredDate != null ? Colors.black87 : Colors.grey.shade600,
                                  fontWeight: _desiredDate != null ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_desiredDate != null)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                                onPressed: () => setState(() => _desiredDate = null),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fotografías del Servicio (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_selectedPhotos.length}/4', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._selectedPhotos.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 90,
                              height: 90,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedPhotos.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (_selectedPhotos.length < 4)
                            InkWell(
                              onTap: _showImagePickerOptions,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 28),
                                    SizedBox(height: 4),
                                    Text('Adjuntar', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Presupuesto Estimado (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        hintText: 'Ej. 25000',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('¿Es una Urgencia / Emergencia?', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Destaca tu solicitud para atención prioritaria'),
                      activeColor: Colors.red,
                      value: _isUrgent,
                      onChanged: (val) => setState(() => _isUrgent = val),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Publicar Solicitud Abierta',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
