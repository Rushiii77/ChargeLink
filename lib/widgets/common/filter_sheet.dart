import 'package:flutter/material.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              const Text(
                'Filter Chargers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
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
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Charger Type
          _buildSectionLabel('Charger Type'),
          const SizedBox(height: 8),
          _buildChipGroup(
            options: ['All', 'AC', 'DC'],
            selected: _filter.chargerType,
            onSelected: (v) =>
                setState(() => _filter = _filter.copyWith(chargerType: v)),
          ),

          const SizedBox(height: 16),

          // Connector Type
          _buildSectionLabel('Connector Type'),
          const SizedBox(height: 8),
          _buildChipGroup(
            options: ['All', 'CCS2', 'Type2', 'CHAdeMO'],
            selected: _filter.connectorType,
            onSelected: (v) =>
                setState(() => _filter = _filter.copyWith(connectorType: v)),
          ),

          const SizedBox(height: 16),

          // Minimum Power
          _buildSectionLabel('Minimum Power / Speed'),
          const SizedBox(height: 8),
          _buildChipGroupDouble(
            options: const [0, 7.4, 22, 50, 100],
            labels: const ['Any', '7+ kW', '22+ kW', '50+ kW', '100+ kW'],
            selected: _filter.minPowerKw,
            onSelected: (v) =>
                setState(() => _filter = _filter.copyWith(minPowerKw: v)),
          ),

          const SizedBox(height: 16),

          // Availability
          _buildSectionLabel('Availability'),
          const SizedBox(height: 4),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Show available stations only',
              style: TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            ),
            value: _filter.availableOnly,
            activeTrackColor: const Color(0xFF00C853).withValues(alpha: 0.5),
            activeThumbColor: const Color(0xFF00C853),
            onChanged: (v) =>
                setState(() => _filter = _filter.copyWith(availableOnly: v)),
          ),

          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(_filter);
              },
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required String selected,
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
          selectedColor: const Color(0xFFE8FFF0),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF00C853) : const Color(0xFF1A1A2E),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
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
          selectedColor: const Color(0xFFE8FFF0),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFF00C853) : const Color(0xFF1A1A2E),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? const Color(0xFF00C853) : const Color(0xFFE5E7EB),
            ),
          ),
        );
      }),
    );
  }
}

