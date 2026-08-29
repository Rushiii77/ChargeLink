import 'package:flutter/material.dart';
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
              color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.15),
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
                    color: const Color(0xFF00E676).withValues(alpha: isDark ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF00E676),
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
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        "Optimized charging recommendations based on telemetry",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
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
                                color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              "Target: ${_targetBattery.toInt()}%",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00E676),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF00E676),
                            inactiveTrackColor: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.1),
                            thumbColor: const Color(0xFF00E676),
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
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                            selectedColor: const Color(0xFF00E676)
                                .withValues(alpha: isDark ? 0.25 : 0.2),
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.04),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF00E676) : const Color(0xFF00A040))
                                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF00E676)
                                    : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
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
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
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
    return GlassContainer(
      tier: GlassTier.secondary,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      borderColor: rec.score > 85
          ? const Color(0xFF00E676).withValues(alpha: 0.5)
          : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
      borderWidth: rec.score > 85 ? 1.5 : 1,
      glowColor: rec.score > 85 ? const Color(0xFF00E676) : null,
      glowSpread: rec.score > 85 ? 1 : 0,
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
                  color: const Color(0xFF00E676).withValues(alpha: isDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00E676).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFF00E676)),
                    const SizedBox(width: 4),
                    Text(
                      rec.tag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  "${rec.score.toInt()}% Match",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rec.charger.address,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Reasoning Note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFFB300)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rec.reasoning,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF334155),
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
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Text("•", style: TextStyle(color: isDark ? Colors.white38 : Colors.black26)),
              const SizedBox(width: 8),
              Text(
                "Est. ₹${rec.estimatedCost.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF00E676) : const Color(0xFF00A040),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: const Color(0xFF0B132B),
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
