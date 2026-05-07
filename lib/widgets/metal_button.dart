import 'package:flutter/material.dart';
import '../theme/theme.dart';

// ─── Base metal button ────────────────────────────────────────────────────────

class MetalButton extends StatefulWidget {
  final String label;
  final double fontSize;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool isWide;

  const MetalButton({
    super.key,
    required this.label,
    this.fontSize = 20,
    this.bgColor = CosmosTheme.buttonBg,
    this.textColor = CosmosTheme.textPrimary,
    this.onTap,
    this.isWide = false,
  });

  @override
  State<MetalButton> createState() => _MetalButtonState();
}

class _MetalButtonState extends State<MetalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            color: widget.bgColor.withOpacity(_pressed ? 0.85 : 0.65),
            borderRadius: BorderRadius.circular(CosmosTheme.buttonRadius),
            border: Border.all(color: CosmosTheme.borderTop, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Glossy top highlight
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(CosmosTheme.buttonRadius),
                      topRight: Radius.circular(CosmosTheme.buttonRadius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.label,
                  style: CosmosTheme.monoStyle(
                    size: widget.fontSize,
                    color: widget.textColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Operator button (÷ × − +) ───────────────────────────────────────────────

class OperatorButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const OperatorButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => MetalButton(
    label: label,
    bgColor: CosmosTheme.operatorBg,
    textColor: CosmosTheme.accent,
    fontSize: 22,
    onTap: onTap,
  );
}

// ─── Equals button (blue gradient + glow) ────────────────────────────────────

class EqualsButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool pulsing;

  const EqualsButton({super.key, this.onTap, this.pulsing = false});

  @override
  State<EqualsButton> createState() => _EqualsButtonState();
}

class _EqualsButtonState extends State<EqualsButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final glowRadius = widget.pulsing ? 28.0 : 18.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CosmosTheme.buttonRadius),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [CosmosTheme.equalStart, CosmosTheme.equalEnd],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: CosmosTheme.equalStart.withOpacity(0.5),
                blurRadius: glowRadius,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(CosmosTheme.buttonRadius),
                      topRight: Radius.circular(CosmosTheme.buttonRadius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '=',
                  style: CosmosTheme.monoStyle(
                    size: 24,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Scientific button (smaller, in left panel) ──────────────────────────────

class ScientificButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onTap;

  const ScientificButton({
    super.key,
    required this.label,
    this.bgColor = CosmosTheme.functionBg,
    this.textColor = const Color(0xFF8BAFD4),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => MetalButton(
    label: label,
    bgColor: bgColor,
    textColor: textColor,
    fontSize: 13,
    onTap: onTap,
  );
}
