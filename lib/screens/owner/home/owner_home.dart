import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to sign out from ChargeLink?"),
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
      return Scaffold(
        appBar: AppBar(title: const Text("Host Dashboard")),
        body: const Center(child: Text("Please sign in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<List<ChargerModel>>(
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

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Gradient Header with Dashboard Stats
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF1A6B3A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top App Bar row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.storefront_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Welcome back,",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(alpha: 0.85),
                                          ),
                                        ),
                                        const Text(
                                          "Station Host",
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

                                // Logout Icon Button
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.logout_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: _logout,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Quick Stats Card
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    "${myChargers.length}",
                                    "My Chargers",
                                    Icons.ev_station_rounded,
                                    const Color(0xFF00C853),
                                  ),
                                  Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                                  _buildStatItem(
                                    "$todayBookings",
                                    "Today's Slots",
                                    Icons.bolt_rounded,
                                    const Color(0xFF3B82F6),
                                  ),
                                  Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                                  _buildStatItem(
                                    "₹${totalRevenue.toStringAsFixed(0)}",
                                    "Total Revenue",
                                    Icons.account_balance_wallet_rounded,
                                    const Color(0xFFF59E0B),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main Actions Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Station Operations",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),

                          const SizedBox(height: 14),

                          _buildActionCard(
                            title: "Add New Charger",
                            subtitle: "List a new EV charging point on ChargeLink map",
                            icon: Icons.add_circle_outline_rounded,
                            color: const Color(0xFF00C853),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddChargerScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildActionCard(
                            title: "Manage Chargers",
                            subtitle: "View pricing, power specs, and toggle availability",
                            icon: Icons.electrical_services_rounded,
                            color: const Color(0xFF3B82F6),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ManageChargersScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildActionCard(
                            title: "Booking Requests & PIN Check-in",
                            subtitle: "Verify driver check-in PIN and manage active sessions",
                            icon: Icons.calendar_month_rounded,
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HostBookingsScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildActionCard(
                            title: "Analytics & Earnings",
                            subtitle: "Track power delivered, user reviews, and revenue graphs",
                            icon: Icons.insights_rounded,
                            color: const Color(0xFF7C3AED),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HostAnalyticsScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildActionCard(
                            title: "Station Host Profile",
                            subtitle: "Update business info, phone, and payout accounts",
                            icon: Icons.store_rounded,
                            color: const Color(0xFF0D9488),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HostProfileScreen()),
                              );
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
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
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
