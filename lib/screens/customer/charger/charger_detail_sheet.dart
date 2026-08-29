import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_button.dart';
import '../../../widgets/glass/glass_container.dart';
import '../booking/booking_screen.dart';

class ChargerDetailSheet extends StatelessWidget {
  final ChargerModel charger;

  const ChargerDetailSheet({super.key, required this.charger});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);

    return GlassContainer(
      tier: GlassTier.primary,
      padding: const EdgeInsets.all(24),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.15),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? const Color(0xFF00E676).withValues(alpha: isDark ? 0.2 : 0.15)
                      : Colors.redAccent.withValues(alpha: isDark ? 0.2 : 0.15),
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
                        ? (isDark ? const Color(0xFF00E676) : const Color(0xFF00A040))
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
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  charger.address,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 16),

          // 2x2 Glass Specs Grid
          Row(
            children: [
              _glassSpecTile(
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFFFFB300),
                label: 'Charging Speed',
                value: charger.powerLabel,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _glassSpecTile(
                icon: Icons.electrical_services_rounded,
                iconColor: const Color(0xFF00E5FF),
                label: 'Connector Standard',
                value: charger.connectorType,
                isDark: isDark,
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
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _glassSpecTile(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFFFB300),
                label: 'User Rating',
                value: charger.ratingLabel,
                isDark: isDark,
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
    required bool isDark,
  }) {
    return Expanded(
      child: GlassContainer(
        tier: GlassTier.tertiary,
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
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
                      color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
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
