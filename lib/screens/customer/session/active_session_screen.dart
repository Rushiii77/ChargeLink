import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/charger_model.dart';
import '../../../services/theme_service.dart';
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
    final isDark = ThemeService.isDark(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? AppColors.deepTeal.withValues(alpha: 0.3) : AppColors.neutral.withValues(alpha: 0.15)),
        ),
        title: Text(
          "Stop Charging?",
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Your charging session will be finalized and a digital settlement receipt will be generated.",
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Continue Charging", style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.neutral)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
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
    final isDark = ThemeService.isDark(context);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        tier: GlassTier.primary,
        padding: const EdgeInsets.all(28),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.deepTeal.withValues(alpha: 0.35) : AppColors.accentLime.withValues(alpha: 0.40),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppColors.accentLime : AppColors.deepTeal, width: 1.5),
              ),
              child: Icon(Icons.check_rounded, color: isDark ? AppColors.accentLime : AppColors.deepTeal, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              "Charging Session Complete",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.neutralDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _activeCharger.name,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
              ),
            ),
            const SizedBox(height: 20),
            GlassContainer(
              tier: GlassTier.tertiary,
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  _receiptRow("Duration", _formatTime(_elapsedSeconds), isDark),
                  const SizedBox(height: 8),
                  _receiptRow("Energy Delivered", "${_energyDeliveredKwh.toStringAsFixed(2)} kWh", isDark),
                  const SizedBox(height: 8),
                  _receiptRow("Average Power", "${_activeCharger.powerKw.toInt()} kW", isDark),
                  Divider(height: 24, color: isDark ? AppColors.neutral.withValues(alpha: 0.2) : AppColors.neutral.withValues(alpha: 0.12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Settled",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.neutralDark,
                        ),
                      ),
                      Text(
                        "₹${_currentCost.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                        ),
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

  Widget _receiptRow(String label, String val, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.neutral)),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkText : AppColors.neutralDark)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentBattery / 100.0).clamp(0.0, 1.0);
    final isDark = ThemeService.isDark(context);

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
                      tier: GlassTier.tertiary,
                      width: 44,
                      height: 44,
                      borderRadius: BorderRadius.circular(14),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? AppColors.darkText : AppColors.neutralDark,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "Live Charging Telemetry",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Station Pill Banner
                GlassContainer(
                  tier: GlassTier.tertiary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ev_station_rounded, color: isDark ? AppColors.accentLime : AppColors.deepTeal, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _activeCharger.name,
                        style: TextStyle(
                          color: isDark ? AppColors.darkText : AppColors.neutralDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${_activeCharger.powerLabel})",
                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.neutral, fontSize: 12),
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
                                color: (isDark ? AppColors.accentLime : AppColors.deepTeal)
                                    .withValues(alpha: 0.10 * _pulseController.value),
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
                            backgroundColor: isDark
                                ? AppColors.neutral.withValues(alpha: 0.20)
                                : AppColors.neutral.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? AppColors.accentLime : AppColors.deepTeal,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),

                        // Inside Info
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, size: 36, color: isDark ? AppColors.accentLime : AppColors.deepTeal),
                            const SizedBox(height: 2),
                            Text(
                              "${_currentBattery.toInt()}%",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkText : AppColors.neutralDark,
                              ),
                            ),
                            Text(
                              "Target ${_targetBattery.toInt()}%",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
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
                  tier: GlassTier.secondary,
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildLiveTile(
                            icon: Icons.electric_bolt_rounded,
                            color: const Color(0xFFF59E0B),
                            label: "Energy Delivered",
                            value: "${_energyDeliveredKwh.toStringAsFixed(2)} kWh",
                            isDark: isDark,
                          ),
                          _buildLiveTile(
                            icon: Icons.speed_rounded,
                            color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                            label: "Charging Speed",
                            value: "${_activeCharger.powerKw.toInt()} kW",
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildLiveTile(
                            icon: Icons.timer_rounded,
                            color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                            label: "Session Time",
                            value: _formatTime(_elapsedSeconds),
                            isDark: isDark,
                          ),
                          _buildLiveTile(
                            icon: Icons.currency_rupee_rounded,
                            color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                            label: "Running Total",
                            value: "₹${_currentCost.toStringAsFixed(0)}",
                            isDark: isDark,
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
                  variant: GlassButtonVariant.destructive,
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
    required bool isDark,
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
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.neutral),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.neutralDark,
            ),
          ),
        ],
      ),
    );
  }
}
