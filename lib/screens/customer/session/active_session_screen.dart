import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';

class ActiveSessionScreen extends StatefulWidget {
  final ChargerModel? charger;

  const ActiveSessionScreen({super.key, this.charger});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Timer _timer;

  double _currentBattery = 34.0;
  final double _targetBattery = 85.0;
  double _energyDeliveredKwh = 3.2;
  double _currentCost = 57.6;
  int _elapsedSeconds = 245;

  late ChargerModel _activeCharger;

  @override
  void initState() {
    super.initState();

    _activeCharger = widget.charger ??
        ChargerModel(
          id: 'demo',
          ownerId: 'demo',
          name: 'Nerul EV Fast Station',
          address: 'Sector 1, Nerul, Navi Mumbai',
          pricePerKwh: 18.0,
          rating: 4.8,
          chargerType: 'DC',
          powerKw: 50.0,
          connectorType: 'CCS2',
          latitude: 19.0342,
          longitude: 73.0285,
        );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        // Simulate energy progression
        if (_currentBattery < _targetBattery) {
          _currentBattery += 0.05;
          _energyDeliveredKwh += 0.02;
          _currentCost = _energyDeliveredKwh * _activeCharger.pricePerKwh;
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _stopCharging() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Stop Charging?"),
        content: const Text("Your battery will stop charging and final receipt will be generated."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Continue Charging", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showReceipt();
            },
            child: const Text("Stop & Pay"),
          ),
        ],
      ),
    );
  }

  void _showReceipt() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE8FFF0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF00C853), size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              "Charging Session Complete",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 6),
            Text(
              _activeCharger.name,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _receiptRow("Duration", _formatTime(_elapsedSeconds)),
                  const SizedBox(height: 8),
                  _receiptRow("Energy Delivered", "${_energyDeliveredKwh.toStringAsFixed(2)} kWh"),
                  const SizedBox(height: 8),
                  _receiptRow("Average Power", "${_activeCharger.powerKw.toInt()} kW"),
                  const Divider(height: 20, color: Color(0xFFE5E7EB)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Paid", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(
                        "₹${_currentCost.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text("Done", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentBattery / 100.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark ambient charging theme
      appBar: AppBar(
        title: const Text(
          "Active Charging Session",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // Station Pill Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.ev_station_rounded, color: Color(0xFF00C853), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _activeCharger.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${_activeCharger.powerLabel})",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Animated Charging Gauge
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (ctx, child) {
                        return Container(
                          width: 190 + (_pulseController.value * 20),
                          height: 190 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00C853).withValues(alpha: 0.08 * _pulseController.value),
                          ),
                        );
                      },
                    ),

                    // Circular Progress Track
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                        strokeCap: StrokeCap.round,
                      ),
                    ),

                    // Inside Info
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 36, color: Color(0xFF00C853)),
                        const SizedBox(height: 2),
                        Text(
                          "${_currentBattery.toInt()}%",
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Target ${_targetBattery.toInt()}%",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Live Metrics 2x2 Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildLiveTile(
                        icon: Icons.electric_bolt_rounded,
                        color: const Color(0xFFF59E0B),
                        label: "Energy Delivered",
                        value: "${_energyDeliveredKwh.toStringAsFixed(2)} kWh",
                      ),
                      _buildLiveTile(
                        icon: Icons.speed_rounded,
                        color: const Color(0xFF3B82F6),
                        label: "Charging Speed",
                        value: "${_activeCharger.powerKw.toInt()} kW",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildLiveTile(
                        icon: Icons.timer_rounded,
                        color: const Color(0xFF00C853),
                        label: "Session Time",
                        value: _formatTime(_elapsedSeconds),
                      ),
                      _buildLiveTile(
                        icon: Icons.currency_rupee_rounded,
                        color: const Color(0xFFE11D48),
                        label: "Running Total",
                        value: "₹${_currentCost.toStringAsFixed(0)}",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Stop Charging CTA Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.power_settings_new_rounded),
                label: const Text(
                  "STOP CHARGING & SETTLE",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                onPressed: _stopCharging,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

