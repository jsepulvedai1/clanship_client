import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:math'; // Importante para generar el desplazamiento aleatorio
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_event.dart';
import 'package:clanship_cliente/features/home/presentation/bloc/home_state.dart';
import 'package:clanship_cliente/features/home/presentation/pages/professional_detail_page.dart';
import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/network/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExploreMapPage extends StatefulWidget {
  const ExploreMapPage({super.key});

  @override
  State<ExploreMapPage> createState() => _ExploreMapPageState();
}

class _ExploreMapPageState extends State<ExploreMapPage>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = getIt<LocationService>();
  Position? _currentPosition;
  Professional? _selectedProfessional;
  bool _mapReady = false;

  final Map<String, ui.Image> _specialtyImagesCache = {};

  Future<ui.Image> _loadSpecialtyImage(String url) async {
    if (_specialtyImagesCache.containsKey(url)) {
      return _specialtyImagesCache[url]!;
    }
    final Uri uri = Uri.parse(url);
    final HttpClientRequest request = await HttpClient().getUrl(uri);
    final HttpClientResponse response = await request.close();
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    _specialtyImagesCache[url] = fi.image;
    return fi.image;
  }

  // Santiago Centro por defecto si falla el GPS
  final LatLng _initialPosition = const LatLng(-33.4489, -70.6693);

  @override
  bool get wantKeepAlive => true;

  /// Genera profesionales simulados distribuidos aleatoriamente en un radio cercano (aprox. 1.5km)
  /// tomando como origen la ubicación real recibida.
  List<Professional> _generateMockProfessionalsAround(LatLng center) {
    final Random random = Random(42);

    final List<Map<String, dynamic>> baseData = [
      {
        'name': 'Carolina R.',
        'specialty': 'Electricista',
        'rating': 4.8,
        'verified': true,
        'price': 35.0,
      },
      {
        'name': 'Diego M.',
        'specialty': 'Gasfitería',
        'rating': 4.6,
        'verified': true,
        'price': 28.0,
      },
      {
        'name': 'Valentina S.',
        'specialty': 'Pintura',
        'rating': 4.9,
        'verified': false,
        'price': 22.0,
      },
      {
        'name': 'Andrés P.',
        'specialty': 'Carpintería',
        'rating': 4.5,
        'verified': true,
        'price': 32.0,
      },
      {
        'name': 'Lucía F.',
        'specialty': 'Limpieza',
        'rating': 4.7,
        'verified': true,
        'price': 18.0,
      },
      {
        'name': 'Roberto C.',
        'specialty': 'Mecánica',
        'rating': 4.3,
        'verified': false,
        'price': 40.0,
      },
      {
        'name': 'Patricia G.',
        'specialty': 'Jardinería',
        'rating': 4.9,
        'verified': true,
        'price': 20.0,
      },
      {
        'name': 'Felipe O.',
        'specialty': 'Electricista',
        'rating': 4.4,
        'verified': false,
        'price': 30.0,
      },
      {
        'name': 'Isabel T.',
        'specialty': 'Gasfitería',
        'rating': 4.8,
        'verified': true,
        'price': 26.0,
      },
      {
        'name': 'Matías H.',
        'specialty': 'Carpintería',
        'rating': 4.6,
        'verified': true,
        'price': 35.0,
      },
      {
        'name': 'Sofía B.',
        'specialty': 'Pintura',
        'rating': 4.7,
        'verified': true,
        'price': 24.0,
      },
      {
        'name': 'Juan V.',
        'specialty': 'Limpieza',
        'rating': 4.5,
        'verified': false,
        'price': 16.0,
      },
    ];

    return List.generate(baseData.length, (index) {
      final data = baseData[index];

      final double u = random.nextDouble();
      final double v = random.nextDouble();
      final double radiusInDegrees = 0.015 * sqrt(u);
      final double theta = v * 2 * pi;

      final double latOffset = radiusInDegrees * cos(theta);
      final double lngOffset = radiusInDegrees * sin(theta);

      // Calculamos la distancia asegurándonos de que retorne un double
      final double calculatedDistance = double.parse(
        (0.3 + (random.nextDouble() * 1.5)).toStringAsFixed(1),
      );

      return Professional(
        id: 'mock_${index + 1}',
        name: data['name'] as String,
        specialty: data['specialty'] as String,
        rating: (data['rating'] as num).toDouble(), // Casteo seguro a double
        distance: calculatedDistance,
        imageUrl:
            'https://i.pravatar.cc/150?u=${(data['name'] as String).toLowerCase().split(' ')[0]}',
        isVerified: data['verified'] as bool,
        pricePerHour: (data['price'] as num)
            .toDouble(), // Conversión explícita a double
        description: 'Servicio profesional garantizado a domicilio.',
        latitude: center.latitude + latOffset,
        longitude: center.longitude + lngOffset,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });

        // 1. Notificar al BLoC para traer los datos reales de la API en la ubicación real
        context.read<HomeBloc>().add(
          FetchNearbyProfessionals(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );

        // 2. Mover la cámara a la posición real del usuario
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14.5,
          ),
        );

        // 3. Render real professionals if they are already loaded
        final state = context.read<HomeBloc>().state;
        if (state is HomeLoaded) {
          _buildMarkers(state.professionals);
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      // Si falla la ubicación real por permisos/GPS deshabilitado, usamos la posición por defecto
      if (_markers.isEmpty) {
        _buildMarkers([]);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final state = context.read<HomeBloc>().state;
    if (state is HomeLoaded) {
      _buildMarkers(state.professionals, query: _searchController.text);
    } else {
      _buildMarkers([], query: _searchController.text);
    }
  }

  Future<void> _buildMarkers(
    List<Professional> professionals, {
    String query = '',
  }) async {
    final List<Professional> listToUse = professionals;

    final Set<Marker> newMarkers = {};

    final filteredList = listToUse.where((p) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.specialty.toLowerCase().contains(q);
    }).toList();

    debugPrint('Building ${filteredList.length} markers around center...');

    for (final prof in filteredList) {
      try {
        final Color pinColor = _getCategoryColor(prof.specialty);
        final IconData categoryIcon = _getCategoryIcon(prof.specialty);

        ui.Image? specialtyImage;
        if (prof.specialtyIconUrl != null && prof.specialtyIconUrl!.isNotEmpty) {
          try {
            specialtyImage = await _loadSpecialtyImage(prof.specialtyIconUrl!);
          } catch (e) {
            debugPrint('Error loading specialty icon from network: $e');
          }
        }

        final markerIcon = await _createModernMarkerIcon(
          icon: categoryIcon,
          color: pinColor,
          label: prof.name,
          specialtyImage: specialtyImage,
        );

        newMarkers.add(
          Marker(
            markerId: MarkerId(prof.id),
            position: LatLng(prof.latitude, prof.longitude),
            onTap: () => _onMarkerTapped(prof),
            icon: markerIcon,
            anchor: const Offset(0.5, 1.0),
          ),
        );
      } catch (e) {
        debugPrint('Error creating marker for ${prof.name}: $e');
        newMarkers.add(
          Marker(
            markerId: MarkerId(prof.id),
            position: LatLng(prof.latitude, prof.longitude),
            onTap: () => _onMarkerTapped(prof),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..addAll(newMarkers);
      });
    }
  }

  Color _getCategoryColor(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('electric')) return Colors.amber.shade700;
    if (s.contains('gasfiter') ||
        s.contains('fontaner') ||
        s.contains('plom')) {
      return Colors.blue.shade600;
    }
    if (s.contains('carpint') || s.contains('muebl')) {
      return Colors.brown.shade600;
    }
    if (s.contains('pintor') || s.contains('pintura')) {
      return Colors.purple.shade500;
    }
    if (s.contains('jard')) return Colors.green.shade600;
    if (s.contains('mecánic') || s.contains('mecanic')) {
      return Colors.grey.shade700;
    }
    if (s.contains('limpieza')) return Colors.teal.shade500;
    if (s.contains('médic') || s.contains('salud')) return Colors.red.shade600;
    return AppColors.primary;
  }

  void _onMarkerTapped(Professional professional) {
    setState(() {
      _selectedProfessional = professional;
    });
  }

  void _navigateToDetail(Professional professional) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfessionalDetailPage(professional: professional),
      ),
    );
  }

  IconData _getCategoryIcon(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('electric')) return Icons.bolt_rounded;
    if (s.contains('gasfiter') ||
        s.contains('fontaner') ||
        s.contains('plom')) {
      return Icons.water_drop_rounded;
    }
    if (s.contains('pintor') || s.contains('pintura')) {
      return Icons.format_paint_rounded;
    }
    if (s.contains('salud') || s.contains('médic')) {
      return Icons.medical_services_rounded;
    }
    if (s.contains('jard')) return Icons.local_florist_rounded;
    if (s.contains('mecánic') || s.contains('mecanic')) {
      return Icons.build_rounded;
    }
    if (s.contains('carpint')) return Icons.carpenter;
    if (s.contains('limpieza')) return Icons.cleaning_services_rounded;
    return Icons.handyman_rounded;
  }

  Future<BitmapDescriptor> _createModernMarkerIcon({
    required IconData icon,
    required Color color,
    required String label,
    ui.Image? specialtyImage,
  }) async {
    // Dimensiones del lienzo optimizadas para pines grandes y nítidos
    const double w = 120.0;
    const double h = 150.0;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // 1. Sombra base difuminada en la punta del pin
    final shadowPaint = ui.Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(w / 2, h - 10),
        width: 32,
        height: 10,
      ),
      shadowPaint,
    );

    // 2. PATH DE LA GOTA EXTERIOR (Borde Blanco)
    final Path outerPath = Path();
    outerPath.moveTo(w / 2, h - 8); // Punta inferior externa

    // Curva izquierda desde la punta hacia la curvatura del círculo
    outerPath.cubicTo(
      w / 2 - 35,
      h - 55, // Punto de control 1 (fuerza de la curva)
      w / 2 - 46,
      75, // Punto de control 2
      w / 2 - 46,
      52, // Destino: extremo izquierdo del círculo
    );

    // Arco superior completo (Cabeza del pin)
    outerPath.addArc(
      Rect.fromCircle(center: const Offset(w / 2, 52), radius: 46),
      3.14159, // Comienza en la izquierda
      3.14159, // Gira 180 grados hacia la derecha
    );

    // Curva derecha desde el círculo bajando hacia la punta inferior
    outerPath.cubicTo(w / 2 + 46, 75, w / 2 + 35, h - 55, w / 2, h - 8);
    outerPath.close();

    // 3. PATH DE LA GOTA INTERIOR (Relleno de Color)
    final Path innerPath = Path();
    innerPath.moveTo(
      w / 2,
      h - 14,
    ); // Punta inferior interna (un poco más arriba)

    innerPath.cubicTo(w / 2 - 30, h - 55, w / 2 - 40, 72, w / 2 - 40, 52);
    innerPath.addArc(
      Rect.fromCircle(
        center: const Offset(w / 2, 52),
        radius: 40,
      ), // Radio menor para dejar borde
      3.14159,
      3.14159,
    );
    innerPath.cubicTo(w / 2 + 40, 72, w / 2 + 30, h - 55, w / 2, h - 14);
    innerPath.close();

    // 4. DIBUJAR EN EL CANVAS

    // Primero pintamos la gota exterior en Blanco
    final Paint whitePaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true;
    canvas.drawPath(outerPath, whitePaint);

    // Luego pintamos la gota interior con el Color de la categoría
    final Paint colorPaint = Paint()
      ..color = color
      ..isAntiAlias = true;
    canvas.drawPath(innerPath, colorPaint);

    // 5. PINTAR EL ICONO EN EL CENTRO DE LA CABEZA
    if (specialtyImage != null) {
      final double targetWidth = 54.0;
      final double targetHeight = 54.0;
      final Rect destRect = Rect.fromCenter(
        center: const Offset(w / 2, 52),
        width: targetWidth,
        height: targetHeight,
      );
      canvas.drawImageRect(
        specialtyImage,
        Rect.fromLTWH(0, 0, specialtyImage.width.toDouble(), specialtyImage.height.toDouble()),
        destRect,
        Paint()..isAntiAlias = true,
      );
    } else {
      final iconPainter = TextPainter(textDirection: TextDirection.ltr)
        ..text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: 44.0, // Tamaño del icono proporcional
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: Colors.white,
          ),
        )
        ..layout();

      // Centramos el icono exactamente en el centro de la cabeza (Y = 52)
      iconPainter.paint(
        canvas,
        Offset((w / 2) - (iconPainter.width / 2), 52 - (iconPainter.height / 2)),
      );
    }

    // 6. GENERAR BITMAP
    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), h.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // ───── Map ─────
          BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeLoaded) {
                _buildMarkers(
                  state.professionals,
                  query: _searchController.text,
                );
              }
            },
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      )
                    : _initialPosition,
                zoom: 14.5,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() => _mapReady = true);

                final state = context.read<HomeBloc>().state;
                if (state is HomeLoaded) {
                  _buildMarkers(
                    state.professionals,
                    query: _searchController.text,
                  );
                } else {
                  _buildMarkers([], query: _searchController.text);
                }

                if (_currentPosition != null) {
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      14.5,
                    ),
                  );
                }
              },
              onTap: (_) {
                setState(() => _selectedProfessional = null);
              },

              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              indoorViewEnabled: false,
              trafficEnabled: false,
            ),
          ),

          // ───── Search Bar ─────
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      controller: _searchController,
                      autofocus: false,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar servicios cercanos...',
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.38),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.38),
                        size: 20,
                      ),
                      onPressed: () {},
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ───── "Buscar en esta área" Button ─────
          // Positioned(
          //   bottom: _selectedProfessional != null ? 220 : 40,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: AnimatedOpacity(
          //       opacity: _mapReady ? 1.0 : 0.0,
          //       duration: const Duration(milliseconds: 300),
          //       child: Container(
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(24),
          //           boxShadow: [
          //             BoxShadow(
          //               color: AppColors.primary.withOpacity(0.3),
          //               blurRadius: 16,
          //               offset: const Offset(0, 4),
          //             ),
          //           ],
          //         ),
          //         child: ElevatedButton.icon(
          //           onPressed: () async {
          //             if (_mapController != null) {
          //               final bounds =
          //                   await _mapController!.getVisibleRegion();
          //               final centerLat = (bounds.northeast.latitude +
          //                       bounds.southwest.latitude) /
          //                   2;
          //               final centerLng = (bounds.northeast.longitude +
          //                       bounds.southwest.longitude) /
          //                   2;
          //               if (mounted) {
          //                 context
          //                     .read<HomeBloc>()
          //                     .add(FetchNearbyProfessionals(
          //                       latitude: centerLat,
          //                       longitude: centerLng,
          //                     ));
          //               }
          //             }
          //           },
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: AppColors.primary,
          //             foregroundColor: Colors.white,
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 24, vertical: 14),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(24),
          //             ),
          //             elevation: 0,
          //           ),
          //           icon: const Icon(Icons.refresh_rounded, size: 20),
          //           label: Text(
          //             'Buscar en esta área',
          //             style: TextStyle(
          //               fontWeight: FontWeight.w600,
          //               fontSize: 15,
          //               letterSpacing: 0.3,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          // ───── Zoom & Recenter Buttons ─────
          Positioned(
            bottom: _selectedProfessional != null ? 230 : 48,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapControl(
                  icon: Icons.add_rounded,
                  onPressed: () =>
                      _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  heroTag: 'explore_zoom_in',
                ),
                const SizedBox(height: 12),
                _buildMapControl(
                  icon: Icons.remove_rounded,
                  onPressed: () =>
                      _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  heroTag: 'explore_zoom_out',
                ),
                const SizedBox(height: 12),
                _buildMapControl(
                  icon: Icons.my_location_rounded,
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          14.5,
                        ),
                      );
                    } else {
                      _getUserLocation();
                    }
                  },
                  heroTag: 'explore_recenter',
                ),
              ],
            ),
          ),

          // ───── Selected Professional Bottom Card ─────
          if (_selectedProfessional != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => _navigateToDetail(_selectedProfessional!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getCategoryColor(
                                _selectedProfessional!.specialty,
                              ).withOpacity(0.8),
                              _getCategoryColor(
                                _selectedProfessional!.specialty,
                              ),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _selectedProfessional!.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedProfessional!.name,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_selectedProfessional!.isVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified_rounded,
                                          color: AppColors.success,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Verificado',
                                          style: TextStyle(
                                            color: AppColors.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedProfessional!.specialty,
                              style: TextStyle(
                                fontSize: 14,
                                color: _getCategoryColor(
                                  _selectedProfessional!.specialty,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedProfessional!.rating.toStringAsFixed(
                                    1,
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.payments_outlined,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '\$${_selectedProfessional!.pricePerHour.toStringAsFixed(0)}/hr',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Ver perfil',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ───── Loading Overlay ─────
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return Positioned(
                  top: topPadding + 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withOpacity(0.08),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Buscando servicios...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        mini: true,
        elevation: 0,
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  // Colorful map style — keeps POIs visible and uses vibrant water/park colors
  static const String _silverMapStyle = '''
[
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#a3ccff"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#5b8cb4"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#b6e59e"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#447530"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#ffd47b"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#e8b84e"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#f0f0f0"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#f5f1eb"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#eef2e4"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [{"saturation": 20}, {"lightness": 10}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#e0dbd3"}]
  },
  {
    "featureType": "administrative",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6b6b6b"}]
  }
]
''';
}
