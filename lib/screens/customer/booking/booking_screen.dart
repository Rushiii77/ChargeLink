import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../widgets/glass/glass_background.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';
import 'payment_sheet.dart';

class BookingScreen extends StatefulWidget {
  final ChargerModel charger;

  const BookingScreen({super.key, required this.charger});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();

  late DateTime _selectedDate;
  late int _selectedSlotIndex;
  int _selectedDurationMinutes = 60; // default 1 hour
  final double _currentBattery = 25.0;
  double _targetBattery = 85.0;
  bool _isLoading = false;

  static const double _bookingFee = 100.0; // Fixed ₹100 slot reservation fee

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:30 AM',
    '12:00 PM',
    '01:30 PM',
    '03:00 PM',
    '04:30 PM',
    '06:00 PM',
    '07:30 PM',
    '09:00 PM',
  ];

  final List<int> _durations = [30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedSlotIndex = 0;
  }

  double get _estimatedEnergyKwh {
    final hours = _selectedDurationMinutes / 60.0;
    return (widget.charger.powerKw * hours).clamp(5.0, 120.0);
  }

  double get _estimatedTotalCharge {
    final hours = _selectedDurationMinutes / 60.0;
    final energy = widget.charger.powerKw * hours;
    return energy * widget.charger.pricePerKwh;
  }

  DateTime get _calculatedStartTime {
    final slot = _timeSlots[_selectedSlotIndex];
    final isPm = slot.contains('PM');
    final parts = slot.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );
  }

  Future<void> _startCheckoutFlow() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please sign in to book a charger"),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    // 1. Open Payment Sheet modal for ₹100 fee
    final paymentMethod = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentSheet(
        charger: widget.charger,
        startTime: _calculatedStartTime,
        durationMinutes: _selectedDurationMinutes,
        estimatedEnergyKwh: _estimatedEnergyKwh,
        estimatedTotalCharge: _estimatedTotalCharge,
        bookingFee: _bookingFee,
      ),
    );

    if (paymentMethod == null) return; // User cancelled

    setState(() => _isLoading = true);

    try {
      final booking = await _bookingService.createBooking(
        customerId: user.uid,
        charger: widget.charger,
        startTime: _calculatedStartTime,
        durationMinutes: _selectedDurationMinutes,
        totalAmount: _estimatedTotalCharge,
        bookingFee: _bookingFee,
        paymentMethod: paymentMethod,
      );

      if (!mounted) return;

      _showSuccessDialog(booking);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to complete booking: $e"),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(BookingModel booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00E676),
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Slot Reserved!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "₹${booking.bookingFee.toStringAsFixed(0)} advance deposit paid successfully.",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00E676),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Transaction: ${booking.transactionId}",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 18),

              // PIN Box
              GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                borderRadius: BorderRadius.circular(20),
                blur: 16,
                opacity: 0.1,
                child: Column(
                  children: [
                    Text(
                      "STATION CHECK-IN PIN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.otpPin,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E676),
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              GlassButton(
                text: "VIEW MY BOOKINGS",
                icon: Icons.calendar_month_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/my-bookings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar
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
                      "Reserve Charging Slot",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Station Summary Card
                _buildStationHeader(),

                const SizedBox(height: 24),

                // 1. Select Date
                _buildSectionTitle("1. Select Date"),
                const SizedBox(height: 10),
                _buildDateSelector(),

                const SizedBox(height: 24),

                // 2. Select Time Slot
                _buildSectionTitle("2. Select Time Slot"),
                const SizedBox(height: 10),
                _buildTimeSlotSelector(),

                const SizedBox(height: 24),

                // 3. Charging Duration
                _buildSectionTitle("3. Charging Duration"),
                const SizedBox(height: 10),
                _buildDurationSelector(),

                const SizedBox(height: 24),

                // 4. Battery Estimator
                _buildSectionTitle("4. Target Battery % (Estimator)"),
                const SizedBox(height: 10),
                _buildBatteryEstimator(),

                const SizedBox(height: 24),

                // Price Breakdown Card
                _buildPriceSummary(),

                const SizedBox(height: 28),

                // Pay & Book Button
                GlassButton(
                  text: "PAY ₹${_bookingFee.toStringAsFixed(0)} & RESERVE SLOT",
                  isLoading: _isLoading,
                  icon: Icons.lock_outline_rounded,
                  onPressed: _startCheckoutFlow,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStationHeader() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      blur: 20,
      opacity: 0.14,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
            ),
            child: const Icon(
              Icons.ev_station_rounded,
              color: Color(0xFF00E676),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.charger.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.charger.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      widget.charger.powerLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        widget.charger.connectorType,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final dates = List.generate(7, (index) => now.add(Duration(days: index)));
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (ctx, index) {
          final d = dates[index];
          final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
          final dayName = index == 0 ? 'Today' : (index == 1 ? 'Tmrw' : weekdays[d.weekday - 1]);

          return GlassContainer(
            width: 68,
            margin: const EdgeInsets.only(right: 10),
            borderRadius: BorderRadius.circular(18),
            blur: 16,
            opacity: isSelected ? 0.3 : 0.08,
            borderColor: isSelected ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.15),
            glowColor: isSelected ? const Color(0xFF00E676) : null,
            onTap: () => setState(() => _selectedDate = d),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF00E676) : Colors.white60,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${d.day} ${months[d.month - 1]}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_timeSlots.length, (index) {
        final slot = _timeSlots[index];
        final isSelected = index == _selectedSlotIndex;

        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          borderRadius: BorderRadius.circular(14),
          blur: 16,
          opacity: isSelected ? 0.25 : 0.08,
          borderColor: isSelected ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.15),
          onTap: () => setState(() => _selectedSlotIndex = index),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 13,
                color: isSelected ? const Color(0xFF00E676) : Colors.white60,
              ),
              const SizedBox(width: 6),
              Text(
                slot,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF00E676) : Colors.white70,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDurationSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _durations.map((mins) {
          final isSelected = mins == _selectedDurationMinutes;
          final label = mins < 60 ? '$mins mins' : '${mins / 60} hrs';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedDurationMinutes = mins),
              selectedColor: const Color(0xFF00E676).withValues(alpha: 0.25),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF00E676) : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBatteryEstimator() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      blur: 16,
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current: ${_currentBattery.toInt()}%",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              Text(
                "Target: ${_targetBattery.toInt()}%",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00E676),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              thumbColor: const Color(0xFF00E676),
            ),
            child: Slider(
              value: _targetBattery,
              min: 30,
              max: 100,
              divisions: 14,
              onChanged: (val) => setState(() => _targetBattery = val),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFFB300)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Est. ~${_estimatedEnergyKwh.toStringAsFixed(1)} kWh delivered in $_selectedDurationMinutes mins.",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(22),
      blur: 20,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Booking & Fare Summary",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildFareRow("Slot Reservation Deposit", "₹${_bookingFee.toStringAsFixed(0)} (Payable Now)", isHighlight: true),
          const SizedBox(height: 6),
          _buildFareRow("Energy Rate", "₹${widget.charger.pricePerKwh.toStringAsFixed(0)} / kWh"),
          const SizedBox(height: 6),
          _buildFareRow("Estimated Energy Consumed", "~${_estimatedEnergyKwh.toStringAsFixed(1)} kWh (~₹${_estimatedTotalCharge.toStringAsFixed(0)})"),
          const SizedBox(height: 6),
          _buildFareRow("Escrow Security & Platform Fee", "FREE (₹0)"),
          Divider(height: 24, color: Colors.white.withValues(alpha: 0.15)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Amount Due Now",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "100% Refundable Deposit",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Text(
                "₹${_bookingFee.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isHighlight ? const Color(0xFF00E676) : Colors.white.withValues(alpha: 0.65),
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isHighlight ? const Color(0xFF00E676) : Colors.white,
          ),
        ),
      ],
    );
  }
}
