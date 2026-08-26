import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';
import '../../../widgets/glass/glass_text_field.dart';

class PaymentSheet extends StatefulWidget {
  final ChargerModel charger;
  final DateTime startTime;
  final int durationMinutes;
  final double estimatedEnergyKwh;
  final double estimatedTotalCharge;
  final double bookingFee;

  const PaymentSheet({
    super.key,
    required this.charger,
    required this.startTime,
    required this.durationMinutes,
    required this.estimatedEnergyKwh,
    required this.estimatedTotalCharge,
    this.bookingFee = 100.0,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String _selectedMethod = 'GPay';
  final _upiController = TextEditingController(text: 'driver@okaxis');
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _upiApps = [
    {
      'id': 'GPay',
      'name': 'Google Pay',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFF4285F4),
    },
    {
      'id': 'PhonePe',
      'name': 'PhonePe UPI',
      'icon': Icons.payments_rounded,
      'color': Color(0xFF6739B7),
    },
    {
      'id': 'Paytm',
      'name': 'Paytm UPI',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF00BAF2),
    },
    {
      'id': 'Card',
      'name': 'Credit / Debit Card',
      'icon': Icons.credit_card_rounded,
      'color': Color(0xFF00E676),
    },
  ];

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate secure 256-bit gateway handshake
    await Future.delayed(const Duration(milliseconds: 1600));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    Navigator.pop(context, _selectedMethod);
  }

  @override
  Widget build(BuildContext context) {
    final startTimeStr =
        "${widget.startTime.hour.toString().padLeft(2, '0')}:${widget.startTime.minute.toString().padLeft(2, '0')}";
    final dateStr =
        "${widget.startTime.day}/${widget.startTime.month}/${widget.startTime.year}";

    return GlassContainer(
      height: MediaQuery.of(context).size.height * 0.88,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      blur: 28,
      opacity: 0.45,
      color: const Color(0xFF0B132B),
      borderColor: Colors.white.withValues(alpha: 0.2),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF00E676),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Secure Slot Checkout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "256-Bit Encrypted EV Escrow Gateway",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Summary Glass Card
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(20),
                    blur: 16,
                    opacity: 0.12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.charger.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${widget.charger.powerKw.toInt()} kW ${widget.charger.connectorType}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E676),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$dateStr • $startTimeStr (${widget.durationMinutes} mins slot)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Slot Reservation Fee",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              "₹${widget.bookingFee.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00E676),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ℹ️ Note: This ₹100 deposit confirms your reservation. Actual charging energy (~₹${widget.estimatedTotalCharge.toStringAsFixed(0)}) is settled post-session at the charger.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Select Payment Method
                  const Text(
                    "Select Payment Method",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ..._upiApps.map((app) {
                    final isSelected = _selectedMethod == app['id'];
                    return GlassContainer(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      borderRadius: BorderRadius.circular(18),
                      blur: 16,
                      opacity: isSelected ? 0.22 : 0.08,
                      borderColor: isSelected
                          ? const Color(0xFF00E676)
                          : Colors.white.withValues(alpha: 0.12),
                      borderWidth: isSelected ? 1.8 : 1.0,
                      onTap: () => setState(() => _selectedMethod = app['id']),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: (app['color'] as Color)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(app['icon'] as IconData,
                                color: app['color'] as Color, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              app['name'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF00E676)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00E676)
                                    : Colors.white38,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 14, color: Color(0xFF0B132B))
                                : null,
                          ),
                        ],
                      ),
                    );
                  }),

                  if (_selectedMethod == 'GPay' ||
                      _selectedMethod == 'PhonePe' ||
                      _selectedMethod == 'Paytm') ...[
                    const SizedBox(height: 6),
                    GlassTextField(
                      controller: _upiController,
                      labelText: "UPI Virtual Payment Address (VPA)",
                      hintText: "username@bank",
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Escrow Security Notice
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          size: 16, color: Color(0xFF00E676)),
                      const SizedBox(width: 6),
                      Text(
                        "100% Refundable if cancelled before slot start time",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Pay Button
                  GlassButton(
                    text:
                        "PAY ₹${widget.bookingFee.toStringAsFixed(0)} & CONFIRM SLOT",
                    isLoading: _isProcessing,
                    icon: Icons.shield_rounded,
                    onPressed: _processPayment,
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

