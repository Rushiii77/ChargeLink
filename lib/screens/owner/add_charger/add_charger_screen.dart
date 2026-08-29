import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';
import '../../../widgets/glass/glass_text_field.dart';

class AddChargerScreen extends StatefulWidget {
  const AddChargerScreen({super.key});

  @override
  State<AddChargerScreen> createState() => _AddChargerScreenState();
}

class _AddChargerScreenState extends State<AddChargerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController(text: '18');
  final _latController = TextEditingController(text: '19.0330');
  final _lngController = TextEditingController(text: '73.0297');

  final AuthService _authService = AuthService();
  final ChargerService _chargerService = ChargerService();

  String _selectedChargerType = 'DC';
  double _selectedPowerKw = 50.0;
  String _selectedConnector = 'CCS2';
  bool _isLoading = false;

  final List<double> _powerOptions = [7.4, 11.0, 22.0, 50.0, 120.0];
  final List<String> _connectorOptions = ['CCS2', 'Type2', 'CHAdeMO'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _showToast("Location permission permanently denied", isError: true);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(5);
        _lngController.text = position.longitude.toStringAsFixed(5);
      });

      _showToast("Coordinates updated from device GPS");
    } catch (_) {
      _showToast("Using default Navi Mumbai coordinates");
    }
  }

  Future<void> _publishCharger() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) {
      _showToast("Please login first", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final address = _addressController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 18.0;
      final lat = double.tryParse(_latController.text.trim()) ?? 19.0330;
      final lng = double.tryParse(_lngController.text.trim()) ?? 73.0297;

      await _chargerService.addCharger(
        ownerId: user.uid,
        name: name,
        address: address,
        pricePerKwh: price,
        chargerType: _selectedChargerType,
        powerKw: _selectedPowerKw,
        connectorType: _selectedConnector,
        latitude: lat,
        longitude: lng,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚡ Charger published to the live network!"),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showToast("Failed to add charger: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    children: [
                      GlassContainer(
                        tier: GlassTier.tertiary,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(14),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "Add EV Charging Station",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Section 1: Basic Information
                  _buildSectionTitle("1. Station Details", isDark),
                  const SizedBox(height: 10),
                  GlassContainer(
                    tier: GlassTier.secondary,
                    padding: const EdgeInsets.all(18),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        GlassTextField(
                          controller: _nameController,
                          labelText: "Station Name",
                          hintText: "e.g. Apex Fast EV Hub",
                          prefixIcon: Icons.ev_station_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Please enter station name"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        GlassTextField(
                          controller: _addressController,
                          labelText: "Full Location Address",
                          hintText: "e.g. Sector 19, Seawoods, Navi Mumbai",
                          prefixIcon: Icons.location_on_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Please enter address"
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 2: Technical Specifications
                  _buildSectionTitle("2. Power & Charging Specs", isDark),
                  const SizedBox(height: 10),
                  GlassContainer(
                    tier: GlassTier.secondary,
                    padding: const EdgeInsets.all(18),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current Standard",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: ['DC', 'AC'].map((type) {
                            final isSelected = _selectedChargerType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ChoiceChip(
                                label: Text(type == 'DC' ? 'DC Fast Charging' : 'AC Standard'),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedChargerType = type),
                                selectedColor: const Color(0xFF00E676).withValues(alpha: isDark ? 0.25 : 0.2),
                                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF00E676) : const Color(0xFF00A040))
                                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF00E676) : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "Power Output Rating (kW)",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _powerOptions.map((kw) {
                              final isSelected = _selectedPowerKw == kw;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text("${kw.toInt()} kW"),
                                  selected: isSelected,
                                  onSelected: (_) => setState(() => _selectedPowerKw = kw),
                                  selectedColor: const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.25 : 0.2),
                                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF00B4D8)
                                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: isSelected ? const Color(0xFF00E5FF) : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "Connector Port Type",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _connectorOptions.map((conn) {
                            final isSelected = _selectedConnector == conn;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(conn),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedConnector = conn),
                                selectedColor: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.25 : 0.2),
                                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF8B5CF6)
                                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 3: Pricing & Location Coordinates
                  _buildSectionTitle("3. Pricing & Coordinates", isDark),
                  const SizedBox(height: 10),
                  GlassContainer(
                    tier: GlassTier.secondary,
                    padding: const EdgeInsets.all(18),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        GlassTextField(
                          controller: _priceController,
                          labelText: "Tariff Price per kWh (₹)",
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.currency_rupee_rounded,
                          validator: (v) => (v == null || double.tryParse(v) == null)
                              ? "Enter valid price"
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: GlassTextField(
                                controller: _latController,
                                labelText: "Latitude",
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                prefixIcon: Icons.my_location_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GlassTextField(
                                controller: _lngController,
                                labelText: "Longitude",
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                prefixIcon: Icons.explore_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _fetchCurrentLocation,
                          icon: const Icon(Icons.gps_fixed_rounded, size: 16, color: Color(0xFF00E676)),
                          label: Text(
                            "Auto-detect GPS coordinates",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Submit Button
                  GlassButton(
                    text: "PUBLISH CHARGER TO NETWORK",
                    isLoading: _isLoading,
                    icon: Icons.cloud_upload_rounded,
                    onPressed: _publishCharger,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        letterSpacing: 0.5,
      ),
    );
  }
}
