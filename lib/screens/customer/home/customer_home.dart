import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_colors.dart';
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
    _loadCustomMarkers();
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

  // ── Custom Markers ────────────────────────────────────────────────────────
  BitmapDescriptor? _availableMarker;
  BitmapDescriptor? _busyMarker;

  Future<void> _loadCustomMarkers() async {
    try {
      final availableMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(46, 46)),
        'assets/icons/ev_marker.png',
      );
      final busyMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(46, 46)),
        'assets/icons/ev_marker_busy.png',
      );
      if (mounted) {
        setState(() {
          _availableMarker = availableMarker;
          _busyMarker = busyMarker;
        });
      }
    } catch (_) {
      // Fall back to default markers
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
          charger.connectorType.toUpperCase() !=
              _filter.connectorType.toUpperCase()) {
        return false;
      }

      if (_filter.minPowerKw > 0 && charger.powerKw < _filter.minPowerKw) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = charger.name.toLowerCase().contains(q);
        final matchAddress = charger.address.toLowerCase().contains(q);
        if (!matchName && !matchAddress) return false;
      }

      return true;
    }).toList();
  }

  // ── Map Markers ───────────────────────────────────────────────────────────
  Set<Marker> _buildMarkers() {
    return _filteredChargers.map((charger) {
      return Marker(
        markerId: MarkerId(charger.id),
        position: LatLng(charger.latitude, charger.longitude),
        icon: charger.isAvailable
            ? (_availableMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen))
            : (_busyMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
        infoWindow: InfoWindow(
          title: charger.name,
          snippet:
              '${charger.powerLabel} • ₹${charger.pricePerKwh.toStringAsFixed(0)}/kWh',
          onTap: () => _showDetail(charger),
        ),
        onTap: () => _showDetail(charger),
      );
    }).toSet();
  }

  // ── Detail Sheet ──────────────────────────────────────────────────────────
  void _showDetail(ChargerModel charger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChargerDetailSheet(charger: charger),
    );
  }

  // ── Filter Sheet ──────────────────────────────────────────────────────────
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

  // ── Geolocation (Find My Location) ────────────────────────────────────────
  Future<void> _goToMyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location permission permanently denied. Enable it in app settings.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 15.5),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not obtain current location'),
          backgroundColor: AppColors.error,
        ),
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
    final isDark = ThemeService.isDark(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map with dynamic dark Midnight style ──────────────────
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _buildMarkers(),
            style: isDark ? MapStyles.darkMapStyle : null,
            onMapCreated: (controller) {
              _mapController = controller;
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
                      tier: GlassTier.secondary,
                      height: 52,
                      borderRadius: BorderRadius.circular(18),
                      borderColor: AppColors.deepTeal.withValues(alpha: isDark ? 0.35 : 0.20),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        },
                        style: TextStyle(
                          color: isDark ? AppColors.darkText : AppColors.neutralDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: isDark ? AppColors.accentLime : AppColors.deepTeal,
                        decoration: InputDecoration(
                          hintText: 'Search EV charging stations...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.neutral
                                : AppColors.neutral.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark ? AppColors.accentLime : AppColors.deepTeal,
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
                    tier: GlassTier.secondary,
                    width: 48,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                    color: _filter.isActive ? AppColors.deepTeal : null,
                    borderColor: _filter.isActive
                        ? AppColors.deepTeal
                        : (isDark ? AppColors.deepTeal.withValues(alpha: 0.35) : AppColors.neutral.withValues(alpha: 0.15)),
                    glowColor: _filter.isActive ? AppColors.accentLime : null,
                    onTap: _openFilterSheet,
                    child: Icon(
                      Icons.tune_rounded,
                      color: _filter.isActive
                          ? AppColors.accentLime
                          : (isDark ? AppColors.darkText : AppColors.neutralDark),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Glass My Bookings button
                  GlassContainer(
                    tier: GlassTier.secondary,
                    width: 48,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                    borderColor: isDark ? AppColors.deepTeal.withValues(alpha: 0.35) : AppColors.neutral.withValues(alpha: 0.15),
                    onTap: () => Navigator.pushNamed(context, '/my-bookings'),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Glass Theme Toggle button
                  GlassContainer(
                    tier: GlassTier.secondary,
                    width: 48,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                    borderColor: isDark ? AppColors.deepTeal.withValues(alpha: 0.35) : AppColors.neutral.withValues(alpha: 0.15),
                    onTap: () => ThemeService.toggleTheme(),
                    child: Icon(
                      isDark
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      color: isDark
                          ? const Color(0xFFF59E0B)
                          : AppColors.deepTeal,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Glass Logout button
                  GlassContainer(
                    tier: GlassTier.secondary,
                    width: 48,
                    height: 52,
                    borderRadius: BorderRadius.circular(18),
                    borderColor: isDark ? AppColors.deepTeal.withValues(alpha: 0.35) : AppColors.neutral.withValues(alpha: 0.15),
                    onTap: _logout,
                    child: Icon(
                      Icons.logout_rounded,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
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
                child: CircularProgressIndicator(color: AppColors.deepTeal),
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
          tier: GlassTier.secondary,
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(16),
          glowColor: AppColors.accentLime,
          borderColor: isDark ? AppColors.deepTeal.withValues(alpha: 0.4) : AppColors.deepTeal.withValues(alpha: 0.25),
          onTap: _goToMyLocation,
          child: Center(
            child: Icon(
              Icons.my_location_rounded,
              color: isDark ? AppColors.accentLime : AppColors.deepTeal,
              size: 22,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomStrip() {
    final isDark = ThemeService.isDark(context);

    if (_filteredChargers.isEmpty) {
      return GlassContainer(
        tier: GlassTier.secondary,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral),
            const SizedBox(width: 10),
            Text(
              'No chargers match your filters',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                fontWeight: FontWeight.w500,
              ),
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildSmartPill(
                  icon: Icons.auto_awesome_rounded,
                  label: "AI Smart Match",
                  color: isDark ? AppColors.accentLime : AppColors.deepTeal,
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
                  color: isDark ? AppColors.accentLime : AppColors.primaryLight,
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
                  color: const Color(0xFFF59E0B),
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
              tier: GlassTier.tertiary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              borderRadius: BorderRadius.circular(14),
              child: Text(
                '${_filteredChargers.length} station${_filteredChargers.length == 1 ? '' : 's'} nearby',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
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
    final isDark = ThemeService.isDark(context);

    return GlassContainer(
      tier: GlassTier.tertiary,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      borderColor: color.withValues(alpha: isDark ? 0.40 : 0.30),
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