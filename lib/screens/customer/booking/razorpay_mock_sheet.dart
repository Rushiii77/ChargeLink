import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../widgets/glass/glass_container.dart';

class RazorpayPaymentResult {
  final bool success;
  final String paymentId;
  final String orderId;
  final String paymentMethod;
  final String? errorMessage;

  RazorpayPaymentResult({
    required this.success,
    required this.paymentId,
    required this.orderId,
    required this.paymentMethod,
    this.errorMessage,
  });
}

class RazorpayMockSheet extends StatefulWidget {
  final ChargerModel charger;
  final double amount;
  final String customerEmail;
  final String customerPhone;

  const RazorpayMockSheet({
    super.key,
    required this.charger,
    this.amount = 100.0,
    this.customerEmail = "driver@chargelink.com",
    this.customerPhone = "+91 98765 43210",
  });

  @override
  State<RazorpayMockSheet> createState() => _RazorpayMockSheetState();
}

class _RazorpayMockSheetState extends State<RazorpayMockSheet> {
  String _selectedCategory = 'UPI'; // 'UPI', 'Card', 'Netbanking', 'Wallet'
  String _selectedUpiApp = 'GPay';
  final _upiIdController = TextEditingController(text: 'driver@okaxis');
  final _cardNumberController = TextEditingController(text: '4111 2222 3333 4444');
  final _cardExpiryController = TextEditingController(text: '12/28');
  final _cardCvvController = TextEditingController(text: '888');
  String _selectedBank = 'HDFC Bank';

  bool _simulateSuccess = true;
  bool _isProcessing = false;
  String _processingStatus = 'Initializing Razorpay...';

  late String _orderId;

  final List<String> _popularBanks = [
    'HDFC Bank',
    'State Bank of India',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra',
  ];

