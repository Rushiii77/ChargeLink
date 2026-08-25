import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';

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
      // Fallback
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8FFF0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00C853),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Charger Published!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "'$name' is now live on the ChargeLink map for all EV drivers.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text("Go to Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
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
        backgroundColor: isError ? Colors.red.shade400 : const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "List New Charger",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Station Name
              _buildLabel("Station / Charger Name"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty ? "Enter station name" : null,
                decoration: _inputDeco(
                  hint: "e.g., GreenPoint Fast Charging Hub",
                  icon: Icons.ev_station_rounded,
                ),
              ),

              const SizedBox(height: 18),

              // Full Address
              _buildLabel("Location Address"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                validator: (v) => v == null || v.trim().isEmpty ? "Enter location address" : null,
                decoration: _inputDeco(
                  hint: "e.g., Plot 12, Sector 15, Navi Mumbai",
                  icon: Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // GPS Coordinates Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel("Map Coordinates"),
                  TextButton.icon(
                    onPressed: _fetchCurrentLocation,
                    icon: const Icon(Icons.my_location_rounded, size: 16),
                    label: const Text("Use Current GPS", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00C853),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => double.tryParse(v ?? '') == null ? "Valid Lat" : null,
                      decoration: _inputDeco(hint: "Latitude", icon: Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => double.tryParse(v ?? '') == null ? "Valid Long" : null,
                      decoration: _inputDeco(hint: "Longitude", icon: Icons.map_outlined),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Charger Current Type (AC vs DC)
              _buildLabel("Current Type"),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip("DC Fast Charger", "DC"),
                  const SizedBox(width: 12),
                  _buildTypeChip("AC Standard Charger", "AC"),
                ],
              ),

              const SizedBox(height: 22),

              // Power Output (kW)
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
                        selectedColor: const Color(0xFFE8FFF0),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF00C853) : const Color(0xFF1A1A2E),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 22),

              // Connector Type
              _buildLabel("Connector Standard"),
              const SizedBox(height: 8),
              Row(
                children: _connectorOptions.map((conn) {
                  final isSelected = conn == _selectedConnector;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(conn),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedConnector = conn),
                      selectedColor: const Color(0xFFE8FFF0),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF00C853) : const Color(0xFF1A1A2E),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // Pricing Rate (₹ / kWh)
              _buildLabel("Price Rate (₹ per kWh)"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => double.tryParse(v ?? '') == null ? "Enter price per kWh" : null,
                decoration: _inputDeco(hint: "e.g., 18", icon: Icons.currency_rupee_rounded),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                    shadowColor: const Color(0xFF00C853).withValues(alpha: 0.4),
                  ),
                  onPressed: _isLoading ? null : _publishCharger,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          "PUBLISH CHARGING STATION",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildTypeChip(String label, String type) {
    final isSelected = _selectedChargerType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedChargerType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8FFF0) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF00C853) : const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: const Color(0xFF00C853), size: 20),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

