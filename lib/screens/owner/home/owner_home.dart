import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../services/theme_service.dart';
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
    final isDark = ThemeService.isDark(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0B132B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
        ),
        title: Text(
          "Log Out",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to sign out from ChargeLink Host Hub?",
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF475569),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B))),
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
    final isDark = ThemeService.isDark(context);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Please sign in",
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
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
                    physics: const BouncingScrollPhysics(),
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
                                  opacity: isDark ? 0.15 : 0.85,
                                  color: isDark ? Colors.white : Colors.white,
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
                                        color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      "Station Host Hub",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Actions: Theme toggle + Logout
                            Row(
                              children: [
                                GlassContainer(
                                  width: 44,
                                  height: 44,
                                  borderRadius: BorderRadius.circular(14),
                                  blur: 16,
                                  opacity: isDark ? 0.1 : 0.85,
                                  color: isDark ? Colors.white : Colors.white,
                                  onTap: () => ThemeService.toggleTheme(),
                                  child: Icon(
                                    isDark
                                        ? Icons.wb_sunny_rounded
                                        : Icons.nightlight_round,
                                    color: isDark
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFF3395FF),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GlassContainer(
                                  width: 44,
                                  height: 44,
                                  borderRadius: BorderRadius.circular(14),
                                  blur: 16,
                                  opacity: isDark ? 0.1 : 0.85,
                                  color: isDark ? Colors.white : Colors.white,
                                  onTap: _logout,
                                  child: Icon(
                                    Icons.logout_rounded,
                                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Frosted Stats Glass Card
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          borderRadius: BorderRadius.circular(24),
                          blur: 20,
                          opacity: isDark ? 0.14 : 0.9,
                          color: isDark ? Colors.white : Colors.white,
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
                                isDark,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
                              ),
                              _buildStatItem(
                                "$todayBookings",
                                "Today's Slots",
                                Icons.bolt_rounded,
                                const Color(0xFF00E5FF),
                                isDark,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
                              ),
                              _buildStatItem(
                                "₹${totalRevenue.toStringAsFixed(0)}",
                                "Total Revenue",
                                Icons.account_balance_wallet_rounded,
                                const Color(0xFFFFB300),
                                isDark,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Section Title
                        Text(
                          "Station Operations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                          isDark: isDark,
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
                          isDark: isDark,
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
                          isDark: isDark,
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
                          isDark: isDark,
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
                          isDark: isDark,
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

  Widget _buildStatItem(String value, String label, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
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
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      blur: 16,
      opacity: isDark ? 0.1 : 0.85,
      color: isDark ? Colors.white : Colors.white,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF94A3B8),
            size: 22,
          ),
        ],
      ),
    );
  }
}
