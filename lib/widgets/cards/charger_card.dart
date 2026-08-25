import 'package:flutter/material.dart';
import '../../models/charger_model.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                          ? const Color(0xFFE8FFF0)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.ev_station_rounded,
                      color: charger.isAvailable
                          ? const Color(0xFF00C853)
                          : Colors.red.shade400,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: charger.isAvailable
                          ? const Color(0xFFE8FFF0)
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      charger.isAvailable ? 'Available' : 'Busy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: charger.isAvailable
                            ? const Color(0xFF00C853)
                            : Colors.red.shade700,
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
                  color: Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Address
              Text(
                charger.address,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Power + connector row
              Row(
                children: [
                  Icon(Icons.bolt, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    charger.powerLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      charger.connectorType,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C853),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.star_rounded, size: 15, color: Colors.amber.shade600),
                  const SizedBox(width: 2),
                  Text(
                    charger.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

