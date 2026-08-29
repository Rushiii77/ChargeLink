import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/charger_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_container.dart';

class HostAnalyticsScreen extends StatelessWidget {
  const HostAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final chargerService = ChargerService();
    final user = authService.currentUser;
    final isDark = ThemeService.isDark(context);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text("Please login first", style: TextStyle(color: isDark ? AppColors.darkText : AppColors.neutralDark)),
        ),
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
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Bar
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
                              "Revenue & Power Analytics",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkText : AppColors.neutralDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Revenue Hero Glass Banner
                        GlassContainer(
                          tier: GlassTier.primary,
                          padding: const EdgeInsets.all(22),
                          borderRadius: BorderRadius.circular(28),
                          glowColor: AppColors.accentLime,
                          glowSpread: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Gross Revenue",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.deepTeal.withValues(alpha: 0.35)
                                          : AppColors.accentLime.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.trending_up_rounded, size: 14, color: isDark ? AppColors.accentLime : AppColors.deepTeal),
                                        const SizedBox(width: 4),
                                        Text(
                                          "+18.4%",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.accentLime : AppColors.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "₹${totalGrossEarnings.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Divider(
                                height: 1,
                                color: isDark ? AppColors.neutral.withValues(alpha: 0.2) : AppColors.neutral.withValues(alpha: 0.12),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _analyticMetric("Power Dispensed", "${totalKwhDelivered.toStringAsFixed(1)} kWh", isDark),
                                  _analyticMetric("Completed Slots", "$completedSessions", isDark),
                                  _analyticMetric("Host Score", "4.9 ★", isDark),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          "Station Performance",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.neutralDark,
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (myChargers.isEmpty)
                          GlassContainer(
                            tier: GlassTier.secondary,
                            padding: const EdgeInsets.all(20),
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                              child: Text(
                                "No stations listed yet to track analytics.",
                                style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.neutral),
                              ),
                            ),
                          )
                        else
                          ...myChargers.map((charger) {
                            final stationBookings = hostBookings.where((b) => b.chargerId == charger.id).toList();
                            double stationRevenue = 0;
                            for (var b in stationBookings) {
                              stationRevenue += b.totalAmount;
                            }

                            return GlassContainer(
                              tier: GlassTier.secondary,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.deepTeal.withValues(alpha: isDark ? 0.35 : 0.10),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.ev_station_rounded, color: isDark ? AppColors.accentLime : AppColors.deepTeal, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          charger.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.darkText : AppColors.neutralDark,
                                          ),
                                        ),
                                        Text(
                                          "${stationBookings.length} total bookings",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${stationRevenue.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 24),
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

  Widget _analyticMetric(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.neutral),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.neutralDark,
          ),
        ),
      ],
    );
  }
}
