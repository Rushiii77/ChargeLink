import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../widgets/cards/charger_card.dart';
import '../../../widgets/common/filter_sheet.dart';
import '../charger/charger_detail_sheet.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  // ── Services ──────────────────────────────────────────────────────────────
  final AuthService _authService = AuthService();
  final ChargerService _chargerService = ChargerService();

  // ── Map ───────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  BitmapDescriptor? _customMarker;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.0330, 73.0297),
    zoom: 14,
  );

  // ── State ─────────────────────────────────────────────────────────────────
  List<ChargerModel> _allChargers = [];
  List<ChargerModel> _filteredChargers = [];
  ChargerFilter _filter = const ChargerFilter();
  String _searchQuery = '';
  bool _isLoading = true;

  late StreamSubscription<List<ChargerModel>> _chargerSub;
  final TextEditingController _searchController = TextEditingController();

  // ── Init ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _ensureChargersSeeded();
    _listenToChargers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _chargerSub.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── Marker icon ───────────────────────────────────────────────────────────
  Future<void> _loadCustomMarker() async {
    try {
      final marker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/ev_marker.png',
      );
      if (mounted) setState(() => _customMarker = marker);
    } catch (_) {}
  }

  // ── Seed Firestore if empty ───────────────────────────────────────────────
  Future<void> _ensureChargersSeeded() async {
    final exists = await _chargerService.chargersExist();
    if (!exists) {
      await _chargerService.seedChargers();
    }
  }

  // ── Real-time charger stream ──────────────────────────────────────────────
  void _listenToChargers() {
    _chargerSub = _chargerService.chargerStream().listen((chargers) {
      if (!mounted) return;
      setState(() {
        _allChargers = chargers;
        _isLoading = false;
        _applyFilters();
      });
    });
  }

  // ── Filter + Search ───────────────────────────────────────────────────────
  void _applyFilters() {
    final query = _searchQuery.toLowerCase();
    setState(() {
      _filteredChargers = _allChargers.where((c) {
        // Search
        if (query.isNotEmpty &&
            !c.name.toLowerCase().contains(query) &&
            !c.address.toLowerCase().contains(query)) {
          return false;
        }
        // Charger type
        if (_filter.chargerType != 'All' &&
            c.chargerType != _filter.chargerType) {
          return false;
        }
        // Connector
        if (_filter.connectorType != 'All' &&
            c.connectorType != _filter.connectorType) {
          return false;
        }
        // Min power
        if (_filter.minPowerKw > 0 && c.powerKw < _filter.minPowerKw) {
          return false;
        }
        // Availability
        if (_filter.availableOnly && !c.isAvailable) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  // ── Map markers ───────────────────────────────────────────────────────────
  Set<Marker> _buildMarkers() {
    final icon = _customMarker ?? BitmapDescriptor.defaultMarker;
    return _filteredChargers.map((charger) {
      return Marker(
        markerId: MarkerId(charger.id),
        position: LatLng(charger.latitude, charger.longitude),
        icon: icon,
        onTap: () => _showDetail(charger),
      );
    }).toSet();
  }

  // ── Show charger detail ───────────────────────────────────────────────────
  void _showDetail(ChargerModel charger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChargerDetailSheet(charger: charger),
    );
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterSheet(
        initialFilter: _filter,
        onApply: (f) {
          setState(() => _filter = f);
          _applyFilters();
        },
      ),
    );
  }

  // ── Go to user location ───────────────────────────────────────────────────
  Future<void> _goToMyLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location services are disabled on your device."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permission is permanently denied in settings."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    } catch (_) {
      // If GPS fails or times out, smoothly focus on chargers cluster (Nerul)
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition),
      );
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _buildMarkers(),
            onMapCreated: (controller) {
              _mapController = controller;
              // Auto-center on user's real GPS after map loads
              _goToMyLocation();
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
          ),

          // ── Top overlay: search bar + filter ───────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) {
                          _searchQuery = v;
                          _applyFilters();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search charging stations...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.green,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _applyFilters();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Filter button
                  GestureDetector(
                    onTap: _openFilterSheet,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            _filter.isActive ? Colors.green : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune,
                        color:
                            _filter.isActive ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // My Bookings button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/my-bookings');
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Logout button
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.logout, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Loading overlay ─────────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),

          // ── Bottom charger cards strip ──────────────────────────────────
          if (!_isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomStrip(),
            ),
        ],
      ),

      // ── FAB: my location ────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        mini: true,
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }

  Widget _buildBottomStrip() {
    if (_filteredChargers.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.grey.shade400),
            const SizedBox(width: 10),
            Text(
              'No chargers match your filters',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              '${_filteredChargers.length} station${_filteredChargers.length == 1 ? '' : 's'} nearby',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
              itemCount: _filteredChargers.length,
              itemBuilder: (_, i) => ChargerCard(
                charger: _filteredChargers[i],
                onTap: () {
                  // Animate map to charger
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          _filteredChargers[i].latitude,
                          _filteredChargers[i].longitude,
                        ),
                        zoom: 16,
                      ),
                    ),
                  );
                  _showDetail(_filteredChargers[i]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}