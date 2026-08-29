import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
                color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.neutral.withValues(alpha: 0.3),
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
                    color: isDark ? AppColors.darkText : AppColors.neutralDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? AppColors.accentLime.withValues(alpha: isDark ? 0.25 : 0.35)
                      : AppColors.error.withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: charger.isAvailable
                        ? AppColors.accentLime.withValues(alpha: 0.6)
                        : AppColors.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  charger.isAvailable ? '● Available' : '● Busy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: charger.isAvailable
                        ? (isDark ? AppColors.accentLime : AppColors.primaryDark)
                        : AppColors.error,
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
                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  charger.address,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(
            color: isDark ? AppColors.neutral.withValues(alpha: 0.2) : AppColors.neutral.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 16),

          // 2x2 Glass Specs Grid
          Row(
            children: [
              _glassSpecTile(
                icon: Icons.bolt_rounded,
                iconColor: isDark ? AppColors.accentLime : AppColors.deepTeal,
                label: 'Charging Speed',
                value: charger.powerLabel,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _glassSpecTile(
                icon: Icons.electrical_services_rounded,
                iconColor: AppColors.primaryLight,
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
                iconColor: isDark ? AppColors.accentLime : AppColors.deepTeal,
                label: 'Energy Rate',
                value: '₹${charger.pricePerKwh.toStringAsFixed(0)} / kWh',
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _glassSpecTile(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: 'User Rating',
                value: charger.ratingLabel,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Book Now Button
          GlassButton(
            text: charger.isAvailable ? 'RESERVE CHARGING SLOT' : 'CURRENTLY OCCUPIED',
            icon: Icons.flash_on_rounded,
            variant: charger.isAvailable ? GlassButtonVariant.primary : GlassButtonVariant.secondary,
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
                color: iconColor.withValues(alpha: isDark ? 0.20 : 0.10),
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
                      color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.neutralDark,
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
