import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/charger_service.dart';
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
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        title: const Text("Verify Check-in PIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ask driver for the 4-digit PIN generated for ${booking.chargerName}.",
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: Color(0xFF00E676),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                counterText: "",
                hintText: "••••",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: const Color(0xFF0B132B),
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
                    backgroundColor: Color(0xFF00E676),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Incorrect PIN. Please re-check with driver."),
                    backgroundColor: Colors.redAccent.shade700,
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: const Text("Complete Session", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Mark charging session at '${booking.chargerName}' as completed?",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: const Color(0xFF0B132B),
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
          content: Text("Session completed! ₹${booking.totalAmount.toStringAsFixed(0)} added to revenue."),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login first", style: TextStyle(color: Colors.white))),
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
                      "Station Bookings",
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
                      Tab(text: "Confirmed"),
                      Tab(text: "In Progress"),
                      Tab(text: "History"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: StreamBuilder<List<ChargerModel>>(
                  stream: _chargerService.streamOwnerChargers(user.uid),
                  builder: (context, chargerSnapshot) {
                    if (chargerSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
                    }

                    final myChargers = chargerSnapshot.data ?? [];
                    final myChargerIds = myChargers.map((c) => c.id).toSet();

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                      builder: (context, bookingSnapshot) {
                        if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
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
                            _buildList(active, "No sessions in progress"),
                            _buildList(history, "No previous session history"),
                          ],
                        );
                      },
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

  Widget _buildList(List<BookingModel> bookings, String emptyMsg) {
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
                Icons.calendar_month_rounded,
                size: 38,
                color: Color(0xFF00E676),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Reservations made by EV drivers will appear here.",
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      blur: 20,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.chargerName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Text(
                "₹${booking.totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            "Reserved for $dateStr at $timeStr (${booking.durationMinutes} mins)",
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 14),
          if (isConfirmed) ...[
            GlassButton(
              text: "VERIFY PIN & START SESSION",
              height: 48,
              icon: Icons.pin_rounded,
              onPressed: () => _verifyPinAndStart(booking),
            ),
          ] else if (isActive) ...[
            GlassButton(
              text: "COMPLETE CHARGING SESSION",
              height: 48,
              color: const Color(0xFF00E5FF),
              icon: Icons.check_circle_outline_rounded,
              onPressed: () => _completeSession(booking),
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.done_all_rounded, size: 16, color: Colors.white60),
                const SizedBox(width: 6),
                Text(
                  "Status: ${booking.formattedStatus}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
