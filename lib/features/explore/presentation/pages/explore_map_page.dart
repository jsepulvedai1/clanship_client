import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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
import 'package:clanship_cliente/features/home/presentation/widgets/services_filter_sheet.dart';
import 'package:clanship_cliente/core/services/specialties_cache_service.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';

class _MapCluster {
  double latSum;
  double lngSum;
  final List<Professional> items;

  _MapCluster({
    required double initialLat,
    required double initialLng,
    required Professional initialProf,
  })  : latSum = initialLat,
        lngSum = initialLng,
        items = [initialProf];

  LatLng get center => LatLng(latSum / items.length, lngSum / items.length);

  void add(Professional prof) {
    items.add(prof);
    latSum += prof.latitude;
    lngSum += prof.longitude;
  }
}

class ExploreMapPage extends StatefulWidget {

  final bool initialUrgencyMode;
  const ExploreMapPage({super.key, this.initialUrgencyMode = false});

  @override
  State<ExploreMapPage> createState() => _ExploreMapPageState();
}

class _ExploreMapPageState extends State<ExploreMapPage>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Professional> _filteredProfessionals = [];
  double _currentZoom = 14.5;
  final Map<int, BitmapDescriptor> _clusterIconCache = {};
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = getIt<LocationService>();
  Position? _currentPosition;
  Professional? _selectedProfessional;
  bool _isUrgencyMode = false;
  final Set<int> _selectedTagIds = {};
  final Set<int> _selectedSubtagIds = {};
  final Set<String> _selectedTagNames = {};
  final Set<String> _selectedSubtagNames = {};
  List<dynamic> _specialties = [];

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

  @override
  void initState() {
    super.initState();
    _isUrgencyMode = widget.initialUrgencyMode;
    _searchController.addListener(_onSearchChanged);
    _initLocation();
    _fetchSpecialties();
  }

  Future<void> _fetchSpecialties() async {
    try {
      final cacheService = getIt<SpecialtiesCacheService>();

      List<dynamic> list = cacheService.getSpecialties();
      if (list.isEmpty) {
        await cacheService.preloadOrRefresh();
        list = cacheService.getSpecialties();
      } else {
        cacheService.preloadOrRefresh();
      }
      if (mounted) {
        setState(() {
          _specialties = list;
        });
      }
    } catch (e) {
      debugPrint('Error fetching specialties for filter: $e');
    }
  }

  void _updateSelectedNames() {
    _selectedTagNames.clear();
    _selectedSubtagNames.clear();

    for (final spec in _specialties) {
      final tags = spec['tags'] as List<dynamic>? ?? [];
      for (final tag in tags) {
        final tagId = int.parse(tag['id'].toString());
        final tagName = tag['name'] as String;
        if (_selectedTagIds.contains(tagId)) {
          _selectedTagNames.add(tagName);
        }
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        for (final subtag in subtags) {
          final subtagId = int.parse(subtag['id'].toString());
          final subtagName = subtag['name'] as String;
          if (_selectedSubtagIds.contains(subtagId)) {
            _selectedSubtagNames.add(subtagName);
            // If the subtag is selected, the parent tag name also matches
            _selectedSubtagNames.add(tagName);
          }
        }
      }
    }
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ServicesFilterSheet(
          specialties: _specialties,
          initialSelectedTagIds: _selectedTagIds,
          initialSelectedSubtagIds: _selectedSubtagIds,
          onApply: (selectedTagIds, selectedSubtagIds) {
            setState(() {
              _selectedTagIds.clear();
              _selectedTagIds.addAll(selectedTagIds);
              _selectedSubtagIds.clear();
              _selectedSubtagIds.addAll(selectedSubtagIds);
              _updateSelectedNames();
              
              if (_selectedProfessional != null) {
                final p = _selectedProfessional!;
                if (_selectedTagIds.isNotEmpty || _selectedSubtagIds.isNotEmpty) {
                  final matchesTag = _selectedTagNames.any((tagName) => p.tags.any((t) => t.toLowerCase() == tagName.toLowerCase() || t.toLowerCase().startsWith('${tagName.toLowerCase()}|')));
                  final matchesSubtag = _selectedSubtagNames.any((subtagName) => p.tags.any((t) => t.toLowerCase() == subtagName.toLowerCase() || t.toLowerCase().startsWith('${subtagName.toLowerCase()}|')));
                  if (!matchesTag && !matchesSubtag) {
                    _selectedProfessional = null;
                  }
                }
              }
            });
            final state = context.read<HomeBloc>().state;
            if (state is HomeLoaded) {
              _buildMarkers(state.professionals, query: _searchController.text);
            }
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  Future<void> _initLocation() async {
    try {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted) {
        setState(() {
          _currentPosition = lastPosition;
        });

        context.read<HomeBloc>().add(
          FetchNearbyProfessionals(
            latitude: lastPosition.latitude,
            longitude: lastPosition.longitude,
          ),
        );

        _mapController?.moveCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(lastPosition.latitude, lastPosition.longitude),
            14.5,
          ),
        );
      }
    } catch (_) {}
    await _getUserLocation();
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
    setState(() {});
    final state = context.read<HomeBloc>().state;
    if (state is HomeLoaded) {
      _buildMarkers(state.professionals, query: _searchController.text);
    } else {
      _buildMarkers([], query: _searchController.text);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  void _onCameraIdle() {
    _recluster();
  }

  Future<BitmapDescriptor> _getClusterMarkerIcon(int count) async {
    if (_clusterIconCache.containsKey(count)) {
      return _clusterIconCache[count]!;
    }

    const double size = 48.0;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // 1. Sombra circular
    final shadowPaint = ui.Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(size / 2, size / 2 + 1), 19.0, shadowPaint);

    // 2. Borde exterior blanco
    final whitePaint = ui.Paint()
      ..color = Colors.white
      ..isAntiAlias = true;
    canvas.drawCircle(const Offset(size / 2, size / 2), 19.0, whitePaint);

    // 3. Círculo interior con color temático
    final clusterColor = _isUrgencyMode ? AppColors.urgency : AppColors.primary;
    final colorPaint = ui.Paint()
      ..color = clusterColor
      ..isAntiAlias = true;
    canvas.drawCircle(const Offset(size / 2, size / 2), 16.0, colorPaint);

    // 4. Conteo de profesionales
    final String text = count > 99 ? '+99' : '$count';
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: text.length > 2 ? 12.0 : 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Plus Jakarta Sans',
        ),
      )
      ..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size / 2) - (textPainter.width / 2),
        (size / 2) - (textPainter.height / 2),
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    _clusterIconCache[count] = descriptor;
    return descriptor;
  }

  Future<void> _recluster() async {
    if (_filteredProfessionals.isEmpty) {
      if (mounted && _markers.isNotEmpty) {
        setState(() => _markers = {});
      }
      return;
    }

    // Radio en grados aproximado a 48 píxeles de pantalla según el nivel de zoom
    final double threshold = (360.0 / (math.pow(2, _currentZoom) * 256.0)) * 48.0;
    final double thresholdSq = threshold * threshold;

    final List<_MapCluster> clusters = [];
    for (final prof in _filteredProfessionals) {
      bool added = false;
      for (final c in clusters) {
        final dLat = c.center.latitude - prof.latitude;
        final dLng = c.center.longitude - prof.longitude;
        if ((dLat * dLat + dLng * dLng) <= thresholdSq) {
          c.add(prof);
          added = true;
          break;
        }
      }
      if (!added) {
        clusters.add(_MapCluster(
          initialLat: prof.latitude,
          initialLng: prof.longitude,
          initialProf: prof,
        ));
      }
    }

    final Set<Marker> newMarkers = {};
    for (int i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      if (cluster.items.length > 1) {
        final clusterIcon = await _getClusterMarkerIcon(cluster.items.length);
        newMarkers.add(
          Marker(
            markerId: MarkerId('cluster_${i}_${cluster.items.length}_${cluster.center.latitude}_${cluster.center.longitude}'),
            position: cluster.center,
            icon: clusterIcon,
            anchor: const Offset(0.5, 0.5),
            onTap: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  cluster.center,
                  (_currentZoom + 2.5).clamp(1.0, 20.0),
                ),
              );
            },
          ),
        );
      } else {
        final prof = cluster.items.first;
        try {
          final Color pinColor = _getProfessionalColor(prof);
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
              anchor: const Offset(0.5, 1.0),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  void _buildMarkers(
    List<Professional> professionals, {
    String query = '',
  }) {
    final List<Professional> listToUse = professionals;

    final filteredList = listToUse.where((p) {
      if (_isUrgencyMode && !p.acceptsUrgency) return false;
      if (_selectedTagIds.isNotEmpty || _selectedSubtagIds.isNotEmpty) {
        final matchesTag = _selectedTagNames.any((tagName) => p.tags.any((t) => t.toLowerCase() == tagName.toLowerCase() || t.toLowerCase().startsWith('${tagName.toLowerCase()}|')));
        final matchesSubtag = _selectedSubtagNames.any((subtagName) => p.tags.any((t) => t.toLowerCase() == subtagName.toLowerCase() || t.toLowerCase().startsWith('${subtagName.toLowerCase()}|')));
        if (!matchesTag && !matchesSubtag) return false;
      }
      if (query.isEmpty) return true;
      final q = query.toLowerCase();

      final List<String> matchingParentTags = [];
      for (final spec in _specialties) {
        final tags = spec['tags'] as List<dynamic>? ?? [];
        for (final tag in tags) {
          final tagName = tag['name'] as String;
          final subtags = tag['subtags'] as List<dynamic>? ?? [];
          for (final subtag in subtags) {
            final subtagName = (subtag['name'] as String).toLowerCase();
            if (subtagName.contains(q)) {
              matchingParentTags.add(tagName.toLowerCase());
            }
          }
        }
      }

      return p.name.toLowerCase().contains(q) ||
          p.specialty.toLowerCase().contains(q) ||
          p.tags.any((tag) => tag.toLowerCase().contains(q)) ||
          p.synonyms.any((syn) => syn.toLowerCase().contains(q)) ||
          p.tags.any((t) {
            final cleanTag = t.toLowerCase().split('|')[0];
            return matchingParentTags.contains(cleanTag);
          });
    }).toList();

    _filteredProfessionals = filteredList;
    _clusterIconCache.clear();
    _recluster();
  }



  Color _getProfessionalColor(Professional prof) {
    if (_isUrgencyMode) {
      return AppColors.urgency;
    }
    if (prof.specialtyColor != null && prof.specialtyColor!.isNotEmpty) {
      try {
        final hex = prof.specialtyColor!.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      } catch (_) {}
    }
    return _getCategoryColor(prof.specialty);
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
    // Dimensiones compactas y proporcionadas para Google Maps en móvil
    const double w = 54.0;
    const double h = 68.0;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // 1. Sombra base difuminada en la punta del pin
    final shadowPaint = ui.Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(w / 2, h - 4),
        width: 18,
        height: 6,
      ),
      shadowPaint,
    );

    // 2. PATH DE LA GOTA EXTERIOR (Borde Blanco)
    final Path outerPath = Path();
    outerPath.moveTo(w / 2, h - 4); // Punta inferior externa

    // Curva izquierda desde la punta hacia la curvatura del círculo
    outerPath.cubicTo(
      w / 2 - 16,
      h - 26, // Punto de control 1
      w / 2 - 22,
      36, // Punto de control 2
      w / 2 - 22,
      24, // Destino: extremo izquierdo del círculo
    );

    // Arco superior completo (Cabeza del pin)
    outerPath.addArc(
      Rect.fromCircle(center: const Offset(w / 2, 24), radius: 22),
      3.14159, // Comienza en la izquierda
      3.14159, // Gira 180 grados hacia la derecha
    );

    // Curva derecha desde el círculo bajando hacia la punta inferior
    outerPath.cubicTo(w / 2 + 22, 36, w / 2 + 16, h - 26, w / 2, h - 4);
    outerPath.close();

    // 3. PATH DE LA GOTA INTERIOR (Relleno de Color)
    final Path innerPath = Path();
    innerPath.moveTo(
      w / 2,
      h - 7,
    ); // Punta inferior interna

    innerPath.cubicTo(w / 2 - 13, h - 25, w / 2 - 18.5, 34, w / 2 - 18.5, 24);
    innerPath.addArc(
      Rect.fromCircle(
        center: const Offset(w / 2, 24),
        radius: 18.5,
      ), // Radio menor para dejar borde
      3.14159,
      3.14159,
    );
    innerPath.cubicTo(w / 2 + 18.5, 34, w / 2 + 13, h - 25, w / 2, h - 7);
    innerPath.close();

    // 4. DIBUJAR EN EL CANVAS
    final Paint whitePaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true;
    canvas.drawPath(outerPath, whitePaint);

    final Paint colorPaint = Paint()
      ..color = color
      ..isAntiAlias = true;
    canvas.drawPath(innerPath, colorPaint);

    // 5. PINTAR EL ICONO EN EL CENTRO DE LA CABEZA
    if (specialtyImage != null) {
      final double targetWidth = 24.0;
      final double targetHeight = 24.0;
      final Rect destRect = Rect.fromCenter(
        center: const Offset(w / 2, 24),
        width: targetWidth,
        height: targetHeight,
      );
      canvas.drawImageRect(
        specialtyImage,
        Rect.fromLTWH(
          0,
          0,
          specialtyImage.width.toDouble(),
          specialtyImage.height.toDouble(),
        ),
        destRect,
        Paint()..isAntiAlias = true,
      );
    } else {
      final iconPainter = TextPainter(textDirection: TextDirection.ltr)
        ..text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: 20.0,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: Colors.white,
          ),
        )
        ..layout();

      iconPainter.paint(
        canvas,
        Offset(
          (w / 2) - (iconPainter.width / 2),
          24 - (iconPainter.height / 2),
        ),
      );
    }

    // 6. GENERAR BITMAP
    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), h.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
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
                      enabled: true,
                      controller: _searchController,
                      autofocus: false,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.exploreSearchHint,
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.38),
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
                        ).colorScheme.onSurface.withValues(alpha: 0.38),
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  else
                    GestureDetector(
                      onTap: _showFiltersBottomSheet,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (_selectedTagIds.isNotEmpty || _selectedSubtagIds.isNotEmpty)
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: (_selectedTagIds.isNotEmpty || _selectedSubtagIds.isNotEmpty)
                              ? Colors.white
                              : AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Urgency Toggle Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5271),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5271).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.exploreUrgencyMode,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.exploreUrgencySubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isUrgencyMode,
                    onChanged: (value) {
                      setState(() {
                        _isUrgencyMode = value;
                        if (_isUrgencyMode && _selectedProfessional != null && !_selectedProfessional!.acceptsUrgency) {
                          _selectedProfessional = null;
                        }
                        final state = context.read<HomeBloc>().state;
                        if (state is HomeLoaded) {
                          _buildMarkers(state.professionals, query: _searchController.text);
                        }
                      });
                    },
                    activeColor: const Color(0xFF00FF7F),
                    activeTrackColor: Colors.white.withValues(alpha: 0.3),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            if (_selectedTagIds.isNotEmpty || _selectedSubtagIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ActionChip(
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    elevation: 2,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.exploreClearFilters(_selectedTagIds.length + _selectedSubtagIds.length),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.close_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTagIds.clear();
                        _selectedSubtagIds.clear();
                        _selectedTagNames.clear();
                        _selectedSubtagNames.clear();
                        final state = context.read<HomeBloc>().state;
                        if (state is HomeLoaded) {
                          _buildMarkers(state.professionals, query: _searchController.text);
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ],
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
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
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
                              _getProfessionalColor(_selectedProfessional!).withValues(alpha: 0.8),
                              _getProfessionalColor(_selectedProfessional!),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: _selectedProfessional!.imageUrl.isNotEmpty
                              ? Image.network(
                                  _selectedProfessional!.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      _selectedProfessional!.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _selectedProfessional!.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                      color: AppColors.success.withValues(
                                        alpha: 0.15,
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
                                          l10n.exploreVerified,
                                          style: const TextStyle(
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
                                color: _getProfessionalColor(_selectedProfessional!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_selectedProfessional!.tags.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: _selectedProfessional!.tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getProfessionalColor(_selectedProfessional!).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _getProfessionalColor(_selectedProfessional!).withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getProfessionalColor(_selectedProfessional!),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
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
                                    l10n.exploreViewProfile,
                                    style: const TextStyle(
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
                            ).shadowColor.withValues(alpha: 0.08),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.exploreSearchingServices,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
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
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
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


}
