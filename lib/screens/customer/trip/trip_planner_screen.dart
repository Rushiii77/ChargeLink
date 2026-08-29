import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';
import '../../../widgets/glass/glass_text_field.dart';
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
    final isDark = ThemeService.isDark(context);
    final needsChargingStop = _currentEstimatedRangeKm < _tripDistanceKm + 30;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar
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
                      "EV Trip & Route Planner",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Route Form Box
                GlassContainer(
                  tier: GlassTier.secondary,
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      GlassTextField(
                        controller: _originController,
                        labelText: "Starting Point",
                        prefixIcon: Icons.trip_origin_rounded,
                      ),
                      const SizedBox(height: 12),
                      GlassTextField(
                        controller: _destinationController,
                        labelText: "Destination",
                        prefixIcon: Icons.location_on_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Battery Range Slider
                GlassContainer(
                  tier: GlassTier.secondary,
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current Battery Level",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            "${_currentBattery.toInt()}% (~${_currentEstimatedRangeKm.toInt()} km)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF00E676),
                          inactiveTrackColor: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.1),
                          thumbColor: const Color(0xFF00E676),
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
                  GlassContainer(
                    tier: GlassTier.secondary,
                    padding: const EdgeInsets.all(18),
                    borderRadius: BorderRadius.circular(22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _tripMetric("Total Trip", "${_tripDistanceKm.toInt()} km", Icons.route_rounded, isDark),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
                        ),
                        _tripMetric("Est. Duration", "2 hrs 40m", Icons.timer_rounded, isDark),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
                        ),
                        _tripMetric("Stops Needed", needsChargingStop ? "1 Stop" : "0 Stops", Icons.ev_station_rounded, isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Recommended Waypoint Stops",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (needsChargingStop) ...[
                    _buildStopCard(
                      stopNumber: "1",
                      name: "Khalapur Expressway Supercharger",
                      address: "Mumbai-Pune Expressway, KM 42",
                      power: "120 kW DC Fast",
                      suggestedDuration: "20 mins",
                      targetCharge: "Charge from 22% → 85%",
                      isDark: isDark,
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
                    GlassContainer(
                      tier: GlassTier.secondary,
                      padding: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(20),
                      borderColor: const Color(0xFF00E676).withValues(alpha: 0.4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "You have enough battery to reach your destination without stopping!",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w600,
                              ),
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
        ),
      ),
    );
  }

  Widget _tripMetric(String label, String val, IconData icon, bool isDark) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00E676)),
        const SizedBox(height: 6),
        Text(
          val,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStopCard({
    required String stopNumber,
    required String name,
    required String address,
    required String power,
    required String suggestedDuration,
    required String targetCharge,
    required ChargerModel charger,
    required bool isDark,
  }) {
    return GlassContainer(
      tier: GlassTier.secondary,
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stopNumber,
                    style: const TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: isDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                ),
                child: Text(
                  suggestedDuration,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            address,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFFB300)),
                const SizedBox(width: 6),
                Text(
                  "$power • $targetCharge",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          GlassButton(
            text: "PRE-BOOK WAYPOINT CHARGER",
            height: 48,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingScreen(charger: charger)),
              );
            },
          ),
        ],
      ),
    );
  }
}
