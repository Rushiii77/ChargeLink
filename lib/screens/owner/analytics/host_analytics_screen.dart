import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';

class HostAnalyticsScreen extends StatefulWidget {
  const HostAnalyticsScreen({super.key});

  @override
  State<HostAnalyticsScreen> createState() => _HostAnalyticsScreenState();
}

class _HostAnalyticsScreenState extends State<HostAnalyticsScreen> {
  final AuthService _authService = AuthService();
  final ChargerService _chargerService = ChargerService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Analytics")),
        body: const Center(child: Text("Please login first")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Earnings & Analytics",
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
        builder: (context, chargerSnapshot) {
          if (chargerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
          }

          final chargers = chargerSnapshot.data ?? [];
          final chargerIds = chargers.map((c) => c.id).toSet();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
            builder: (context, bookingSnapshot) {
              if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
              }

              final allDocs = bookingSnapshot.data?.docs ?? [];
              final hostBookings = allDocs
                  .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                  .where((b) => chargerIds.contains(b.chargerId))
                  .toList();

              final completedBookings = hostBookings
                  .where((b) => b.status.toLowerCase() == 'completed')
                  .toList();

              double totalRevenue = 0;
              double totalKwh = 0;

              for (var b in completedBookings) {
                totalRevenue += b.totalAmount;
                totalKwh += (b.powerKw * (b.durationMinutes / 60.0));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Revenue Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF1A6B3A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TOTAL REVENUE",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text("Real-time", style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "₹${totalRevenue.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "From ${completedBookings.length} completed charging sessions",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3 Metric Grid
                    Row(
                      children: [
                        _buildMetricTile(
                          icon: Icons.bolt_rounded,
                          color: const Color(0xFFF59E0B),
                          label: "Energy Dispensed",
                          value: "${totalKwh.toStringAsFixed(1)} kWh",
                        ),
                        const SizedBox(width: 12),
                        _buildMetricTile(
                          icon: Icons.ev_station_rounded,
                          color: const Color(0xFF3B82F6),
                          label: "Active Stations",
                          value: "${chargers.length}",
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Section: Station Performance
                    const Text(
                      "Stations Performance",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 12),

                    if (chargers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Center(
                          child: Text("No charging stations listed yet.", style: TextStyle(color: Color(0xFF6B7280))),
                        ),
                      )
                    else
                      ...chargers.map((c) {
                        final stationSessions = completedBookings.where((b) => b.chargerId == c.id).length;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8FFF0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.ev_station_rounded, color: Color(0xFF00C853), size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                                    ),
                                    Text(
                                      "$stationSessions sessions completed",
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "★ ${c.rating.toStringAsFixed(1)}",
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
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
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

