import 'dart:math';
import '../models/charger_model.dart';

class RecommendationResult {
  final ChargerModel charger;
  final double score; // 0 to 100
  final String tag; // "Fastest", "Best Value", "Nearest"
  final String reasoning;
  final double estimatedTimeMinutes;
  final double estimatedCost;

  RecommendationResult({
    required this.charger,
    required this.score,
    required this.tag,
    required this.reasoning,
    required this.estimatedTimeMinutes,
    required this.estimatedCost,
  });
}

class AIRecommendationService {
  // Approximate distance calculation using Haversine formula (in km)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  List<RecommendationResult> getRecommendations({
    required List<ChargerModel> allChargers,
    required double userLat,
    required double userLng,
    required double currentBatteryPercent,
    required double targetBatteryPercent,
    required String preference, // 'Fastest', 'Best Value', 'Nearest', 'Balanced'
  }) {
    if (allChargers.isEmpty) return [];

    const batteryCapacityKwh = 45.0; // Typical EV battery
    final batteryDeltaPercent = (targetBatteryPercent - currentBatteryPercent).clamp(5.0, 100.0);
    final energyNeededKwh = (batteryDeltaPercent / 100.0) * batteryCapacityKwh;

    final results = <RecommendationResult>[];

    for (final charger in allChargers) {
      if (!charger.isAvailable) continue; // Skip unavailable chargers for top picks

      final distanceKm = calculateDistance(
        userLat,
        userLng,
        charger.latitude,
        charger.longitude,
      );

      // Estimated charging time (hours) = energyNeeded / powerKw
      final chargingTimeHours = energyNeededKwh / charger.powerKw;
      final chargingTimeMins = (chargingTimeHours * 60).clamp(10.0, 180.0);

      // Estimated cost = energyNeeded * pricePerKwh
      final estimatedCost = energyNeededKwh * charger.pricePerKwh;

      // Scoring factors (normalized)
      final distanceScore = (10.0 - distanceKm.clamp(0.0, 10.0)) * 10; // Max 100
      final speedScore = (charger.powerKw / 120.0).clamp(0.0, 1.0) * 100; // Max 100
      final priceScore = ((25.0 - charger.pricePerKwh.clamp(10.0, 25.0)) / 15.0) * 100; // Lower price = higher score
      final ratingScore = (charger.rating / 5.0) * 100;

      double totalScore = 0;
      String tag = "Recommended";
      String reason = "";

      switch (preference) {
        case 'Fastest':
          totalScore = (speedScore * 0.5) + (distanceScore * 0.25) + (ratingScore * 0.25);
          tag = "Fastest Charging";
          reason = "${charger.powerKw.toInt()} kW ${charger.chargerType} gets you to ${targetBatteryPercent.toInt()}% in just ${chargingTimeMins.toInt()} mins.";
          break;

        case 'Best Value':
          totalScore = (priceScore * 0.5) + (distanceScore * 0.25) + (ratingScore * 0.25);
          tag = "Lowest Price";
          reason = "Economical ₹${charger.pricePerKwh.toStringAsFixed(0)}/kWh rate saves you money on ~${energyNeededKwh.toStringAsFixed(1)} kWh.";
          break;

        case 'Nearest':
          totalScore = (distanceScore * 0.6) + (speedScore * 0.2) + (ratingScore * 0.2);
          tag = "Closest to You";
          reason = "Located just ${distanceKm.toStringAsFixed(1)} km away with zero queue time.";
          break;

        default: // Balanced
          totalScore = (distanceScore * 0.3) + (speedScore * 0.3) + (priceScore * 0.2) + (ratingScore * 0.2);
          tag = "Optimal Balance";
          reason = "High speed (${charger.powerKw.toInt()} kW) paired with ${distanceKm.toStringAsFixed(1)} km proximity and ★ ${charger.rating.toStringAsFixed(1)} rating.";
          break;
      }

      results.add(
        RecommendationResult(
          charger: charger,
          score: totalScore.clamp(0.0, 100.0),
          tag: tag,
          reasoning: reason,
          estimatedTimeMinutes: chargingTimeMins,
          estimatedCost: estimatedCost,
        ),
      );
    }

    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

