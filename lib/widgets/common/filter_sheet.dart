import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import '../glass/glass_button.dart';
import '../glass/glass_container.dart';

class ChargerFilter {
  final String chargerType; // 'All', 'AC', 'DC'
  final String connectorType; // 'All', 'CCS2', 'Type2', 'CHAdeMO'
  final double minPowerKw; // 0 = no filter
  final bool availableOnly;

  const ChargerFilter({
    this.chargerType = 'All',
    this.connectorType = 'All',
    this.minPowerKw = 0,
    this.availableOnly = false,
  });

  ChargerFilter copyWith({
    String? chargerType,
    String? connectorType,
    double? minPowerKw,
    bool? availableOnly,
  }) {
    return ChargerFilter(
      chargerType: chargerType ?? this.chargerType,
      connectorType: connectorType ?? this.connectorType,
      minPowerKw: minPowerKw ?? this.minPowerKw,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }

  bool get isActive =>
      chargerType != 'All' ||
      connectorType != 'All' ||
      minPowerKw > 0 ||
      availableOnly;
}

class FilterSheet extends StatefulWidget {
  final ChargerFilter initialFilter;
  final ValueChanged<ChargerFilter> onApply;

  const FilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late ChargerFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark(context);

    return GlassContainer(
      tier: GlassTier.primary,
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
          const SizedBox(height: 18),

          Row(
            children: [
              Text(
                'Filter Stations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filter = const ChargerFilter();
                  });
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    color: Color(0xFFF43F5E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Charger Type
          _buildSectionLabel('Current Standard', isDark),
          const SizedBox(height: 8),
          _buildChipGroup(
            options: ['All', 'AC', 'DC'],
            selected: _filter.chargerType,
            isDark: isDark,
            onSelected: (v) =>
                setState(() => _filter = _filter.copyWith(chargerType: v)),
          ),

          const SizedBox(height: 16),

          // Connector Type
          _buildSectionLabel('Connector Port', isDark),
          const SizedBox(height: 8),
          _buildChipGroup(
            options: ['All', 'CCS2', 'Type2', 'CHAdeMO'],
            selected: _filter.connectorType,
            isDark: isDark,
            onSelected: (v) =>
                setState(() => _filter = _filter.copyWith(connectorType: v)),
          ),

          const SizedBox(height: 16),

          // Minimum Power
          _buildSectionLabel('Minimum Speed Rating', isDark),
          const SizedBox(height: 8),
          _buildChipGroupDouble(
            options: const [0, 7.4, 22, 50, 100],
            labels: const ['Any', '7+ kW', '22+ kW', '50+ kW', '100+ kW'],
            selected: _filter.minPowerKw,
            isDark: isDark,
            onSelected: (v) =>
                setState(() => _filter = _filter.copyWith(minPowerKw: v)),
          ),

          const SizedBox(height: 16),

          // Availability Switch
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Show available stations only',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
            ),
            value: _filter.availableOnly,
            activeTrackColor: const Color(0xFF00E676).withValues(alpha: 0.5),
            activeThumbColor: const Color(0xFF00E676),
            onChanged: (v) =>
                setState(() => _filter = _filter.copyWith(availableOnly: v)),
          ),

          const SizedBox(height: 20),

          // Apply button
          GlassButton(
            text: 'APPLY FILTERS',
            icon: Icons.check_rounded,
            onPressed: () {
              Navigator.pop(context);
              widget.onApply(_filter);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF475569),
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required String selected,
    required bool isDark,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (_) => onSelected(opt),
          selectedColor: const Color(0xFF00E676).withValues(alpha: isDark ? 0.25 : 0.2),
          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
          labelStyle: TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFF00E676) : const Color(0xFF00A040))
                : (isDark ? Colors.white70 : const Color(0xFF475569)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        );
      }).toList(),
    );
  }

  Widget _buildChipGroupDouble({
    required List<double> options,
    required List<String> labels,
    required double selected,
    required bool isDark,
    required ValueChanged<double> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      children: List.generate(options.length, (i) {
        final isSelected = options[i] == selected;
        return ChoiceChip(
          label: Text(labels[i]),
          selected: isSelected,
          onSelected: (_) => onSelected(options[i]),
          selectedColor: const Color(0xFF00E676).withValues(alpha: isDark ? 0.25 : 0.2),
          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
          labelStyle: TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFF00E676) : const Color(0xFF00A040))
                : (isDark ? Colors.white70 : const Color(0xFF475569)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        );
      }),
    );
  }
}
