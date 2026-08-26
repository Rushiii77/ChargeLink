import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';
import '../booking/booking_screen.dart';

class ChargerDetailSheet extends StatelessWidget {
  final ChargerModel charger;

  const ChargerDetailSheet({super.key, required this.charger});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      blur: 28,
      opacity: 0.45,
      color: const Color(0xFF0B132B),
      borderColor: Colors.white.withValues(alpha: 0.2),
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
                color: Colors.white.withValues(alpha: 0.3),
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
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? const Color(0xFF00E676).withValues(alpha: 0.2)
                      : Colors.redAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: charger.isAvailable
                        ? const Color(0xFF00E676).withValues(alpha: 0.5)
                        : Colors.redAccent.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  charger.isAvailable ? '● Available' : '● Busy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: charger.isAvailable
                        ? const Color(0xFF00E676)
                        : Colors.redAccent.shade100,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Address
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  charger.address,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),

          // 2x2 Glass Specs Grid
          Row(
            children: [
              _glassSpecTile(
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFFFFB300),
                label: 'Charging Speed',
                value: charger.powerLabel,
              ),
              const SizedBox(width: 12),
              _glassSpecTile(
                icon: Icons.electrical_services_rounded,
                iconColor: const Color(0xFF00E5FF),
                label: 'Connector Standard',
                value: charger.connectorType,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _glassSpecTile(
                icon: Icons.currency_rupee_rounded,
                iconColor: const Color(0xFF00E676),
                label: 'Energy Rate',
                value: '₹${charger.pricePerKwh.toStringAsFixed(0)} / kWh',
              ),
              const SizedBox(width: 12),
              _glassSpecTile(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFFFB300),
                label: 'User Rating',
                value: charger.ratingLabel,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Book Now Glass Button
          GlassButton(
            text: charger.isAvailable ? 'RESERVE CHARGING SLOT' : 'CURRENTLY OCCUPIED',
            icon: Icons.flash_on_rounded,
            color: charger.isAvailable ? const Color(0xFF00E676) : null,
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

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _glassSpecTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(16),
        blur: 16,
        opacity: 0.1,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