  @override
  void initState() {
    super.initState();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _orderId = 'order_RPZ_${timestamp.toString().substring(5)}';
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Connecting to Razorpay Security Gateway...';
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _processingStatus = 'Authorizing with Bank Server...';
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    if (_simulateSuccess) {
      setState(() {
        _processingStatus = 'Payment Verified by Razorpay!';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final paymentId = 'pay_RPZ_${timestamp.toString().substring(4)}';

      if (!mounted) return;
      Navigator.pop(
        context,
        RazorpayPaymentResult(
          success: true,
          paymentId: paymentId,
          orderId: _orderId,
          paymentMethod: 'Razorpay ($_selectedCategory - ${_selectedCategory == "UPI" ? _selectedUpiApp : _selectedCategory})',
        ),
      );
    } else {
      setState(() {
        _processingStatus = 'Payment Declined by Bank (Test)';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.pop(
        context,
        RazorpayPaymentResult(
          success: false,
          paymentId: '',
          orderId: _orderId,
          paymentMethod: _selectedCategory,
          errorMessage: 'Transaction declined in simulated test mode.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Razorpay Signature Dark Slate
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // ── Razorpay Header Bar ─────────────────────────────────────────
              _buildRazorpayHeader(),

              // ── Merchant & Amount Summary Strip ─────────────────────────────
              _buildMerchantStrip(),

              // ── Body: Categories + Detail Options ───────────────────────────
              Expanded(
                child: Row(
                  children: [
                    // Left Navigation Rail for Payment Types
                    _buildPaymentCategoriesRail(),

                    // Right Content Area
                    Expanded(
                      child: Container(
                        color: const Color(0xFF0B132B),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedCategory == 'UPI') _buildUpiSection(),
                              if (_selectedCategory == 'Card') _buildCardSection(),
                              if (_selectedCategory == 'Netbanking') _buildNetbankingSection(),
                              if (_selectedCategory == 'Wallet') _buildWalletSection(),

                              const SizedBox(height: 24),

                              // Test Mode Toggle
                              _buildSimulationControls(),

                              const SizedBox(height: 24),

                              // Razorpay Pay Button
                              _buildPayButton(),

                              const SizedBox(height: 16),

                              // Security Footer
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_rounded, size: 13, color: Color(0xFF00E676)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Secured by Razorpay • 256-Bit SSL",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Processing Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(28),
                  borderRadius: BorderRadius.circular(24),
                  blur: 24,
                  opacity: 0.25,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3395FF)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Razorpay Checkout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _processingStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRazorpayHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF02042B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          // Razorpay Logo Simulation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0C2340),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3395FF).withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF3395FF)),
                SizedBox(width: 4),
                Text(
                  "Razorpay",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "TEST MODE",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
            onPressed: () => Navigator.pop(context, null),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.ev_station_rounded, color: Color(0xFF00E676), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ChargeLink Mobility Hub",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Slot Booking Deposit • $_orderId",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${widget.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "Payable Now",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCategoriesRail() {
    final categories = [
      {'id': 'UPI', 'label': 'UPI / QR', 'icon': Icons.qr_code_rounded},
      {'id': 'Card', 'label': 'Cards', 'icon': Icons.credit_card_rounded},
      {'id': 'Netbanking', 'label': 'Netbanking', 'icon': Icons.account_balance_rounded},
      {'id': 'Wallet', 'label': 'Wallets', 'icon': Icons.account_balance_wallet_rounded},
    ];

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['id'];
          return InkWell(
            onTap: () => setState(() => _selectedCategory = cat['id'] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0B132B) : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? const Color(0xFF3395FF) : Colors.transparent,
                    width: 3.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 22,
                    color: isSelected ? const Color(0xFF3395FF) : Colors.white60,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUpiSection() {
    final upiApps = [
      {'id': 'GPay', 'name': 'Google Pay', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF4285F4)},
      {'id': 'PhonePe', 'name': 'PhonePe', 'icon': Icons.payments_rounded, 'color': const Color(0xFF6739B7)},
      {'id': 'Paytm', 'name': 'Paytm UPI', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF00BAF2)},
      {'id': 'CRED', 'name': 'CRED UPI', 'icon': Icons.security_rounded, 'color': const Color(0xFFFFFFFF)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pay with UPI App",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),

        ...upiApps.map((app) {
          final isSelected = _selectedUpiApp == app['id'];
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: BorderRadius.circular(14),
            blur: 12,
            opacity: isSelected ? 0.2 : 0.06,
            borderColor: isSelected ? const Color(0xFF3395FF) : Colors.white.withValues(alpha: 0.1),
            onTap: () => setState(() => _selectedUpiApp = app['id'] as String),
            child: Row(
              children: [
                Icon(app['icon'] as IconData, color: app['color'] as Color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    app['name'] as String,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF3395FF), size: 18),
              ],
            ),
          );
        }),

        const SizedBox(height: 14),

        const Text(
          "Or Enter UPI ID / VPA",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: _upiIdController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              hintText: "yourname@upi",
              hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
              prefixIcon: Icon(Icons.alternate_email_rounded, color: Color(0xFF3395FF), size: 18),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Credit / Debit Card",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),

        _buildCardInput("Card Number", _cardNumberController, Icons.credit_card_rounded),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildCardInput("Expiry (MM/YY)", _cardExpiryController, Icons.date_range_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _buildCardInput("CVV", _cardCvvController, Icons.lock_outline_rounded)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.check_box_rounded, color: Color(0xFF3395FF), size: 18),
            const SizedBox(width: 8),
            Text(
              "Save card as per RBI guidelines",
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardInput(String label, TextEditingController controller, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
          prefixIcon: Icon(icon, color: const Color(0xFF3395FF), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildNetbankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Netbanking Bank",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        ..._popularBanks.map((bank) {
          final isSelected = _selectedBank == bank;
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: BorderRadius.circular(14),
            blur: 12,
            opacity: isSelected ? 0.2 : 0.06,
            borderColor: isSelected ? const Color(0xFF3395FF) : Colors.white.withValues(alpha: 0.1),
            onTap: () => setState(() => _selectedBank = bank),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: Color(0xFF3395FF), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bank,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF3395FF), size: 18),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWalletSection() {
    final wallets = ['Amazon Pay', 'MobiKwik', 'PayZapp', 'Airtel Money'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Supported Wallets",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        ...wallets.map((wallet) {
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: BorderRadius.circular(14),
            blur: 12,
            opacity: 0.06,
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF3395FF), size: 18),
                const SizedBox(width: 12),
                Text(
                  wallet,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 18),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSimulationControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mock Simulation Mode",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  _simulateSuccess ? "Will simulate success" : "Will simulate bank decline",
                  style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _simulateSuccess,
            activeTrackColor: const Color(0xFF00E676).withValues(alpha: 0.5),
            activeThumbColor: const Color(0xFF00E676),
            onChanged: (v) => setState(() => _simulateSuccess = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3395FF), // Razorpay Blue
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: _handlePayment,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 18),
          const SizedBox(width: 8),
          Text(
            "PAY ₹${widget.amount.toStringAsFixed(0)} VIA RAZORPAY",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

