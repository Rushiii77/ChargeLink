import 'package:flutter/material.dart';
import '../../models/charger_model.dart';
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
    return GlassContainer(
      width: 230,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(22),
      blur: 20,
      opacity: 0.35,
      color: const Color(0xFF0B132B),
      borderColor: charger.isAvailable
          ? const Color(0xFF00E676).withValues(alpha: 0.4)
          : Colors.white.withValues(alpha: 0.15),
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
                      ? const Color(0xFF00E676).withValues(alpha: 0.2)
                      : Colors.redAccent.withValues(alpha: 0.2),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: charger.isAvailable
                        ? const Color(0xFF00E676)
                        : Colors.redAccent.shade100,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Station name
          Text(
            charger.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
              color: Colors.white.withValues(alpha: 0.65),
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
                    color: Color(0xFF00E5FF),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
              const SizedBox(width: 2),
              Text(
                charger.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
