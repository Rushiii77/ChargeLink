import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';

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

  double get _totalPrice {
    final hours = _selectedDurationMinutes / 60.0;
    // Estimated energy * price per kWh
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

  Future<void> _confirmBooking() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please sign in to book a charger"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final booking = await _bookingService.createBooking(
        customerId: user.uid,
        charger: widget.charger,
        startTime: _calculatedStartTime,
        durationMinutes: _selectedDurationMinutes,
        totalAmount: _totalPrice,
      );

      if (!mounted) return;

      _showSuccessDialog(booking);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to complete booking: $e"),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8FFF0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00C853),
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Slot Reserved!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your charging slot at ${booking.chargerName} is confirmed.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // PIN Box
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "STATION CHECK-IN PIN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.otpPin,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C853),
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Return from booking screen
                    Navigator.pushNamed(context, '/my-bookings');
                  },
                  child: const Text(
                    "View My Bookings",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Reserve Charging Slot",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // 4. Target Battery % (Smart Estimation)
            _buildSectionTitle("4. Target Battery % (Estimator)"),
            const SizedBox(height: 10),
            _buildBatteryEstimator(),

            const SizedBox(height: 24),

            // Price Breakdown Card
            _buildPriceSummary(),

            const SizedBox(height: 28),

            // Reserve Slot Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xFF00C853).withValues(alpha: 0.4),
                ),
                onPressed: _isLoading ? null : _confirmBooking,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        "CONFIRM & PAY ₹${_totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildStationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8FFF0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.ev_station_rounded,
              color: Color(0xFF00C853),
              size: 32,
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
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.charger.address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
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
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.charger.connectorType,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
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

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = d),
            child: Container(
              width: 68,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00C853) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF00C853).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${d.day} ${months[d.month - 1]}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_timeSlots.length, (index) {
        final slot = _timeSlots[index];
        final isSelected = index == _selectedSlotIndex;

        return GestureDetector(
          onTap: () => setState(() => _selectedSlotIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8FFF0) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: isSelected ? const Color(0xFF00C853) : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF00C853) : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
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
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedDurationMinutes = mins),
              selectedColor: const Color(0xFFE8FFF0),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF00C853) : const Color(0xFF1A1A2E),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBatteryEstimator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current: ${_currentBattery.toInt()}%",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                "Target: ${_targetBattery.toInt()}%",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C853),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00C853),
              inactiveTrackColor: const Color(0xFFE5E7EB),
              thumbColor: const Color(0xFF00C853),
              trackHeight: 6,
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
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Est. ~${_estimatedEnergyKwh.toStringAsFixed(1)} kWh to be delivered in $_selectedDurationMinutes mins.",
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E)),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Fare Breakdown",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          _buildFareRow("Energy Rate", "₹${widget.charger.pricePerKwh.toStringAsFixed(0)} / kWh"),
          const SizedBox(height: 6),
          _buildFareRow("Estimated Energy", "~${_estimatedEnergyKwh.toStringAsFixed(1)} kWh"),
          const SizedBox(height: 6),
          _buildFareRow("Platform Fee", "FREE (₹0)"),
          const Divider(height: 24, color: Color(0xFFE5E7EB)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                "₹${_totalPrice.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C853),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      ],
    );
  }
}
