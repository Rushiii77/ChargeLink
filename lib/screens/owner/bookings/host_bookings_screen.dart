import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/charger_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';

class HostBookingsScreen extends StatefulWidget {
  const HostBookingsScreen({super.key});

  @override
  State<HostBookingsScreen> createState() => _HostBookingsScreenState();
}

class _HostBookingsScreenState extends State<HostBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();
  final ChargerService _chargerService = ChargerService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _verifyPinAndStart(BookingModel booking) {
    final isDark = ThemeService.isDark(context);
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: isDark ? AppColors.deepTeal.withValues(alpha: 0.3) : AppColors.neutral.withValues(alpha: 0.15)),
        ),
        title: Text(
          "Verify Check-in PIN",
          style: TextStyle(color: isDark ? AppColors.darkText : AppColors.neutralDark, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ask driver for the 4-digit PIN generated for ${booking.chargerName}.",
              style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.neutral),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: isDark ? AppColors.accentLime : AppColors.deepTeal,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightBg,
                counterText: "",
                hintText: "••••",
                hintStyle: TextStyle(color: isDark ? AppColors.neutral : AppColors.neutral.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: isDark ? AppColors.deepTeal.withValues(alpha: 0.3) : AppColors.neutral.withValues(alpha: 0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: isDark ? AppColors.accentLime : AppColors.deepTeal, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.neutral)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              final entered = pinController.text.trim();
              if (entered == booking.otpPin) {
                Navigator.pop(ctx);
                await _bookingService.updateBookingStatus(booking.id, 'active');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("✓ PIN Verified! Charging session activated for ${booking.chargerName}."),
                    backgroundColor: AppColors.deepTeal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Invalid PIN entered. Please check with driver."),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text("Verify & Start", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSession(BookingModel booking) async {
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
          "Complete Session?",
          style: TextStyle(color: isDark ? AppColors.darkText : AppColors.neutralDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Mark charging session as completed and settle payment?",
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.neutral),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.neutral)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Complete", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookingService.updateBookingStatus(booking.id, 'completed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Session completed! ₹${booking.totalAmount.toStringAsFixed(0)} settled."),
          backgroundColor: AppColors.deepTeal,
          behavior: SnackBarBehavior.floating,
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
          child: Text("Please login first", style: TextStyle(color: isDark ? AppColors.darkText : AppColors.neutralDark)),
        ),
      );
    }

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
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

                  // Sort by start time
                  hostBookings.sort((a, b) => b.startTime.compareTo(a.startTime));

                  final incoming = hostBookings
                      .where((b) => b.status.toLowerCase() == 'confirmed')
                      .toList();

                  final inProgress = hostBookings
                      .where((b) => b.status.toLowerCase() == 'active')
                      .toList();

                  final past = hostBookings
                      .where((b) =>
                          b.status.toLowerCase() == 'completed' ||
                          b.status.toLowerCase() == 'cancelled')
                      .toList();

                  return Column(
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
                              "Host Booking Dispatch",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkText : AppColors.neutralDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tab Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: GlassContainer(
                          tier: GlassTier.secondary,
                          borderRadius: BorderRadius.circular(18),
                          padding: const EdgeInsets.all(4),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: AppColors.deepTeal,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepTeal.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: isDark ? AppColors.accentLime : Colors.white,
                            unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            tabs: [
                              Tab(text: "Incoming (${incoming.length})"),
                              Tab(text: "In Progress (${inProgress.length})"),
                              Tab(text: "Past (${past.length})"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tabs Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildHostBookingList(incoming, "No incoming driver slots", isDark),
                            _buildHostBookingList(inProgress, "No active charging sessions", isDark),
                            _buildHostBookingList(past, "No past sessions recorded", isDark),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHostBookingList(List<BookingModel> bookings, String emptyMessage, bool isDark) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 40,
                color: isDark ? AppColors.accentLime : AppColors.deepTeal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.neutralDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: bookings.length,
      itemBuilder: (ctx, index) => _buildHostBookingCard(bookings[index], isDark),
    );
  }

  Widget _buildHostBookingCard(BookingModel booking, bool isDark) {
    Color statusColor;

    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = isDark ? AppColors.accentLime : AppColors.deepTeal;
        break;
      case 'active':
        statusColor = AppColors.primaryLight;
        break;
      case 'completed':
        statusColor = isDark ? AppColors.darkTextSecondary : AppColors.neutral;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = isDark ? AppColors.darkTextSecondary : AppColors.neutral;
    }

    final dateStr =
        "${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year}";
    final startTimeStr =
        "${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}";
    final endTimeStr =
        "${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')}";

    return GlassContainer(
      tier: GlassTier.secondary,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.chargerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.neutralDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  booking.formattedStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),
          Text(
            "$dateStr • $startTimeStr - $endTimeStr (${booking.durationMinutes} mins)",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
            ),
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? AppColors.neutral.withValues(alpha: 0.2) : AppColors.neutral.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                "${booking.powerKw.toInt()} kW ${booking.connectorType}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
              const Spacer(),
              Text(
                "Revenue: ₹${booking.totalAmount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons: Verify PIN or Complete
          if (booking.status.toLowerCase() == 'confirmed') ...[
            GlassButton(
              text: "VERIFY DRIVER PIN & START",
              icon: Icons.qr_code_scanner_rounded,
              height: 48,
              onPressed: () => _verifyPinAndStart(booking),
            ),
          ] else if (booking.status.toLowerCase() == 'active') ...[
            GlassButton(
              text: "COMPLETE & SETTLE CHARGING",
              icon: Icons.check_circle_rounded,
              height: 48,
              variant: GlassButtonVariant.accent,
              onPressed: () => _completeSession(booking),
            ),
          ],
        ],
      ),
    );
  }
}
