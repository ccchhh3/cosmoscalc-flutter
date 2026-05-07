import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../engine/calculator_engine.dart';
import '../theme/theme.dart';
import '../painters/space_background_painter.dart';
import '../widgets/display_view.dart';
import '../widgets/metal_button.dart';
import '../widgets/scientific_panel.dart';
import '../widgets/history_drawer.dart';
import '../widgets/converter_sheet.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  bool _showScientific = false;
  bool _showHistory    = false;
  bool _showConverter  = false;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final engine = context.read<CalculatorEngine>();
    final key    = event.logicalKey;

    if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) engine.digit('0');
    else if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) engine.digit('1');
    else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) engine.digit('2');
    else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) engine.digit('3');
    else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) engine.digit('4');
    else if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) engine.digit('5');
    else if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) engine.digit('6');
    else if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) engine.digit('7');
    else if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) engine.digit('8');
    else if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) engine.digit('9');
    else if (key == LogicalKeyboardKey.period || key == LogicalKeyboardKey.numpadDecimal) engine.digit('.');
    else if (key == LogicalKeyboardKey.add     || key == LogicalKeyboardKey.numpadAdd)      engine.operation('+');
    else if (key == LogicalKeyboardKey.minus   || key == LogicalKeyboardKey.numpadSubtract) engine.operation('−');
    else if (key == LogicalKeyboardKey.asterisk|| key == LogicalKeyboardKey.numpadMultiply) engine.operation('×');
    else if (key == LogicalKeyboardKey.slash   || key == LogicalKeyboardKey.numpadDivide)   engine.operation('÷');
    else if (key == LogicalKeyboardKey.enter   || key == LogicalKeyboardKey.numpadEnter ||
             key == LogicalKeyboardKey.equal)   engine.equals();
    else if (key == LogicalKeyboardKey.percent) engine.percent();
    else if (key == LogicalKeyboardKey.escape)  engine.clear();
    else if (key == LogicalKeyboardKey.backspace) engine.clearEntry();
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<CalculatorEngine>();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: CosmosTheme.background,
        body: Stack(
          children: [
            // Layer 1: Space background
            Positioned.fill(
              child: CustomPaint(painter: SpaceBackgroundPainter()),
            ),

            // Layer 2: Main content
            Column(
              children: [
                // Title bar zone
                const SizedBox(height: 28),

                // Toolbar
                _Toolbar(
                  showScientific: _showScientific,
                  showHistory:    _showHistory,
                  showConverter:  _showConverter,
                  angleLabel:     engine.angleModeLabel,
                  onScientific: () => setState(() {
                    _showScientific = !_showScientific;
                    if (_showScientific) _showHistory = false;
                  }),
                  onHistory: () => setState(() {
                    _showHistory = !_showHistory;
                    if (_showHistory) _showScientific = false;
                  }),
                  onConverter: () => setState(() =>
                    _showConverter = !_showConverter),
                  onAngleToggle: engine.toggleAngle,
                ),

                const Divider(height: 0.5, color: Colors.white12),

                // Main body row
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Scientific panel
                      ScientificPanel(show: _showScientific),

                      // Center: display + keypad
                      Expanded(
                        child: Column(
                          children: [
                            const DisplayView(),
                            Expanded(child: _BasicKeypad()),
                          ],
                        ),
                      ),

                      // History drawer
                      HistoryDrawer(
                        show: _showHistory,
                        onClose: () => setState(() => _showHistory = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Layer 3: Converter sheet overlay
            if (_showConverter)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: ConverterSheet(
                  onClose: () => setState(() => _showConverter = false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Toolbar ──────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final bool showScientific, showHistory, showConverter;
  final String angleLabel;
  final VoidCallback onScientific, onHistory, onConverter, onAngleToggle;

  const _Toolbar({
    required this.showScientific,
    required this.showHistory,
    required this.showConverter,
    required this.angleLabel,
    required this.onScientific,
    required this.onHistory,
    required this.onConverter,
    required this.onAngleToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          const SizedBox(width: 12),
          _PillBtn(label: '科学', active: showScientific, onTap: onScientific),
          const SizedBox(width: 8),
          _PillBtn(label: '历史', active: showHistory, onTap: onHistory),
          const SizedBox(width: 8),
          _PillBtn(label: '换算', active: showConverter, onTap: onConverter),
          const Spacer(),
          GestureDetector(
            onTap: onAngleToggle,
            child: Text(
              angleLabel,
              style: CosmosTheme.monoStyle(
                size: 13,
                color: CosmosTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _PillBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? CosmosTheme.operatorBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? CosmosTheme.accent.withOpacity(0.5)
                : CosmosTheme.borderTop.withOpacity(0.3),
            width: 0.8,
          ),
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

// ─── Basic Keypad (5×4 grid) ──────────────────────────────────────────────────

class _BasicKeypad extends StatelessWidget {
  static const _layout = [
    // Row 0
    [_K('AC', _T.clear), _K('+/-', _T.toggleSign), _K('%', _T.percent), _K('÷', _T.op)],
    // Row 1
    [_K('7', _T.digit), _K('8', _T.digit), _K('9', _T.digit), _K('×', _T.op)],
    // Row 2
    [_K('4', _T.digit), _K('5', _T.digit), _K('6', _T.digit), _K('−', _T.op)],
    // Row 3
    [_K('1', _T.digit), _K('2', _T.digit), _K('3', _T.digit), _K('+', _T.op)],
    // Row 4
    [_K('0', _T.digit, wide: true), _K('.', _T.digit), _K('=', _T.equals)],
  ];

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<CalculatorEngine>();

    return Padding(
      padding: const EdgeInsets.all(CosmosTheme.keypadPadding),
      child: Column(
        children: [
          for (final row in _layout) ...[
            Expanded(
              child: Row(
                children: [
                  for (int i = 0; i < row.length; i++) ...[
                    if (i > 0) const SizedBox(width: CosmosTheme.buttonGap),
                    Expanded(
                      flex: row[i].wide ? 2 : 1,
                      child: _buildKey(context, engine, row[i]),
                    ),
                  ],
                ],
              ),
            ),
            if (row != _layout.last)
              const SizedBox(height: CosmosTheme.buttonGap),
          ],
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, CalculatorEngine engine, _K key) {
    switch (key.type) {
      case _T.digit:
        return MetalButton(
          label: key.label,
          onTap: () => engine.digit(key.label),
        );
      case _T.op:
        return OperatorButton(
          label: key.label,
          onTap: () => engine.operation(key.label),
        );
      case _T.equals:
        return EqualsButton(
          pulsing: engine.pulseEq,
          onTap: engine.equals,
        );
      case _T.clear:
        return MetalButton(
          label: engine.display != '0' || engine.hasPending ? 'C' : 'AC',
          textColor: CosmosTheme.accent,
          onTap: engine.clear,
        );
      case _T.toggleSign:
        return MetalButton(
          label: key.label,
          textColor: CosmosTheme.accent,
          onTap: engine.toggleSign,
        );
      case _T.percent:
        return MetalButton(
          label: key.label,
          textColor: CosmosTheme.accent,
          onTap: engine.percent,
        );
    }
  }
}

enum _T { digit, op, equals, clear, toggleSign, percent }

class _K {
  final String label;
  final _T type;
  final bool wide;
  const _K(this.label, this.type, {this.wide = false});
}
