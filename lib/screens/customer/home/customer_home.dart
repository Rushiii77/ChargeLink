import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/map_styles.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/cards/charger_card.dart';
import '../../../widgets/common/filter_sheet.dart';
import '../../../widgets/glass/glass_container.dart';
import '../ai/smart_recommendation_sheet.dart';
import '../charger/charger_detail_sheet.dart';
import '../session/active_session_screen.dart';
import '../trip/trip_planner_screen.dart';

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
    target: LatLng(19.0330, 73.0297), // Nerul, Navi Mumbai
    zoom: 13.5,
  );

  // ── State ─────────────────────────────────────────────────────────────────
  List<ChargerModel> _allChargers = [];
  List<ChargerModel> _filteredChargers = [];
  ChargerFilter _filter = const ChargerFilter();
  String _searchQuery = '';
  bool _isLoading = true;

  StreamSubscription<List<ChargerModel>>? _chargerSubscription;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    ThemeService.themeModeNotifier.addListener(_updateMapTheme);
    _loadCustomMarker();
    _initChargers();
  }

  @override
  void dispose() {
    ThemeService.themeModeNotifier.removeListener(_updateMapTheme);
    _chargerSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMapTheme() {
    if (mounted) setState(() {});
  }

  // ── Custom Marker ─────────────────────────────────────────────────────────
  Future<void> _loadCustomMarker() async {
    try {
      final marker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(44, 44)),
        'assets/icons/ev_marker.png',
      );
      if (mounted) {
        setState(() {
          _customMarker = marker;
        });
      }
    } catch (_) {
      // Fall back to default marker
    }
  }

  // ── Chargers Stream + Seed ────────────────────────────────────────────────
  Future<void> _initChargers() async {
    final exists = await _chargerService.chargersExist();
    if (!exists) {
      await _chargerService.seedChargers();
    }

    _chargerSubscription = _chargerService.chargerStream().listen(
      (chargers) {
        if (!mounted) return;
        setState(() {
          _allChargers = chargers;
          _applyFilters();
          _isLoading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
    );
  }

  // ── Filtering ─────────────────────────────────────────────────────────────
  void _applyFilters() {
    _filteredChargers = _allChargers.where((charger) {
      if (_filter.availableOnly && !charger.isAvailable) return false;

      if (_filter.chargerType != 'All' &&
          charger.chargerType.toUpperCase() !=
              _filter.chargerType.toUpperCase()) {
        return false;
      }

      if (_filter.connectorType != 'All' &&
          !charger.connectorType
              .toUpperCase()
              .contains(_filter.connectorType.toUpperCase())) {
        return false;
      }

      if (_filter.minPowerKw > 0 && charger.powerKw < _filter.minPowerKw) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = charger.name.toLowerCase().contains(query);
        final addressMatch = charger.address.toLowerCase().contains(query);
        if (!nameMatch && !addressMatch) return false;
      }

      return true;
    }).toList();
  }

  // ── Markers ───────────────────────────────────────────────────────────────
  Set<Marker> _buildMarkers() {
    return _filteredChargers.map((charger) {
      return Marker(
        markerId: MarkerId(charger.id),
        position: LatLng(charger.latitude, charger.longitude),
        icon: _customMarker ??
            BitmapDescriptor.defaultMarkerWithHue(
              charger.isAvailable
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
        infoWindow: InfoWindow(
          title: charger.name,
          snippet: '${charger.powerLabel} • ₹${charger.pricePerKwh.toStringAsFixed(0)}/kWh',
          onTap: () => _showDetail(charger),
        ),
        onTap: () => _showDetail(charger),
      );
    }).toSet();
  }

  // ── Bottom sheet: Charger Detail ──────────────────────────────────────────
  void _showDetail(ChargerModel charger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChargerDetailSheet(charger: charger),
    );
  }

  // ── Bottom sheet: Filter ──────────────────────────────────────────────────
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        initialFilter: _filter,
        onApply: (newFilter) {
          setState(() {
            _filter = newFilter;
            _applyFilters();
          });
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
      // Fallback
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
            style: ThemeService.isDark(context) ? MapStyles.darkMapStyle : null,
            onMapCreated: (controller) {
              _mapController = controller;
              _goToMyLocation();
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
          ),

          // ── Top Glass Overlay: Search & Actions ─────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Glass Search Bar
                  Expanded(
                    child: GlassContainer(
                      height: 52,
                      borderRadius: BorderRadius.circular(18),
                      blur: 20,
                      opacity: 0.35,
                      color: const Color(0xFF0B132B),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        },
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        cursorColor: const Color(0xFF00E676),
                        decoration: InputDecoration(
                          hintText: 'Search EV charging stations...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF00E676),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Glass Filter button
                  GlassContainer(
                    width: 50,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                    blur: 20,
                    opacity: _filter.isActive ? 0.45 : 0.35,
                    color: _filter.isActive ? const Color(0xFF00E676) : const Color(0xFF0B132B),
                    borderColor: _filter.isActive ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.25),
                    glowColor: _filter.isActive ? const Color(0xFF00E676) : null,
                    onTap: _openFilterSheet,
                    child: Icon(
                      Icons.tune_rounded,
                      color: _filter.isActive ? const Color(0xFF0B132B) : Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Glass My Bookings button
                  GlassContainer(
                    width: 50,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                    blur: 20,
                    opacity: 0.35,
                    color: const Color(0xFF0B132B),
                    onTap: () => Navigator.pushNamed(context, '/my-bookings'),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF00E676),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Glass Theme Toggle button
                  GlassContainer(
                    width: 48,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                    blur: 20,
                    opacity: 0.35,
                    color: const Color(0xFF0B132B),
                    onTap: () => ThemeService.toggleTheme(),
                    child: Icon(
                      ThemeService.isDark(context)
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      color: ThemeService.isDark(context)
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF00E5FF),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Glass Logout button
                  GlassContainer(
                    width: 48,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                    blur: 20,
                    opacity: 0.35,
                    color: const Color(0xFF0B132B),
                    onTap: _logout,
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Loading overlay ─────────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF00E676)),
              ),
            ),

          // ── Bottom Glass Cards & Smart Actions Strip ─────────────────────
          if (!_isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomStrip(),
            ),
        ],
      ),

      // ── Floating GPS Button in Crystal Glass ────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 230),
        child: GlassContainer(
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(16),
          blur: 20,
          opacity: 0.4,
          color: const Color(0xFF0B132B),
          glowColor: const Color(0xFF00E676),
          onTap: _goToMyLocation,
          child: const Center(
            child: Icon(Icons.my_location_rounded, color: Color(0xFF00E676), size: 22),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomStrip() {
    if (_filteredChargers.isEmpty) {
      return GlassContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        borderRadius: BorderRadius.circular(20),
        blur: 20,
        opacity: 0.35,
        color: const Color(0xFF0B132B),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 10),
            Text(
              'No chargers match your filters',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Smart Feature Glass Pill Action Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildSmartPill(
                  icon: Icons.auto_awesome_rounded,
                  label: "AI Smart Match",
                  color: const Color(0xFF00E676),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => SmartRecommendationSheet(
                        allChargers: _allChargers,
                        userLat: 19.0330,
                        userLng: 73.0297,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildSmartPill(
                  icon: Icons.alt_route_rounded,
                  label: "Trip Planner",
                  color: const Color(0xFF00E5FF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TripPlannerScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildSmartPill(
                  icon: Icons.bolt_rounded,
                  label: "Live Session",
                  color: const Color(0xFFFFB300),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveSessionScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(left: 18, bottom: 8),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              borderRadius: BorderRadius.circular(14),
              blur: 16,
              opacity: 0.35,
              color: const Color(0xFF0B132B),
              child: Text(
                '${_filteredChargers.length} station${_filteredChargers.length == 1 ? '' : 's'} nearby',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
              itemCount: _filteredChargers.length,
              itemBuilder: (_, i) => ChargerCard(
                charger: _filteredChargers[i],
                onTap: () {
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

  Widget _buildSmartPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      blur: 20,
      opacity: 0.35,
      color: const Color(0xFF0B132B),
      borderColor: color.withValues(alpha: 0.4),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}