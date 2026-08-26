import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../widgets/glass/glass_background.dart';
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
          backgroundColor: newValue ? const Color(0xFF00E676) : const Color(0xFF0B132B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteCharger(ChargerModel charger) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: const Text("Delete Station", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to remove '${charger.name}' from the quantum grid?",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade400,
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
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to manage chargers", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
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
                      "My Charging Stations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Chargers Stream
              Expanded(
                child: StreamBuilder<List<ChargerModel>>(
                  stream: _chargerService.streamOwnerChargers(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF00E676)),
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
                              GlassContainer(
                                width: 88,
                                height: 88,
                                borderRadius: BorderRadius.circular(28),
                                blur: 16,
                                opacity: 0.1,
                                child: const Icon(
                                  Icons.ev_station_rounded,
                                  size: 48,
                                  color: Color(0xFF00E676),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "No Stations Listed",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Publish your EV charger to start accepting driver bookings and earning revenue.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: chargers.length,
                      itemBuilder: (ctx, index) {
                        final charger = chargers[index];
                        return _buildChargerHostCard(charger);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        borderRadius: BorderRadius.circular(26),
        blur: 20,
        opacity: 0.8,
        color: const Color(0xFF00E676),
        borderColor: Colors.white.withValues(alpha: 0.4),
        glowColor: const Color(0xFF00E676),
        glowSpread: 2,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddChargerScreen()),
          );
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Color(0xFF0B132B), size: 22),
            SizedBox(width: 8),
            Text(
              "Add Charger",
              style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargerHostCard(ChargerModel charger) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      blur: 20,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  charger.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Switch.adaptive(
                value: charger.isAvailable,
                activeTrackColor: const Color(0xFF00E676).withValues(alpha: 0.5),
                activeThumbColor: const Color(0xFF00E676),
                onChanged: (val) => _toggleAvailability(charger, val),
              ),
            ],
          ),

          const SizedBox(height: 2),

          Text(
            charger.address,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),

          // Specs badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                ),
                child: Text(
                  charger.powerLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E676),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                ),
                child: Text(
                  charger.connectorType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "₹${charger.pricePerKwh.toStringAsFixed(0)} / kWh",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating + Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                  const SizedBox(width: 4),
                  Text(
                    charger.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "(${charger.totalReviews} reviews)",
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.shade200, size: 20),
                tooltip: "Delete Station",
                onPressed: () => _deleteCharger(charger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
