import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
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
          backgroundColor: newValue ? const Color(0xFF00C853) : const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteCharger(ChargerModel charger) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Charger"),
        content: Text("Are you sure you want to remove '${charger.name}' from ChargeLink?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
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
        const SnackBar(
          content: Text("Charger station removed"),
          backgroundColor: Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Chargers")),
        body: const Center(child: Text("Please login to manage chargers")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "My Charging Stations",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<ChargerModel>>(
        stream: _chargerService.streamOwnerChargers(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
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
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8FFF0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.ev_station_rounded,
                        size: 56,
                        color: Color(0xFF00C853),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "No Stations Listed Yet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "List your EV charger on ChargeLink to start accepting bookings and earning revenue.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text("List a Charger Now", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddChargerScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chargers.length,
            itemBuilder: (ctx, index) {
              final charger = chargers[index];
              return _buildChargerHostCard(charger);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00C853),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Add Charger", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddChargerScreen()),
          );
        },
      ),
    );
  }

  Widget _buildChargerHostCard(ChargerModel charger) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Name + Availability Switch
            Row(
              children: [
                Expanded(
                  child: Text(
                    charger.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: charger.isAvailable,
                  activeTrackColor: const Color(0xFF00C853).withValues(alpha: 0.5),
                  activeThumbColor: const Color(0xFF00C853),
                  onChanged: (val) => _toggleAvailability(charger, val),
                ),
              ],
            ),

            const SizedBox(height: 2),

            // Address
            Text(
              charger.address,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 14),

            // Specs badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    charger.powerLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C853),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    charger.connectorType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "₹${charger.pricePerKwh.toStringAsFixed(0)} / kWh",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Footer Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      charger.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "(${charger.totalReviews} reviews)",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                  tooltip: "Delete Station",
                  onPressed: () => _deleteCharger(charger),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
