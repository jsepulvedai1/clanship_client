import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/home/presentation/pages/professional_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeMapPage extends StatefulWidget {
  final List<Professional> professionals;

  const HomeMapPage({super.key, required this.professionals});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  final LatLng _initialPosition = const LatLng(
    -33.4489,
    -70.6693,
  ); // Central Santiago, Chile

  @override
  void initState() {
    super.initState();
    _createMarkers();
    // Add listener to update markers in real-time as the user types
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _createMarkers(query: _searchController.text);
  }

  /// Generates the marker set, optionally filtering by query.
  /// Uses modern Google-style pins (Circular icon + Side-aligned label).
  Future<void> _createMarkers({String query = ''}) async {
    final Set<Marker> newMarkers = {};

    final filteredList = widget.professionals.where((p) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.specialty.toLowerCase().contains(q);
    }).toList();

    for (int i = 0; i < filteredList.length; i++) {
      final prof = filteredList[i];
      // Color coding based on specialty (Mimics Google Maps categories)
      final Color pinColor = _getCategoryColor(prof.specialty);

      final markerIcon = await _getGoogleStyleMarkerIcon(
        prof.name,
        prof.specialty,
        pinColor,
      );

      newMarkers.add(
        Marker(
          markerId: MarkerId(prof.id),
          position: LatLng(prof.latitude, prof.longitude),
          onTap: () => _navigateToDetail(prof),
          icon: markerIcon,
          anchor: const Offset(
            0.12,
            0.5,
          ), // Anchor at the center of the circular pin
          infoWindow: InfoWindow(title: prof.name, snippet: prof.specialty),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    }
  }

  Color _getCategoryColor(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('médic') || s.contains('salud') || s.contains('cardió')) {
      return Colors.red.shade600;
    }
    if (s.contains('soft') || s.contains('dev') || s.contains('ing')) {
      return Colors.blue.shade600;
    }
    if (s.contains('arquitect') || s.contains('constru')) {
      return Colors.orange.shade700;
    }
    return AppColors.primary;
  }

  /// Creates a modern Google-style marker icon: (Circle Pin) + (Label to the right)
  Future<BitmapDescriptor> _getGoogleStyleMarkerIcon(
    String name,
    String specialty,
    Color color,
  ) async {
    const double pinRadius = 22.0;
    const double spacing = 10.0;
    const double nameFontSize = 22.0;
    const double specialtyFontSize = 18.0;
    const double haloWidth = 2.5;

    // 1. Text Painters for Name
    final TextPainter namePainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: name,
        style: const TextStyle(
          fontSize: nameFontSize,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
    namePainter.layout();

    final TextPainter nameHaloPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: name,
        style: TextStyle(
          fontSize: nameFontSize,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = haloWidth
            ..color = Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
    nameHaloPainter.layout();

    // 2. Text Painters for Specialty
    final TextPainter specPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: specialty,
        style: TextStyle(
          fontSize: specialtyFontSize,
          color: Colors.black.withOpacity(0.7),
          fontWeight: FontWeight.w500,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
    specPainter.layout();

    final TextPainter specHaloPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: specialty,
        style: TextStyle(
          fontSize: specialtyFontSize,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = haloWidth
            ..color = Colors.white,
          fontWeight: FontWeight.w500,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
    specHaloPainter.layout();

    final double textWidth = namePainter.width > specPainter.width 
        ? namePainter.width 
        : specPainter.width;
    
    final double width = (pinRadius * 2) + spacing + textWidth + 10;
    final double height = (pinRadius * 2) + 12;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // 1. Draw Pin Shadow
    final ui.Paint shadowPaint = ui.Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4.0);
    canvas.drawCircle(
      const Offset(pinRadius + 2, pinRadius + 3),
      pinRadius,
      shadowPaint,
    );

    // 2. Draw Outer Circle (Pin Body)
    final ui.Paint pinPaint = ui.Paint()..color = color;
    canvas.drawCircle(const Offset(pinRadius, pinRadius), pinRadius, pinPaint);

    // 3. Draw Inner White Circle
    final ui.Paint innerPinPaint = ui.Paint()..color = Colors.white;
    canvas.drawCircle(
      const Offset(pinRadius, pinRadius),
      pinRadius * 0.75,
      innerPinPaint,
    );

    // 4. Draw Inner Dot
    final ui.Paint dotPaint = ui.Paint()..color = color;
    canvas.drawCircle(
      const Offset(pinRadius, pinRadius),
      pinRadius * 0.35,
      dotPaint,
    );

    // 5. Draw Labels (to the right, vertically centered)
    final double textOffsetX = (pinRadius * 2) + spacing;
    final double totalTextHeight = namePainter.height + specPainter.height - 4;
    double currentY = (height - totalTextHeight) / 2;

    // Paint Name with Halo
    nameHaloPainter.paint(canvas, Offset(textOffsetX, currentY));
    namePainter.paint(canvas, Offset(textOffsetX, currentY));
    
    currentY += namePainter.height - 4;

    // Paint Specialty with Halo
    specHaloPainter.paint(canvas, Offset(textOffsetX, currentY));
    specPainter.paint(canvas, Offset(textOffsetX, currentY));

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map with Silver/Minimalist Styling
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.5,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            style: _silverMapStyle,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: false,
            trafficEnabled: false,
          ),

          // 2. High-Fidelity Floating Search Bar
          Positioned(
            top: topPadding + 16,
            left: 20,
            right: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.blue.shade400,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: false,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Buscar profesional...',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 17,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Colors.blue.shade400,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Contextual Actions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                heroTag: 'area_search',
                onPressed: () {},
                backgroundColor: AppColors.primary,
                elevation: 10,
                label: const Text(
                  'Buscar en esta área',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ),
          ),

          // Side Control: Recenter
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'recenter_map',
              onPressed: () {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(_initialPosition, 14.5),
                );
              },
              backgroundColor: Colors.white,
              mini: true,
              elevation: 4,
              child: Icon(
                Icons.my_location_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Minimalist Silver Map Style JSON
  static const String _silverMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#bdbdbd"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#eeeeee"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#e5e5e5"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#dadada"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [{"color": "#e5e5e5"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{"color": "#eeeeee"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#c9c9c9"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  }
]
''';
}
