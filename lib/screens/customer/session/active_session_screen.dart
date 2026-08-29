import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';

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
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: const Text("Stop Charging?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Your charging session will be finalized and a digital settlement receipt will be generated.",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Continue Charging", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade400,
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        padding: const EdgeInsets.all(28),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        blur: 28,
        opacity: 0.45,
        color: const Color(0xFF0B132B),
        borderColor: Colors.white.withValues(alpha: 0.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E676), width: 1.5),
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              "Charging Session Complete",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _activeCharger.name,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              blur: 16,
              opacity: 0.1,
              child: Column(
                children: [
                  _receiptRow("Duration", _formatTime(_elapsedSeconds)),
                  const SizedBox(height: 8),
                  _receiptRow("Energy Delivered", "${_energyDeliveredKwh.toStringAsFixed(2)} kWh"),
                  const SizedBox(height: 8),
                  _receiptRow("Average Power", "${_activeCharger.powerKw.toInt()} kW"),
                  Divider(height: 24, color: Colors.white.withValues(alpha: 0.15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Settled", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(
                        "₹${_currentCost.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassButton(
              text: "DONE",
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
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
        Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65))),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentBattery / 100.0).clamp(0.0, 1.0);

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                // Top App Bar
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
                      "Live Charging Telemetry",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Station Pill Banner
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: BorderRadius.circular(20),
                  blur: 16,
                  opacity: 0.12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.ev_station_rounded, color: Color(0xFF00E676), size: 18),
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
                RepaintBoundary(
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse animation glow
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (ctx, child) {
                            return Container(
                              width: 190 + (_pulseController.value * 20),
                              height: 190 + (_pulseController.value * 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00E676).withValues(alpha: 0.12 * _pulseController.value),
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
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                            strokeCap: StrokeCap.round,
                          ),
                        ),

                        // Inside Info
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 36, color: Color(0xFF00E676)),
                            const SizedBox(height: 2),
                            Text(
                              "${_currentBattery.toInt()}%",
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Target ${_targetBattery.toInt()}%",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.65),
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
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  blur: 20,
                  opacity: 0.12,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildLiveTile(
                            icon: Icons.electric_bolt_rounded,
                            color: const Color(0xFFFFB300),
                            label: "Energy Delivered",
                            value: "${_energyDeliveredKwh.toStringAsFixed(2)} kWh",
                          ),
                          _buildLiveTile(
                            icon: Icons.speed_rounded,
                            color: const Color(0xFF00E5FF),
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
                            color: const Color(0xFF00E676),
                            label: "Session Time",
                            value: _formatTime(_elapsedSeconds),
                          ),
                          _buildLiveTile(
                            icon: Icons.currency_rupee_rounded,
                            color: const Color(0xFFF43F5E),
                            label: "Running Total",
                            value: "₹${_currentCost.toStringAsFixed(0)}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stop Charging CTA Button
                GlassButton(
                  text: "STOP CHARGING & SETTLE",
                  color: Colors.redAccent.shade400,
                  icon: Icons.power_settings_new_rounded,
                  onPressed: _stopCharging,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
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
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65)),
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
