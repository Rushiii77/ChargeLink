import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_container.dart';
import '../add_charger/add_charger_screen.dart';
import '../analytics/host_analytics_screen.dart';
import '../bookings/host_bookings_screen.dart';
import '../chargers/manage_chargers_screen.dart';
import '../profile/host_profile_screen.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  final AuthService _authService = AuthService();
  final ChargerService _chargerService = ChargerService();

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to sign out from ChargeLink Host Hub?",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please sign in", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      body: GlassBackground(
        child: StreamBuilder<List<ChargerModel>>(
          stream: _chargerService.streamOwnerChargers(user.uid),
          builder: (context, chargerSnapshot) {
            final myChargers = chargerSnapshot.data ?? [];
            final myChargerIds = myChargers.map((c) => c.id).toSet();

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              builder: (context, bookingSnapshot) {
                final allDocs = bookingSnapshot.data?.docs ?? [];
                final hostBookings = allDocs
                    .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .where((b) => myChargerIds.contains(b.chargerId))
                    .toList();

                final now = DateTime.now();
                final todayBookings = hostBookings.where((b) {
                  return b.startTime.year == now.year &&
                      b.startTime.month == now.month &&
                      b.startTime.day == now.day;
                }).length;

                double totalRevenue = 0;
                for (var b in hostBookings) {
                  if (b.status.toLowerCase() == 'completed') {
                    totalRevenue += b.totalAmount;
                  }
                }

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GlassContainer(
                                  width: 46,
                                  height: 46,
                                  borderRadius: BorderRadius.circular(14),
                                  blur: 16,
                                  opacity: 0.15,
                                  glowColor: const Color(0xFF00E676),
                                  child: const Center(
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      color: Color(0xFF00E676),
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome back,",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.65),
                                      ),
                                    ),
                                    const Text(
                                      "Station Host Hub",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Logout Button
                            GlassContainer(
                              width: 44,
                              height: 44,
                              borderRadius: BorderRadius.circular(14),
                              blur: 16,
                              opacity: 0.1,
                              onTap: _logout,
                              child: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Frosted Stats Glass Card
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          borderRadius: BorderRadius.circular(24),
                          blur: 24,
                          opacity: 0.14,
                          glowColor: const Color(0xFF00E676),
                          glowSpread: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                "${myChargers.length}",
                                "My Chargers",
                                Icons.ev_station_rounded,
                                const Color(0xFF00E676),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              _buildStatItem(
                                "$todayBookings",
                                "Today's Slots",
                                Icons.bolt_rounded,
                                const Color(0xFF00E5FF),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              _buildStatItem(
                                "₹${totalRevenue.toStringAsFixed(0)}",
                                "Total Revenue",
                                Icons.account_balance_wallet_rounded,
                                const Color(0xFFFFB300),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Section Title
                        const Text(
                          "Station Operations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Glass Action Tiles
                        _buildActionGlassTile(
                          title: "Add New Charger",
                          subtitle: "Publish a high-speed EV charging point to the map",
                          icon: Icons.add_circle_outline_rounded,
                          color: const Color(0xFF00E676),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddChargerScreen()),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildActionGlassTile(
                          title: "Manage Chargers",
                          subtitle: "View pricing, power specs, and toggle availability switch",
                          icon: Icons.electrical_services_rounded,
                          color: const Color(0xFF00E5FF),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageChargersScreen()),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildActionGlassTile(
                          title: "Booking Requests & PIN Check-in",
                          subtitle: "Verify driver 4-digit PIN and activate charging sessions",
                          icon: Icons.calendar_month_rounded,
                          color: const Color(0xFFFFB300),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HostBookingsScreen()),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildActionGlassTile(
                          title: "Analytics & Earnings",
                          subtitle: "Real-time revenue, kWh power dispensed, and driver ratings",
                          icon: Icons.insights_rounded,
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HostAnalyticsScreen()),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildActionGlassTile(
                          title: "Station Host Profile",
                          subtitle: "Manage business profile, contact number, and payouts",
                          icon: Icons.store_rounded,
                          color: const Color(0xFF10B981),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HostProfileScreen()),
                            );
                          },
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGlassTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      blur: 20,
      opacity: 0.1,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: 22,
          ),
        ],
      ),
    );
  }
}
