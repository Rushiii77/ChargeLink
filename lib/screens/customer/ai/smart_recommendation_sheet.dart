import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../services/ai_recommendation_service.dart';
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
    final recommendations = _aiService.getRecommendations(
      allChargers: widget.allChargers,
      userLat: widget.userLat,
      userLng: widget.userLng,
      currentBatteryPercent: _currentBattery,
      targetBatteryPercent: _targetBattery,
      preference: _selectedPreference,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header with AI Sparkles icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF00C853),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Smart AI Recommender",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        "Instant match based on your battery & goals",
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Scrollable Settings & Recommendations
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Battery Slider Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Current: ${_currentBattery.toInt()}%",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              "Target: ${_targetBattery.toInt()}%",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00C853),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF00C853),
                            inactiveTrackColor: const Color(0xFFE5E7EB),
                            thumbColor: const Color(0xFF00C853),
                            trackHeight: 6,
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

                  // Goal Chips
                  const Text(
                    "Optimization Priority",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _preferences.map((pref) {
                        final isSelected = pref == _selectedPreference;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(pref == 'Balanced' ? '⚡ AI Optimal' : pref),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _selectedPreference = pref),
                            selectedColor: const Color(0xFFE8FFF0),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF00C853)
                                  : const Color(0xFF1A1A2E),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recommendations List
                  Text(
                    "Top Matches (${recommendations.length})",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (recommendations.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          "No stations available for this criteria.",
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  else
                    ...recommendations.map((rec) => _buildRecommendationCard(rec)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendationResult rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rec.score > 85 ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
          width: rec.score > 85 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tag + Score Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFF00C853)),
                      const SizedBox(width: 4),
                      Text(
                        rec.tag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C853),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${rec.score.toInt()}% Match",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Station Name
            Text(
              rec.charger.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              rec.charger.address,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            // AI Reasoning Note
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rec.reasoning,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Specs Row
            Row(
              children: [
                Text(
                  "~${rec.estimatedTimeMinutes.toInt()} mins",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(width: 8),
                const Text("•", style: TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(width: 8),
                Text(
                  "Est. ₹${rec.estimatedCost.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00C853)),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                  child: const Text("Book Slot", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
