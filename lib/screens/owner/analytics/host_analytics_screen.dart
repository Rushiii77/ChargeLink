import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_container.dart';

class HostAnalyticsScreen extends StatelessWidget {
  const HostAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final chargerService = ChargerService();
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login first", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: StreamBuilder<List<ChargerModel>>(
            stream: chargerService.streamOwnerChargers(user.uid),
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

                  double totalGrossEarnings = 0.0;
                  double totalKwhDelivered = 0.0;
                  int completedSessions = 0;

                  for (var b in hostBookings) {
                    if (b.status.toLowerCase() == 'completed' || b.status.toLowerCase() == 'active') {
                      totalGrossEarnings += b.totalAmount;
                      totalKwhDelivered += b.powerKw * (b.durationMinutes / 60.0);
                      if (b.status.toLowerCase() == 'completed') completedSessions++;
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Bar
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
                              "Revenue & Power Analytics",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Revenue Hero Glass Banner
                        GlassContainer(
                          padding: const EdgeInsets.all(22),
                          borderRadius: BorderRadius.circular(28),
                          blur: 24,
                          opacity: 0.16,
                          glowColor: const Color(0xFF00E676),
                          glowSpread: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "GROSS REVENUE",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E676).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                                    ),
                                    child: const Text(
                                      "● Live Escrow",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00E676),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "₹${totalGrossEarnings.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Cumulative gross earnings from all active & completed charging slots.",
                                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 2x2 Telemetry Glass Cards
                        Row(
                          children: [
                            _buildGlassStatCard(
                              title: "Energy Delivered",
                              value: "${totalKwhDelivered.toStringAsFixed(1)} kWh",
                              icon: Icons.bolt_rounded,
                              color: const Color(0xFFFFB300),
                            ),
                            const SizedBox(width: 12),
                            _buildGlassStatCard(
                              title: "Sessions Completed",
                              value: "$completedSessions",
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF00E676),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _buildGlassStatCard(
                              title: "Listed Stations",
                              value: "${myChargers.length}",
                              icon: Icons.ev_station_rounded,
                              color: const Color(0xFF00E5FF),
                            ),
                            const SizedBox(width: 12),
                            _buildGlassStatCard(
                              title: "Avg. Driver Rating",
                              value: myChargers.isEmpty
                                  ? "5.0 ★"
                                  : "${(myChargers.map((c) => c.rating).reduce((a, b) => a + b) / myChargers.length).toStringAsFixed(1)} ★",
                              icon: Icons.star_rounded,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Station Breakdown
                        const Text(
                          "Station Performance",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (myChargers.isEmpty)
                          GlassContainer(
                            padding: const EdgeInsets.all(20),
                            borderRadius: BorderRadius.circular(20),
                            blur: 16,
                            opacity: 0.1,
                            child: const Center(
                              child: Text(
                                "No active stations registered yet.",
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ...myChargers.map((charger) {
                            final stationBookings = hostBookings.where((b) => b.chargerId == charger.id).toList();
                            double stationRevenue = 0;
                            for (var b in stationBookings) {
                              if (b.status.toLowerCase() == 'completed') stationRevenue += b.totalAmount;
                            }

                            return GlassContainer(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(20),
                              blur: 16,
                              opacity: 0.12,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.ev_station_rounded, color: Color(0xFF00E676), size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          charger.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "${charger.powerLabel} • ${stationBookings.length} total sessions",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white.withValues(alpha: 0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${stationRevenue.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00E676),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        blur: 16,
        opacity: 0.12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
