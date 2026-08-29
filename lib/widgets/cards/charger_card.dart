import 'package:flutter/material.dart';
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
      width: 235,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(22),
      blur: 16,
      opacity: isDark ? 0.35 : 0.85,
      color: isDark ? const Color(0xFF0B132B) : Colors.white,
      borderColor: charger.isAvailable
          ? const Color(0xFF00E676).withValues(alpha: isDark ? 0.4 : 0.6)
          : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
      borderWidth: 1.2,
      glowColor: charger.isAvailable ? const Color(0xFF00E676) : null,
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
                      ? const Color(0xFF00E676).withValues(alpha: isDark ? 0.2 : 0.15)
                      : Colors.redAccent.withValues(alpha: isDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: charger.isAvailable
                        ? const Color(0xFF00E676).withValues(alpha: 0.4)
                        : Colors.redAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  Icons.ev_station_rounded,
                  color: charger.isAvailable
                      ? const Color(0xFF00E676)
                      : Colors.redAccent.shade100,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: charger.isAvailable
                      ? const Color(0xFF00E676).withValues(alpha: isDark ? 0.2 : 0.12)
                      : Colors.redAccent.withValues(alpha: isDark ? 0.2 : 0.12),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: charger.isAvailable
                        ? (isDark ? const Color(0xFF00E676) : const Color(0xFF00A040))
                        : Colors.redAccent.shade200,
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
              color: isDark ? Colors.white : const Color(0xFF0F172A),
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
              color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Power + connector row
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 15, color: Color(0xFFFFB300)),
              const SizedBox(width: 3),
              Text(
                charger.powerLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  charger.connectorType,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B4D8),
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
                  color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
              const SizedBox(width: 2),
              Text(
                charger.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
