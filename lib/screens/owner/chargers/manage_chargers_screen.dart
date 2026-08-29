import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';
import '../add_charger/add_charger_screen.dart';

class ManageChargersScreen extends StatefulWidget {
  const ManageChargersScreen({super.key});

  @override
  State<ManageChargersScreen> createState() => _ManageChargersScreenState();
}

class _ManageChargersScreenState extends State<ManageChargersScreen> {
  final AuthService _authService = AuthService();
  final ChargerService _chargerService = ChargerService();

  Future<void> _toggleAvailability(ChargerModel charger, bool newValue) async {
    try {
      await _chargerService.updateChargerAvailability(charger.id, newValue);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${charger.name} is now ${newValue ? 'Online & Available' : 'Offline / Maintenance'}",
          ),
          backgroundColor: newValue ? AppColors.deepTeal : AppColors.neutralDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteCharger(ChargerModel charger) async {
    final isDark = ThemeService.isDark(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? AppColors.deepTeal.withValues(alpha: 0.3) : AppColors.neutral.withValues(alpha: 0.15)),
        ),
        title: Text(
          "Delete Station",
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to remove '${charger.name}' from the charging network?",
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.neutral)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _chargerService.deleteCharger(charger.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Charging station removed"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isDark = ThemeService.isDark(context);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Please login to manage chargers",
            style: TextStyle(color: isDark ? AppColors.darkText : AppColors.neutralDark),
          ),
        ),
      );
    }

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
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
                      "My Charging Stations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Charger Stream
              Expanded(
                child: StreamBuilder<List<ChargerModel>>(
                  stream: _chargerService.streamOwnerChargers(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.deepTeal),
                      );
                    }

                    final chargers = snapshot.data ?? [];

                    if (chargers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.ev_station_rounded,
                                  size: 48,
                                  color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "No Charging Stations Listed",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Start earning by registering your EV charger onto the live network.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GlassButton(
                                text: "ADD FIRST CHARGER",
                                width: 220,
                                icon: Icons.add_rounded,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddChargerScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: chargers.length,
                      itemBuilder: (ctx, index) => _buildOwnerChargerCard(chargers[index], isDark),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.deepTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text("ADD CHARGER", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddChargerScreen()),
          );
        },
      ),
    );
  }

  Widget _buildOwnerChargerCard(ChargerModel charger, bool isDark) {
    return GlassContainer(
      tier: GlassTier.secondary,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      borderColor: charger.isAvailable
          ? AppColors.deepTeal.withValues(alpha: isDark ? 0.40 : 0.30)
          : (isDark ? AppColors.neutral.withValues(alpha: 0.15) : AppColors.neutral.withValues(alpha: 0.10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? AppColors.deepTeal.withValues(alpha: isDark ? 0.35 : 0.12)
                      : AppColors.error.withValues(alpha: isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.ev_station_rounded,
                  color: charger.isAvailable
                      ? (isDark ? AppColors.accentLime : AppColors.deepTeal)
                      : AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      charger.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.neutralDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      charger.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                onPressed: () => _deleteCharger(charger),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isDark ? AppColors.neutral.withValues(alpha: 0.2) : AppColors.neutral.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 12),

          // Specs Row
          Row(
            children: [
              Text(
                "${charger.powerKw.toInt()} kW ${charger.chargerType}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withValues(alpha: isDark ? 0.25 : 0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  charger.connectorType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "₹${charger.pricePerKwh.toStringAsFixed(0)} / kWh",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Live Availability Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard.withValues(alpha: 0.6) : AppColors.lightBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: charger.isAvailable ? AppColors.accentLime : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      charger.isAvailable ? "Live & Ready for Bookings" : "Offline (Maintenance)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: charger.isAvailable,
                  activeTrackColor: AppColors.deepTeal.withValues(alpha: 0.5),
                  activeThumbColor: isDark ? AppColors.accentLime : AppColors.deepTeal,
                  onChanged: (val) => _toggleAvailability(charger, val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
