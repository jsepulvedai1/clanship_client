import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:clanship_cliente/core/theme/app_colors.dart';

class AddressPickerPage extends StatefulWidget {
  final String? initialAddress;
  const AddressPickerPage({super.key, this.initialAddress});

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  LatLng _currentCenter = const LatLng(-33.4489, -70.6693); // Default Santiago Centro
  String _currentAddress = '';
  bool _isLoadingAddress = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.initialAddress ?? '';
    _searchController.text = _currentAddress;
    _initializeLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _getCurrentLocation();
      if (position != null) {
        final newLatLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentCenter = newLatLng;
        });
        final controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 16));
        _reverseGeocode(newLatLng);
      } else {
        _reverseGeocode(_currentCenter);
      }
    } catch (e) {
      _reverseGeocode(_currentCenter);
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final street = pm.street ?? '';
        final subLocality = pm.subLocality ?? '';
        final locality = pm.locality ?? '';
        final subAdministrativeArea = pm.subAdministrativeArea ?? '';
        
        // Build clean address format
        final List<String> parts = [];
        if (street.isNotEmpty) parts.add(street);
        if (subLocality.isNotEmpty && subLocality != street) parts.add(subLocality);
        if (locality.isNotEmpty) {
          parts.add(locality);
        } else if (subAdministrativeArea.isNotEmpty) {
          parts.add(subAdministrativeArea);
        }

        final address = parts.join(', ');
        setState(() {
          _currentAddress = address;
          // Only update textfield if user is not actively searching/focusing
          if (!_searchFocusNode.hasFocus) {
            _searchController.text = address;
          }
        });
      }
    } catch (e) {
      // Fallback
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.trim().isNotEmpty) {
        _fetchAutocomplete(query);
      } else {
        setState(() {
          _predictions = [];
        });
      }
    });
  }

  Future<void> _fetchAutocomplete(String input) async {
    const apiKey = 'AIzaSyB985z0U9nO1LXSrpnn4qwnbDAe-7opBHI';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apiKey&components=country:cl&language=es',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List? ?? [];
        setState(() {
          _predictions = predictions.map((p) => {
            'description': p['description'] as String,
            'placeId': p['place_id'] as String,
          }).toList();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _selectPrediction(Map<String, dynamic> prediction) async {
    _searchFocusNode.unfocus();
    setState(() {
      _predictions = [];
      _isSearching = false;
      _currentAddress = prediction['description'];
      _searchController.text = _currentAddress;
    });

    const apiKey = 'AIzaSyB985z0U9nO1LXSrpnn4qwnbDAe-7opBHI';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction['placeId']}&fields=geometry&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']?['geometry']?['location'];
        if (location != null) {
          final lat = (location['lat'] as num).toDouble();
          final lng = (location['lng'] as num).toDouble();
          final newLatLng = LatLng(lat, lng);

          setState(() {
            _currentCenter = newLatLng;
          });

          final controller = await _mapController.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 16));
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map Background
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            onCameraMove: (CameraPosition position) {
              _currentCenter = position.target;
            },
            onCameraIdle: () {
              _reverseGeocode(_currentCenter);
            },
          ),

          // Central Static Pin Indicator
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 38), // Offset to align point of pin
              child: const Icon(
                Icons.location_on,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
          ),

          // Top Header & Search Bar Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Buscar dirección...',
                              hintStyle: const TextStyle(color: Colors.black38),
                              prefixIcon: const Icon(Icons.search, color: Colors.black45),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.black45),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _predictions = [];
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search Results Dropdown List
                  if (_predictions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8, left: 52),
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _predictions.length,
                        itemBuilder: (context, index) {
                          final p = _predictions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                            title: Text(
                              p['description'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () => _selectPrediction(p),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Floating Action Button to re-center location
          Positioned(
            right: 16,
            bottom: 150,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _initializeLocation,
              child: const Icon(Icons.my_location, color: AppColors.secondary),
            ),
          ),

          // Confirm Button Overlay
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isLoadingAddress
                            ? const LinearProgressIndicator(color: AppColors.primary)
                            : Text(
                                _currentAddress.isNotEmpty ? _currentAddress : 'Selecciona una ubicación',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.secondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _currentAddress.isEmpty || _isLoadingAddress
                        ? null
                        : () {
                            Navigator.pop(context, {
                              'address': _currentAddress,
                              'latitude': _currentCenter.latitude,
                              'longitude': _currentCenter.longitude,
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirmar Ubicación',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
