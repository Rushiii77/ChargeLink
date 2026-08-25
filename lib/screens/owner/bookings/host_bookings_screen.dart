import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/charger_service.dart';

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
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Verify Check-in PIN"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ask driver for the 4-digit PIN generated for ${booking.chargerName}.",
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Color(0xFF00C853),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                counterText: "",
                hintText: "••••",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
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
                  const SnackBar(
                    content: Text("PIN Verified! Charging session is now ACTIVE."),
                    backgroundColor: Color(0xFF00C853),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Incorrect PIN. Please re-check with driver."),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text("Verify & Start"),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSession(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Complete Session"),
        content: Text("Mark charging session at '${booking.chargerName}' as completed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Complete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookingService.updateBookingStatus(booking.id, 'completed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Session completed! ₹${booking.totalAmount.toStringAsFixed(0)} added to revenue."),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Booking Requests")),
        body: const Center(child: Text("Please login first")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Station Bookings",
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
            Tab(text: "Confirmed"),
            Tab(text: "In Progress"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: StreamBuilder<List<ChargerModel>>(
        stream: _chargerService.streamOwnerChargers(user.uid),
        builder: (context, chargerSnapshot) {
          if (chargerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
          }

          final myChargers = chargerSnapshot.data ?? [];
          final myChargerIds = myChargers.map((c) => c.id).toSet();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
            builder: (context, bookingSnapshot) {
              if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
              }

              final allDocs = bookingSnapshot.data?.docs ?? [];
              final hostBookings = allDocs
                  .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                  .where((b) => myChargerIds.contains(b.chargerId))
                  .toList();

              hostBookings.sort((a, b) => b.startTime.compareTo(a.startTime));

              final confirmed = hostBookings.where((b) => b.status.toLowerCase() == 'confirmed').toList();
              final active = hostBookings.where((b) => b.status.toLowerCase() == 'active').toList();
              final history = hostBookings.where((b) => b.status.toLowerCase() == 'completed' || b.status.toLowerCase() == 'cancelled').toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(confirmed, "No pending reservations"),
                  _buildList(active, "No charging sessions in progress"),
                  _buildList(history, "No previous session history"),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildList(List<BookingModel> bookings, String emptyMsg) {
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
                Icons.calendar_month_rounded,
                size: 48,
                color: Color(0xFF00C853),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Reservations made by EV drivers will appear here.",
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (ctx, index) => _buildBookingCard(bookings[index]),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final isConfirmed = booking.status.toLowerCase() == 'confirmed';
    final isActive = booking.status.toLowerCase() == 'active';

    final dateStr = "${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year}";
    final timeStr =
        "${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}";

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.chargerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                ),
                Text(
                  "₹${booking.totalAmount.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Reserved for $dateStr at $timeStr (${booking.durationMinutes} mins)",
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            if (isConfirmed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.pin_rounded, size: 18),
                  label: const Text("Verify Check-in PIN & Start Session", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _verifyPinAndStart(booking),
                ),
              ),
            ] else if (isActive) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text("Complete Charging Session", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _completeSession(booking),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Text(
                    "Status: ${booking.formattedStatus}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
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
