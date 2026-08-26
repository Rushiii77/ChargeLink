import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
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

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0B132B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00E676),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Station Published!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "'$name' is now live on the quantum grid for all EV drivers.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 24),
                GlassButton(
                  text: "GO TO DASHBOARD",
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      _showToast("Error adding charger: $e", isError: true);
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
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(14),
                        blur: 16,
                        opacity: 0.1,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        "List New Station",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Station Name
                  _buildLabel("Station / Charger Name"),
                  const SizedBox(height: 8),
                  GlassTextField(
                    controller: _nameController,
                    labelText: "Station Name",
                    hintText: "e.g. GreenPoint Fast Charging Hub",
                    prefixIcon: Icons.ev_station_rounded,
                    validator: (v) => v == null || v.trim().isEmpty ? "Enter station name" : null,
                  ),

                  const SizedBox(height: 16),

                  // Address
                  _buildLabel("Location Address"),
                  const SizedBox(height: 8),
                  GlassTextField(
                    controller: _addressController,
                    labelText: "Full Address",
                    hintText: "e.g. Plot 12, Sector 15, Navi Mumbai",
                    prefixIcon: Icons.location_on_outlined,
                    validator: (v) => v == null || v.trim().isEmpty ? "Enter location address" : null,
                  ),

                  const SizedBox(height: 16),

                  // GPS Coordinates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel("Map Coordinates"),
                      TextButton.icon(
                        onPressed: _fetchCurrentLocation,
                        icon: const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF00E676)),
                        label: const Text("Use Current GPS", style: TextStyle(fontSize: 12, color: Color(0xFF00E676))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          controller: _latController,
                          labelText: "Latitude",
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassTextField(
                          controller: _lngController,
                          labelText: "Longitude",
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Current Type (AC vs DC)
                  _buildLabel("Current Standard"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTypeChip("DC Fast Charger", "DC"),
                      const SizedBox(width: 12),
                      _buildTypeChip("AC Standard", "AC"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Power Output
                  _buildLabel("Power Output"),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _powerOptions.map((power) {
                        final isSelected = power == _selectedPowerKw;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text("${power % 1 == 0 ? power.toInt() : power} kW"),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedPowerKw = power),
                            selectedColor: const Color(0xFF00E676).withValues(alpha: 0.25),
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFF00E676) : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Connector Type
                  _buildLabel("Connector Standard"),
                  const SizedBox(height: 8),
                  Row(
                    children: _connectorOptions.map((conn) {
                      final isSelected = conn == _selectedConnector;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(conn),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedConnector = conn),
                          selectedColor: const Color(0xFF00E676).withValues(alpha: 0.25),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF00E676) : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Price Rate
                  _buildLabel("Price Rate (₹ per kWh)"),
                  const SizedBox(height: 8),
                  GlassTextField(
                    controller: _priceController,
                    labelText: "Price Rate",
                    hintText: "18",
                    prefixIcon: Icons.currency_rupee_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),

                  const SizedBox(height: 28),

                  // Publish Button
                  GlassButton(
                    text: "PUBLISH CHARGING STATION",
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTypeChip(String label, String type) {
    final isSelected = _selectedChargerType == type;

    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: BorderRadius.circular(18),
        blur: 16,
        opacity: isSelected ? 0.25 : 0.08,
        borderColor: isSelected ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.15),
        onTap: () => setState(() => _selectedChargerType = type),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF00E676) : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
