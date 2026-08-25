import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../booking/booking_screen.dart';

class ChargerDetailSheet extends StatelessWidget {
  final ChargerModel charger;

  const ChargerDetailSheet({super.key, required this.charger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          const SizedBox(height: 20),

          // Station name + availability
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  charger.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? const Color(0xFFE8FFF0)
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  charger.isAvailable ? '● Available' : '● Busy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: charger.isAvailable
                        ? const Color(0xFF00C853)
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Address
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  charger.address,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),

          // Info grid
          Row(
            children: [
              _infoTile(
                icon: Icons.bolt_rounded,
                iconColor: Colors.amber.shade700,
                label: 'Power Speed',
                value: charger.powerLabel,
              ),
              const SizedBox(width: 12),
              _infoTile(
                icon: Icons.electrical_services_rounded,
                iconColor: const Color(0xFF3B82F6),
                label: 'Connector',
                value: charger.connectorType,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _infoTile(
                icon: Icons.currency_rupee_rounded,
                iconColor: const Color(0xFF00C853),
                label: 'Price Rate',
                value: '₹${charger.pricePerKwh.toStringAsFixed(0)} / kWh',
              ),
              const SizedBox(width: 12),
              _infoTile(
                icon: Icons.star_rounded,
                iconColor: Colors.amber.shade600,
                label: 'User Rating',
                value: charger.ratingLabel,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Book Now button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    charger.isAvailable ? const Color(0xFF00C853) : Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: charger.isAvailable ? 2 : 0,
                shadowColor: const Color(0xFF00C853).withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
              label: Text(
                charger.isAvailable ? 'Book Charging Slot' : 'Currently Busy',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: charger.isAvailable
                  ? () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(charger: charger),
                        ),
                      );
                    }
                  : null,
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

