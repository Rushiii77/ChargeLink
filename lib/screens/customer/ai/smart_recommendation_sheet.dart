import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/charger_model.dart';
import '../../../services/ai_recommendation_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/glass/glass_container.dart';
import '../booking/booking_screen.dart';

class SmartRecommendationSheet extends StatefulWidget {
  final List<ChargerModel> allChargers;
  final double userLat;
  final double userLng;

  const SmartRecommendationSheet({
    super.key,
    required this.allChargers,
    required this.userLat,
    required this.userLng,
  });

  @override
  State<SmartRecommendationSheet> createState() =>
      _SmartRecommendationSheetState();
}

class _SmartRecommendationSheetState extends State<SmartRecommendationSheet> {
  final AIRecommendationService _aiService = AIRecommendationService();

  final double _currentBattery = 20.0;
  double _targetBattery = 80.0;
  String _selectedPreference = 'Balanced';

  final List<String> _preferences = ['Balanced', 'Fastest', 'Best Value', 'Nearest'];

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);

    final recommendations = _aiService.getRecommendations(
      allChargers: widget.allChargers,
      userLat: widget.userLat,
      userLng: widget.userLng,
      currentBatteryPercent: _currentBattery,
      targetBatteryPercent: _targetBattery,
      preference: _selectedPreference,
    );

    return GlassContainer(
      tier: GlassTier.primary,
      height: MediaQuery.of(context).size.height * 0.85,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.neutral.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.deepTeal.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.deepTeal.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Smart Mobility Engine",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.neutralDark,
                        ),
                      ),
                      Text(
                        "Optimized charging recommendations based on telemetry",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? AppColors.neutral.withValues(alpha: 0.2) : AppColors.neutral.withValues(alpha: 0.12),
          ),

          // Scrollable Area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Battery Slider Box
                  GlassContainer(
                    tier: GlassTier.secondary,
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Current: ${_currentBattery.toInt()}%",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                              ),
                            ),
                            Text(
                              "Target: ${_targetBattery.toInt()}%",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.deepTeal,
                            inactiveTrackColor: isDark
                                ? AppColors.neutral.withValues(alpha: 0.25)
                                : AppColors.neutral.withValues(alpha: 0.15),
                            thumbColor: isDark ? AppColors.accentLime : AppColors.deepTeal,
                          ),
                          child: Slider(
                            value: _targetBattery,
                            min: 30,
                            max: 100,
                            divisions: 14,
                            onChanged: (val) => setState(() => _targetBattery = val),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Preference Chips
                  Text(
                    "Optimization Goal",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _preferences.map((pref) {
                        final isSelected = _selectedPreference == pref;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(pref),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _selectedPreference = pref),
                            selectedColor: isDark
                                ? AppColors.deepTeal.withValues(alpha: 0.40)
                                : AppColors.accentLime.withValues(alpha: 0.35),
                            backgroundColor: isDark
                                ? AppColors.darkCard
                                : AppColors.white.withValues(alpha: 0.7),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? (isDark ? AppColors.accentLime : AppColors.deepTeal)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.neutral),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? (isDark ? AppColors.accentLime : AppColors.deepTeal)
                                    : (isDark ? AppColors.neutral.withValues(alpha: 0.2) : AppColors.neutral.withValues(alpha: 0.15)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Match List
                  Text(
                    "Optimal Matches (${recommendations.length})",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (recommendations.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          "No stations available for this criteria.",
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
                          ),
                        ),
                      ),
                    )
                  else
                    ...recommendations.map((rec) => _buildRecommendationCard(rec, isDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendationResult rec, bool isDark) {
    final isTopMatch = rec.score > 85;

    return GlassContainer(
      tier: GlassTier.secondary,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      borderColor: isTopMatch
          ? (isDark ? AppColors.accentLime.withValues(alpha: 0.5) : AppColors.deepTeal.withValues(alpha: 0.35))
          : (isDark ? AppColors.neutral.withValues(alpha: 0.15) : AppColors.neutral.withValues(alpha: 0.10)),
      borderWidth: isTopMatch ? 1.4 : 1,
      glowColor: isTopMatch ? AppColors.accentLime : null,
      glowSpread: isTopMatch ? 1 : 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag + Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.deepTeal.withValues(alpha: 0.35)
                      : AppColors.accentLime.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppColors.accentLime.withValues(alpha: 0.5)
                        : AppColors.deepTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: isDark ? AppColors.accentLime : AppColors.deepTeal),
                    const SizedBox(width: 4),
                    Text(
                      rec.tag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.accentLime : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.neutral.withValues(alpha: 0.25) : AppColors.neutral.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  "${rec.score.toInt()}% Match",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.neutralDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Name
          Text(
            rec.charger.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.neutralDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rec.charger.address,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.neutral,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Reasoning Note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard.withValues(alpha: 0.6) : AppColors.lightBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.neutral.withValues(alpha: 0.15) : AppColors.neutral.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: isDark ? AppColors.accentLime : AppColors.deepTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rec.reasoning,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkText : AppColors.neutralDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Specs + Button
          Row(
            children: [
              Text(
                "~${rec.estimatedTimeMinutes.toInt()} mins",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.neutralDark,
                ),
              ),
              const SizedBox(width: 8),
              Text("•", style: TextStyle(color: isDark ? AppColors.neutral : AppColors.neutral.withValues(alpha: 0.5))),
              const SizedBox(width: 8),
              Text(
                "Est. ₹${rec.estimatedCost.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.accentLime : AppColors.deepTeal,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(charger: rec.charger),
                    ),
                  );
                },
                child: const Text(
                  "Book Slot",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
