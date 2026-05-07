import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/calculator_engine.dart';
import '../theme/theme.dart';

class HistoryDrawer extends StatelessWidget {
  final bool show;
  final VoidCallback onClose;

  const HistoryDrawer({super.key, required this.show, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: show ? CosmosTheme.historyWidth : 0,
      child: show ? _DrawerContent(onClose: onClose) : const SizedBox.shrink(),
    );
  }
}

class _DrawerContent extends StatelessWidget {
  final VoidCallback onClose;
  const _DrawerContent({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<CalculatorEngine>();

    return Container(
      decoration: const BoxDecoration(
        color: CosmosTheme.historyBg,
        border: Border(
          left: BorderSide(color: Colors.white12, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(-8, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Text(
                  '计算历史',
                  style: CosmosTheme.monoStyle(
                    size: 13,
                    color: CosmosTheme.textSecondary,
                    weight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (engine.history.isNotEmpty)
                  _IconBtn(
                    icon: Icons.delete_outline,
                    color: CosmosTheme.danger,
                    onTap: () => _confirmClear(context, engine),
                  ),
                const SizedBox(width: 4),
                _IconBtn(
                  icon: Icons.close,
                  color: CosmosTheme.textSecondary,
                  onTap: onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, color: Colors.white12),
          // History list or empty state
          Expanded(
            child: engine.history.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    itemCount: engine.history.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0.5, color: Colors.white12),
                    itemBuilder: (context, index) => _HistoryRow(
                      entry: engine.history[index],
                      onTap: () {
                        engine.recallHistory(engine.history[index]);
                        onClose();
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, CalculatorEngine engine) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CosmosTheme.cardBg,
        title: Text('清除历史', style: TextStyle(color: CosmosTheme.textPrimary)),
        content: Text(
          '确定要清除所有计算记录吗？',
          style: TextStyle(color: CosmosTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: CosmosTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              engine.clearHistory();
              Navigator.pop(context);
            },
            child: Text('清除', style: TextStyle(color: CosmosTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatefulWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;
  const _HistoryRow({required this.entry, required this.onTap});

  @override
  State<_HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<_HistoryRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _hovered ? CosmosTheme.cardBg : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.entry.expression,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.right,
                style: CosmosTheme.monoStyle(
                  size: 11,
                  color: CosmosTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.entry.result,
                textAlign: TextAlign.right,
                style: CosmosTheme.monoStyle(
                  size: 16,
                  weight: FontWeight.bold,
                  color: CosmosTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, color: CosmosTheme.textSecondary, size: 32),
          const SizedBox(height: 8),
          Text(
            '尚无计算记录',
            style: CosmosTheme.monoStyle(
              size: 13,
              color: CosmosTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, color: color, size: 18),
  );
}
