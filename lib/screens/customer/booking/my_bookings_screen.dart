import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8FFF0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF00C853),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              booking.chargerName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Present this 4-digit PIN at the charger to unlock and start charging.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Center(
                child: Text(
                  booking.otpPin,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C853),
                    letterSpacing: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Booking"),
        content: Text(
          "Are you sure you want to cancel your slot at ${booking.chargerName}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Keep Slot", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Bookings")),
        body: const Center(child: Text("Please login to see bookings")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00C853),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF00C853),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "In Progress"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _bookingService.streamCustomerBookings(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
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
              _buildBookingList(upcomingBookings, "No upcoming bookings"),
              _buildBookingList(activeBookings, "No active charging sessions"),
              _buildBookingList(pastBookings, "No past booking history"),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8FFF0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 48,
                color: Color(0xFF00C853),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Explore stations on the map to reserve a slot.",
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (ctx, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;
    Color statusBg;

    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = const Color(0xFF00C853);
        statusBg = const Color(0xFFE8FFF0);
        break;
      case 'active':
        statusColor = const Color(0xFF3B82F6);
        statusBg = Colors.blue.shade50;
        break;
      case 'completed':
        statusColor = const Color(0xFF6B7280);
        statusBg = const Color(0xFFF3F4F6);
        break;
      case 'cancelled':
        statusColor = Colors.red.shade600;
        statusBg = Colors.red.shade50;
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusBg = const Color(0xFFF3F4F6);
    }

    final dateStr =
        "${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year}";
    final startTimeStr =
        "${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}";
    final endTimeStr =
        "${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Station name + Status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.chargerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
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

            const SizedBox(height: 4),

            Text(
              booking.chargerAddress,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 14),

            // Time & Date details
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  "$startTimeStr - $endTimeStr",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Specs & Price
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${booking.powerKw.toInt()} kW ${booking.connectorType}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C853),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "₹${booking.totalAmount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),

            if (booking.status.toLowerCase() == 'confirmed') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00C853),
                        side: const BorderSide(color: Color(0xFF00C853)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.pin_rounded, size: 18),
                      label: const Text(
                        "Check-in PIN",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showPinModal(booking),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.red.shade400),
                    tooltip: "Cancel Booking",
                    onPressed: () => _cancelBooking(booking),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

