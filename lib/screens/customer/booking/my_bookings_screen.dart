import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        padding: const EdgeInsets.all(28),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        blur: 28,
        opacity: 0.45,
        color: const Color(0xFF0B132B),
        borderColor: Colors.white.withValues(alpha: 0.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.15),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Present this 4-digit PIN at the charger to unlock and start charging.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              borderRadius: BorderRadius.circular(20),
              blur: 16,
              opacity: 0.1,
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
              text: "DONE",
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: const Text("Cancel Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to cancel your slot at ${booking.chargerName}?",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Keep Slot", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          content: const Text("Booking has been cancelled"),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to see bookings", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
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
                      "My Bookings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Glass Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  padding: const EdgeInsets.all(4),
                  borderRadius: BorderRadius.circular(20),
                  blur: 16,
                  opacity: 0.1,
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelColor: const Color(0xFF0B132B),
                    unselectedLabelColor: Colors.white60,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: "Upcoming"),
                      Tab(text: "In Progress"),
                      Tab(text: "Past"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tab View with Stream
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

                    final upcomingBookings = allBookings
                        .where((b) => b.status.toLowerCase() == 'confirmed')
                        .toList();

                    final activeBookings = allBookings
                        .where((b) => b.status.toLowerCase() == 'active')
                        .toList();

                    final pastBookings = allBookings
                        .where((b) =>
                            b.status.toLowerCase() == 'completed' ||
                            b.status.toLowerCase() == 'cancelled')
                        .toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingList(upcomingBookings, "No upcoming reservations"),
                        _buildBookingList(activeBookings, "No active charging sessions"),
                        _buildBookingList(pastBookings, "No past charging history"),
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

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: 80,
              height: 80,
              borderRadius: BorderRadius.circular(24),
              blur: 16,
              opacity: 0.1,
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 38,
                color: Color(0xFF00E676),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Explore stations on the quantum map to reserve.",
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: bookings.length,
      itemBuilder: (ctx, index) => _buildBookingCard(bookings[index]),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;

    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = const Color(0xFF00E676);
        break;
      case 'active':
        statusColor = const Color(0xFF00E5FF);
        break;
      case 'completed':
        statusColor = Colors.white60;
        break;
      case 'cancelled':
        statusColor = Colors.redAccent.shade200;
        break;
      default:
        statusColor = Colors.white60;
    }

    final dateStr =
        "${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year}";
    final startTimeStr =
        "${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}";
    final endTimeStr =
        "${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')}";

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      blur: 20,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Station + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.chargerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
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
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),

          // Date & Time
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Text(
                "$startTimeStr - $endTimeStr",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
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
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                ),
                child: Text(
                  "${booking.powerKw.toInt()} kW ${booking.connectorType}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E676),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                ),
                child: Text(
                  "Paid ₹${booking.bookingFee.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "Est. ₹${booking.totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
