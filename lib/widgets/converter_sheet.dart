import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ConverterSheet extends StatefulWidget {
  final VoidCallback onClose;
  const ConverterSheet({super.key, required this.onClose});

  @override
  State<ConverterSheet> createState() => _ConverterSheetState();
}

class _ConverterSheetState extends State<ConverterSheet> {
  int _categoryIndex = 0;
  final TextEditingController _inputCtrl = TextEditingController(text: '1');

  // Category definitions
  static const _categories = ['长度', '重量', '温度', '面积', '体积'];

  static const _units = [
    ['m', 'cm', 'mm', 'km', 'in', 'ft', 'mi'],         // length
    ['kg', 'g', 'mg', 'lb', 'oz'],                       // weight
    ['°C', '°F', 'K'],                                    // temperature
    ['m²', 'km²', 'ft²', 'acre'],                        // area
    ['L', 'mL', 'm³', 'gal'],                            // volume
  ];

  // Conversion to base unit (SI)
  static const _toBase = [
    // length → metres
    {'m': 1, 'cm': 0.01, 'mm': 0.001, 'km': 1000.0, 'in': 0.0254, 'ft': 0.3048, 'mi': 1609.344},
    // weight → kg
    {'kg': 1, 'g': 0.001, 'mg': 1e-6, 'lb': 0.453592, 'oz': 0.0283495},
    // temperature: special handling
    null,
    // area → m²
    {'m²': 1, 'km²': 1e6, 'ft²': 0.092903, 'acre': 4046.86},
    // volume → litres
    {'L': 1, 'mL': 0.001, 'm³': 1000.0, 'gal': 3.78541},
  ];

  String _fromUnit = '';
  String _toUnit   = '';

  @override
  void initState() {
    super.initState();
    _resetUnits();
  }

  void _resetUnits() {
    final units = _units[_categoryIndex];
    _fromUnit = units[0];
    _toUnit   = units.length > 1 ? units[1] : units[0];
  }

  double _convert(double value, String from, String to) {
    if (_categoryIndex == 2) {
      // Temperature special handling
      double celsius;
      switch (from) {
        case '°F': celsius = (value - 32) / 1.8; break;
        case 'K':  celsius = value - 273.15; break;
        default:   celsius = value;
      }
      switch (to) {
        case '°F': return celsius * 1.8 + 32;
        case 'K':  return celsius + 273.15;
        default:   return celsius;
      }
    }
    final map = _toBase[_categoryIndex]!;
    final base = value * (map[from] ?? 1.0);
    return base / (map[to] ?? 1.0);
  }

  String _formatResult(double v) {
    if (v.isNaN || v.isInfinite) return '—';
    if (v.abs() >= 1e12 || (v != 0 && v.abs() < 1e-6)) {
      return v.toStringAsExponential(4);
    }
    final s = v.toStringAsFixed(8);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputVal = double.tryParse(_inputCtrl.text) ?? 0;
    final result   = _convert(inputVal, _fromUnit, _toUnit);
    final resultStr = _formatResult(result);

    return Container(
      decoration: BoxDecoration(
        color: CosmosTheme.panelBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          const SizedBox(height: 10),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: CosmosTheme.textSecondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('单位换算',
                  style: CosmosTheme.monoStyle(
                    size: 15,
                    weight: FontWeight.w600,
                    color: CosmosTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onClose,
                  child: const Icon(Icons.close,
                    color: CosmosTheme.textSecondary, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Category tabs
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => _CategoryTab(
                label: _categories[i],
                active: i == _categoryIndex,
                onTap: () => setState(() {
                  _categoryIndex = i;
                  _resetUnits();
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Conversion rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _ConversionRow(
                  value: _inputCtrl.text,
                  unit: _fromUnit,
                  units: _units[_categoryIndex],
                  onUnitChanged: (u) => setState(() => _fromUnit = u),
                  onValueChanged: (v) => setState(() {}),
                  controller: _inputCtrl,
                  readOnly: false,
                ),
                const SizedBox(height: 8),
                // Swap button
                GestureDetector(
                  onTap: () => setState(() {
                    final tmp = _fromUnit;
                    _fromUnit = _toUnit;
                    _toUnit   = tmp;
                  }),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2840),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CosmosTheme.accent.withOpacity(0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.swap_vert,
                      color: CosmosTheme.accent, size: 20),
                  ),
                ),
                const SizedBox(height: 8),
                _ConversionRow(
                  value: resultStr,
                  unit: _toUnit,
                  units: _units[_categoryIndex],
                  onUnitChanged: (u) => setState(() => _toUnit = u),
                  onValueChanged: null,
                  controller: null,
                  readOnly: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CategoryTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? CosmosTheme.operatorBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active
              ? Border.all(color: CosmosTheme.accent.withOpacity(0.5), width: 1)
              : Border.all(color: CosmosTheme.borderTop.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: CosmosTheme.monoStyle(
            size: 13,
            color: active ? CosmosTheme.accent : CosmosTheme.textSecondary,
            weight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ConversionRow extends StatelessWidget {
  final String value;
  final String unit;
  final List<String> units;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<String>? onValueChanged;
  final TextEditingController? controller;
  final bool readOnly;

  const _ConversionRow({
    required this.value,
    required this.unit,
    required this.units,
    required this.onUnitChanged,
    required this.onValueChanged,
    required this.controller,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CosmosTheme.cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CosmosTheme.borderTop.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: readOnly
                ? Text(
                    value,
                    style: CosmosTheme.monoStyle(
                      size: 24,
                      weight: FontWeight.bold,
                      color: CosmosTheme.accent,
                    ),
                  )
                : TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                    style: CosmosTheme.monoStyle(
                      size: 24,
                      weight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onValueChanged,
                  ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: unit,
            dropdownColor: CosmosTheme.cardBg,
            style: CosmosTheme.monoStyle(
              size: 14, color: CosmosTheme.textSecondary),
            underline: const SizedBox.shrink(),
            items: units.map((u) => DropdownMenuItem(
              value: u,
              child: Text(u),
            )).toList(),
            onChanged: (v) { if (v != null) onUnitChanged(v); },
          ),
        ],
      ),
    );
  }
}
