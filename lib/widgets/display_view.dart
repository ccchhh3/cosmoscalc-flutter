import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../engine/calculator_engine.dart';
import '../theme/theme.dart';

class DisplayView extends StatefulWidget {
  const DisplayView({super.key});

  @override
  State<DisplayView> createState() => _DisplayViewState();
}

class _DisplayViewState extends State<DisplayView>
    with SingleTickerProviderStateMixin {
  bool _showCopied = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  bool _wasError = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _copyToClipboard(String value) async {
    if (value.isEmpty || value == 'Error') return;
    await Clipboard.setData(ClipboardData(text: value));
    setState(() => _showCopied = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _showCopied = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final engine = context.read<CalculatorEngine>();
    if (engine.error && !_wasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _shakeCtrl.forward(from: 0);
      });
    }
    _wasError = engine.error;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorEngine>(
      builder: (context, engine, _) {
        if (engine.error && !_wasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _shakeCtrl.forward(from: 0);
          });
        }
        _wasError = engine.error;

        return GestureDetector(
          onTap: () => _copyToClipboard(engine.display),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0D1020),
                  CosmosTheme.background.withOpacity(0.95),
                ],
              ),
              border: const Border(
                bottom: BorderSide(color: Colors.white12, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: CosmosTheme.displayPaddingH,
              vertical: CosmosTheme.displayPaddingV,
            ),
            child: AnimatedBuilder(
              animation: _shakeAnim,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnim.value, 0),
                child: child,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Expression line
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      engine.expr,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: CosmosTheme.monoStyle(
                        size: 14,
                        color: CosmosTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Main display value
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        engine.display,
                        style: CosmosTheme.monoStyle(
                          size: 46,
                          weight: FontWeight.w600,
                          color: engine.error
                              ? CosmosTheme.danger
                              : CosmosTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  // Copy confirmation
                  AnimatedOpacity(
                    opacity: _showCopied ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '✓ 已复制',
                      style: CosmosTheme.monoStyle(
                        size: 12,
                        color: CosmosTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
