import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/calculator_engine.dart';
import '../theme/theme.dart';
import 'metal_button.dart';

class ScientificPanel extends StatelessWidget {
  final bool show;
  const ScientificPanel({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: show ? CosmosTheme.scientificWidth : 0,
      child: show ? _PanelContent() : const SizedBox.shrink(),
    );
  }
}

class _PanelContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final engine = context.watch<CalculatorEngine>();

    final buttons = [
      // Row 1
      _Btn.unary('sin'),   _Btn.unary('cos'),   _Btn.unary('tan'),
      _Btn.mode(engine.angleModeLabel),
      // Row 2
      _Btn.unary('sin⁻¹'), _Btn.unary('cos⁻¹'), _Btn.unary('tan⁻¹'),
      _Btn.const_('π'),
      // Row 3
      _Btn.unary('eˣ'),    _Btn.unary('10ˣ'),   _Btn.unary('ln'),
      _Btn.const_('e'),
      // Row 4
      _Btn.unary('log'),   _Btn.unary('log₂'),  _Btn.unary('x²'),
      _Btn.unary('x³'),
      // Row 5
      _Btn.op2('xʸ'),      _Btn.unary('√x'),    _Btn.unary('∛x'),
      _Btn.op2('ⁿ√x'),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CosmosTheme.panelBg,
            CosmosTheme.background,
          ],
        ),
        border: const Border(
          right: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          for (int row = 0; row < 5; row++)
            Expanded(
              child: Row(
                children: [
                  for (int col = 0; col < 4; col++) ...[
                    if (col > 0) const SizedBox(width: 5),
                    Expanded(
                      child: _buildButton(
                        context, engine, buttons[row * 4 + col],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (true) const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, CalculatorEngine engine, _Btn b) {
    switch (b.type) {
      case _BtnType.unary:
        return ScientificButton(
          label: b.label,
          onTap: () => engine.applyUnary(b.label),
        );
      case _BtnType.mode:
        return ScientificButton(
          label: b.label,
          bgColor: CosmosTheme.modeBg,
          textColor: CosmosTheme.accent,
          onTap: () => engine.toggleAngle(),
        );
      case _BtnType.const_:
        return ScientificButton(
          label: b.label,
          bgColor: CosmosTheme.constBg,
          textColor: CosmosTheme.success,
          onTap: () => engine.inputConstant(b.label),
        );
      case _BtnType.op2:
        return ScientificButton(
          label: b.label,
          bgColor: CosmosTheme.op2Bg,
          textColor: CosmosTheme.accent,
          onTap: () => engine.applyBinaryOp(b.label),
        );
    }
  }
}

enum _BtnType { unary, mode, const_, op2 }

class _Btn {
  final String label;
  final _BtnType type;
  const _Btn._(this.label, this.type);
  factory _Btn.unary(String l)  => _Btn._(l, _BtnType.unary);
  factory _Btn.mode(String l)   => _Btn._(l, _BtnType.mode);
  factory _Btn.const_(String l) => _Btn._(l, _BtnType.const_);
  factory _Btn.op2(String l)    => _Btn._(l, _BtnType.op2);
}
