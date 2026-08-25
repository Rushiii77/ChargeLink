import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../booking/booking_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final _originController = TextEditingController(text: 'Nerul, Navi Mumbai');
  final _destinationController = TextEditingController(text: 'Pune City Center');

  double _currentBattery = 35.0;
  final double _vehicleMaxRangeKm = 300.0;
  final bool _isCalculated = true;

  double get _currentEstimatedRangeKm => (_currentBattery / 100.0) * _vehicleMaxRangeKm;
  final double _tripDistanceKm = 142.0;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needsChargingStop = _currentEstimatedRangeKm < _tripDistanceKm + 30; // 30km safety buffer

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "EV Trip & Route Planner",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Form Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Origin
                  TextField(
                    controller: _originController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      prefixIcon: const Icon(Icons.trip_origin_rounded, color: Color(0xFF00C853), size: 20),
                      labelText: "Starting Point",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Destination
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      prefixIcon: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
                      labelText: "Destination",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Battery Range Slider
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Current Battery Level",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                      ),
                      Text(
                        "${_currentBattery.toInt()}% (~${_currentEstimatedRangeKm.toInt()} km)",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF00C853),
                      inactiveTrackColor: const Color(0xFFE5E7EB),
                      thumbColor: const Color(0xFF00C853),
                    ),
                    child: Slider(
                      value: _currentBattery,
                      min: 10,
                      max: 100,
                      divisions: 18,
                      onChanged: (val) => setState(() => _currentBattery = val),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_isCalculated) ...[
              // Trip Summary Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _tripMetric("Total Trip", "${_tripDistanceKm.toInt()} km", Icons.route_rounded),
                    Container(width: 1, height: 36, color: Colors.white24),
                    _tripMetric("Estimated Time", "2 hrs 40m", Icons.timer_rounded),
                    Container(width: 1, height: 36, color: Colors.white24),
                    _tripMetric("Stops Required", needsChargingStop ? "1 Stop" : "0 Stops", Icons.ev_station_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Recommended Waypoint Stops",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 12),

              if (needsChargingStop) ...[
                _buildStopCard(
                  stopNumber: "1",
                  name: "Khalapur Expressway Supercharger",
                  address: "Mumbai-Pune Expressway, KM 42",
                  power: "120 kW DC Fast",
                  connector: "CCS2",
                  suggestedDuration: "20 mins",
                  targetCharge: "Charge from 22% → 85%",
                  charger: ChargerModel(
                    id: 'expressway_1',
                    ownerId: 'seed',
                    name: 'Khalapur Supercharger',
                    address: 'Expressway Food Mall, KM 42',
                    pricePerKwh: 21.0,
                    rating: 4.9,
                    chargerType: 'DC',
                    powerKw: 120.0,
                    connectorType: 'CCS2',
                    latitude: 18.8350,
                    longitude: 73.2840,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF00C853)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "You have enough battery to reach your destination without stopping!",
                          style: TextStyle(fontSize: 13, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _tripMetric(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00C853)),
        const SizedBox(height: 6),
        Text(
          val,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildStopCard({
    required String stopNumber,
    required String name,
    required String address,
    required String power,
    required String connector,
    required String suggestedDuration,
    required String targetCharge,
    required ChargerModel charger,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stopNumber,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  suggestedDuration,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(address, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Text(
                  "$power • $targetCharge",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingScreen(charger: charger)),
                );
              },
              child: const Text("Pre-Book This Waypoint Slot", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
