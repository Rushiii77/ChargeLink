import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/charger_model.dart';
import '../../services/theme_service.dart';
import '../glass/glass_container.dart';

class ChargerCard extends StatelessWidget {
  final ChargerModel charger;
  final VoidCallback onTap;

  const ChargerCard({
    super.key,
    required this.charger,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);

    return GlassContainer(
      tier: GlassTier.secondary,
      width: 235,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      borderColor: charger.isAvailable
          ? AppColors.deepTeal.withValues(alpha: isDark ? 0.40 : 0.25)
          : (isDark ? AppColors.neutral.withValues(alpha: 0.15) : AppColors.neutral.withValues(alpha: 0.10)),
      borderWidth: 1.1,
      glowColor: charger.isAvailable ? AppColors.accentLime : null,
      glowSpread: charger.isAvailable ? 1 : 0,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: icon + availability chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? AppColors.deepTeal.withValues(alpha: isDark ? 0.25 : 0.12)
                      : AppColors.error.withValues(alpha: isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: charger.isAvailable
                        ? AppColors.deepTeal.withValues(alpha: 0.35)
                        : AppColors.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  Icons.ev_station_rounded,
                  color: charger.isAvailable
                      ? (isDark ? AppColors.accentLime : AppColors.deepTeal)
                      : AppColors.error,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? AppColors.accentLime.withValues(alpha: isDark ? 0.22 : 0.30)
                      : AppColors.error.withValues(alpha: isDark ? 0.15 : 0.10),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: charger.isAvailable
                        ? (isDark ? AppColors.accentLime : AppColors.primaryDark)
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Station name
          Text(
            charger.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.neutralDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 3),

          // Address
          Text(
            charger.address,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Power + connector row
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 15, color: isDark ? AppColors.accentLime : AppColors.deepTeal),
              const SizedBox(width: 3),
              Text(
                charger.powerLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withValues(alpha: isDark ? 0.20 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.deepTeal.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  charger.connectorType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Price + rating row
          Row(
            children: [
              Text(
                '₹${charger.pricePerKwh.toStringAsFixed(0)}/kWh',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 2),
              Text(
                charger.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
