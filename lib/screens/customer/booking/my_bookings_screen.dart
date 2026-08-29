import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();

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

  void _showPinModal(BookingModel booking) {
    final isDark = ThemeService.isDark(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        tier: GlassTier.primary,
        padding: const EdgeInsets.all(28),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.neutral.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.deepTeal.withValues(alpha: 0.35) : AppColors.accentLime.withValues(alpha: 0.40),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppColors.accentLime : AppColors.deepTeal, width: 1.2),
              ),
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              booking.chargerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.neutralDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Present this 4-digit PIN at the charger to unlock and start charging.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
              ),
            ),
            const SizedBox(height: 24),
            GlassContainer(
              tier: GlassTier.tertiary,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Text(
                  booking.otpPin,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                    letterSpacing: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GlassButton(
              text: "CLOSE",
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelBooking(BookingModel booking) async {
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
          "Cancel Reservation?",
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to cancel your slot at ${booking.chargerName}? Your ₹100 deposit will be refunded automatically.",
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Keep Slot",
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.neutral),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Cancel Slot"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookingService.cancelBooking(booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Booking cancelled and deposit refunded."),
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
            "Please sign in to view your bookings",
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
              // Top App Bar
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
                      "My EV Bookings",
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
                    tabs: const [
                      Tab(text: "Upcoming"),
                      Tab(text: "Completed"),
                      Tab(text: "Cancelled"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Stream Content
              Expanded(
                child: StreamBuilder<List<BookingModel>>(
                  stream: _bookingService.streamCustomerBookings(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.deepTeal),
                      );
                    }

                    final allBookings = snapshot.data ?? [];

                    final upcoming = allBookings
                        .where((b) =>
                            b.status.toLowerCase() == 'confirmed' ||
                            b.status.toLowerCase() == 'active')
                        .toList();

                    final completed = allBookings
                        .where((b) => b.status.toLowerCase() == 'completed')
                        .toList();

                    final cancelled = allBookings
                        .where((b) => b.status.toLowerCase() == 'cancelled')
                        .toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingList(upcoming, "No upcoming charging slots", isDark),
                        _buildBookingList(completed, "No completed sessions yet", isDark),
                        _buildBookingList(cancelled, "No cancelled reservations", isDark),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage, bool isDark) {
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
                Icons.calendar_month_outlined,
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
            const SizedBox(height: 6),
            Text(
              "Explore stations on the map to reserve.",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
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
      itemBuilder: (ctx, index) => _buildBookingCard(bookings[index], isDark),
    );
  }

  Widget _buildBookingCard(BookingModel booking, bool isDark) {
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
          // Header: Station + Status
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
            booking.chargerAddress,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? AppColors.neutral.withValues(alpha: 0.2) : AppColors.neutral.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 12),

          // Date & Time
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
              ),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
              ),
              const SizedBox(width: 6),
              Text(
                "$startTimeStr - $endTimeStr",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Specs & Total
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withValues(alpha: isDark ? 0.25 : 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "${booking.powerKw.toInt()} kW ${booking.connectorType}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.deepTeal.withValues(alpha: 0.35) : AppColors.accentLime.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppColors.accentLime.withValues(alpha: 0.5) : AppColors.deepTeal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "Paid ₹${booking.bookingFee.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentLime : AppColors.primaryDark,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "Est. ₹${booking.totalAmount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
            ],
          ),

          if (booking.status.toLowerCase() == 'confirmed') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.accentLime : AppColors.deepTeal,
                      side: BorderSide(color: isDark ? AppColors.accentLime : AppColors.deepTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.pin_rounded, size: 16),
                    label: const Text(
                      "Check-in PIN",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () => _showPinModal(booking),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.error),
                  tooltip: "Cancel Booking",
                  onPressed: () => _cancelBooking(booking),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
