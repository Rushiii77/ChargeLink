import 'package:flutter/material.dart';
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
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: isDark ? 0.15 : 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E676), width: 1.2),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF00E676),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              booking.chargerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Present this 4-digit PIN at the charger to unlock and start charging.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
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
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E676),
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
        backgroundColor: isDark ? const Color(0xFF0B132B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
        ),
        title: Text(
          "Cancel Reservation?",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to cancel your slot at ${booking.chargerName}? Your ₹100 deposit will be refunded automatically.",
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF475569),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Keep Slot",
              style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade400,
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
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
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
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: const Color(0xFF0B132B),
                    unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF64748B),
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
                        child: CircularProgressIndicator(color: Color(0xFF00E676)),
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
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 40,
                color: Color(0xFF00E676),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Explore stations on the map to reserve.",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
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
        statusColor = const Color(0xFF00E676);
        break;
      case 'active':
        statusColor = const Color(0xFF00E5FF);
        break;
      case 'completed':
        statusColor = isDark ? Colors.white60 : const Color(0xFF64748B);
        break;
      case 'cancelled':
        statusColor = Colors.redAccent.shade200;
        break;
      default:
        statusColor = isDark ? Colors.white60 : const Color(0xFF64748B);
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
      borderRadius: BorderRadius.circular(24),
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
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.15 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
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
              color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 12),

          // Date & Time
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 14),
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                "$startTimeStr - $endTimeStr",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                  color: const Color(0xFF00E676).withValues(alpha: isDark ? 0.15 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                ),
                child: Text(
                  "${booking.powerKw.toInt()} kW ${booking.connectorType}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.15 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                ),
                child: Text(
                  "Paid ₹${booking.bookingFee.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B4D8),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "Est. ₹${booking.totalAmount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                      foregroundColor: const Color(0xFF00E676),
                      side: const BorderSide(color: Color(0xFF00E676)),
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
                  icon: Icon(Icons.close_rounded, color: Colors.redAccent.shade200),
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
