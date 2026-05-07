import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AngleMode { degrees, radians }

class HistoryEntry {
  final String expression;
  final String result;
  HistoryEntry(this.expression, this.result);

  Map<String, String> toMap() => {'expr': expression, 'result': result};
  static HistoryEntry fromMap(Map<String, String> m) =>
      HistoryEntry(m['expr'] ?? '', m['result'] ?? '');
}

class CalculatorEngine extends ChangeNotifier {
  String display = '0';
  String expr = '';
  double? _pendingA;
  String? _pendingOp;
  bool _justEvaluated = false;
  bool _entering = false;
  bool error = false;
  bool pulseEq = false;
  AngleMode angle = AngleMode.degrees;
  List<HistoryEntry> history = [];

  static const int _maxHistory = 40;
  static const String _historyKey = 'cosmos_history';

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_historyKey) ?? [];
      history = raw.map((s) {
        final parts = s.split('||');
        if (parts.length == 2) return HistoryEntry(parts[0], parts[1]);
        return null;
      }).whereType<HistoryEntry>().toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = history.map((e) => '${e.expression}||${e.result}').toList();
      await prefs.setStringList(_historyKey, raw);
    } catch (_) {}
  }

  void digit(String d) {
    if (error) return;
    if (_justEvaluated && d != '.') {
      display = d;
      _justEvaluated = false;
      _entering = true;
      notifyListeners();
      return;
    }
    if (!_entering) {
      display = d == '.' ? '0.' : d;
      _entering = true;
    } else {
      if (d == '.' && display.contains('.')) return;
      if (display == '0' && d != '.') {
        display = d;
      } else {
        if (display.replaceAll('.', '').replaceAll('-', '').length >= 12) return;
        display += d;
      }
    }
    _justEvaluated = false;
    notifyListeners();
  }

  void operation(String op) {
    if (error) return;
    final val = double.tryParse(display) ?? 0;
    if (_pendingOp != null && _entering && !_justEvaluated) {
      final result = _compute(_pendingA!, _pendingOp!, val);
      if (result == null) { _triggerError(); return; }
      _pendingA = result;
      display = _formatNum(result);
    } else {
      _pendingA = val;
    }
    _pendingOp = op;
    expr = '${_formatNum(_pendingA!)} $op';
    _entering = false;
    _justEvaluated = false;
    notifyListeners();
  }

  void equals() {
    if (error) return;
    if (_pendingOp == null) { pulseEq = true; notifyListeners(); pulseEq = false; return; }
    final b = double.tryParse(display) ?? 0;
    final result = _compute(_pendingA!, _pendingOp!, b);
    if (result == null) { _triggerError(); return; }
    final exprStr = '${expr} ${_formatNum(b)} =';
    final resStr = _formatNum(result);
    _addHistory(exprStr, resStr);
    expr = exprStr;
    display = resStr;
    _pendingA = null;
    _pendingOp = null;
    _justEvaluated = true;
    _entering = false;
    pulseEq = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 150), () { pulseEq = false; notifyListeners(); });
  }

  double? _compute(double a, String op, double b) {
    switch (op) {
      case '+': return a + b;
      case '−': return a - b;
      case '×': return a * b;
      case '÷': return b == 0 ? null : a / b;
      case 'xʸ': return math.pow(a, b).toDouble();
      case 'ⁿ√x': return b == 0 ? null : math.pow(a, 1 / b).toDouble();
    }
    return null;
  }

  void percent() {
    if (error) return;
    final val = double.tryParse(display) ?? 0;
    final result = _pendingA != null ? (_pendingA! * val / 100) : val / 100;
    display = _formatNum(result);
    _entering = false;
    notifyListeners();
  }

  void toggleSign() {
    if (error) return;
    if (display == '0') return;
    if (display.startsWith('-')) {
      display = display.substring(1);
    } else {
      display = '-$display';
    }
    notifyListeners();
  }

  void clear() {
    display = '0';
    expr = '';
    _pendingA = null;
    _pendingOp = null;
    _justEvaluated = false;
    _entering = false;
    error = false;
    notifyListeners();
  }

  void clearEntry() {
    if (error) { clear(); return; }
    if (display.length > 1) {
      display = display.substring(0, display.length - 1);
      if (display == '-') display = '0';
    } else {
      display = '0';
      _entering = false;
    }
    notifyListeners();
  }

  void applyUnary(String fn) {
    if (error) return;
    final val = double.tryParse(display) ?? 0;
    double? result;
    switch (fn) {
      case 'sin':   result = math.sin(_toRad(val)); break;
      case 'cos':   result = math.cos(_toRad(val)); break;
      case 'tan':
        if ((val % 180).abs() == 90 && angle == AngleMode.degrees) { _triggerError(); return; }
        result = math.tan(_toRad(val));
        break;
      case 'sin⁻¹':
        if (val.abs() > 1) { _triggerError(); return; }
        result = _fromRad(math.asin(val));
        break;
      case 'cos⁻¹':
        if (val.abs() > 1) { _triggerError(); return; }
        result = _fromRad(math.acos(val));
        break;
      case 'tan⁻¹': result = _fromRad(math.atan(val)); break;
      case 'eˣ':   result = math.exp(val); break;
      case '10ˣ':  result = math.pow(10, val).toDouble(); break;
      case 'ln':
        if (val <= 0) { _triggerError(); return; }
        result = math.log(val);
        break;
      case 'log':
        if (val <= 0) { _triggerError(); return; }
        result = math.log(val) / math.ln10;
        break;
      case 'log₂':
        if (val <= 0) { _triggerError(); return; }
        result = math.log(val) / math.log2e;
        break;
      case 'x²':   result = val * val; break;
      case 'x³':   result = val * val * val; break;
      case '√x':
        if (val < 0) { _triggerError(); return; }
        result = math.sqrt(val);
        break;
      case '∛x':   result = val < 0 ? -math.pow(-val, 1/3.0).toDouble() : math.pow(val, 1/3.0).toDouble(); break;
    }
    if (result == null || result.isNaN || result.isInfinite) { _triggerError(); return; }
    final exprStr = '$fn(${_formatNum(val)}) =';
    final resStr = _formatNum(result);
    _addHistory(exprStr, resStr);
    expr = exprStr;
    display = resStr;
    _justEvaluated = true;
    _entering = false;
    notifyListeners();
  }

  void applyBinaryOp(String op) => operation(op);

  void inputConstant(String name) {
    if (error) return;
    final val = name == 'π' ? math.pi : math.e;
    display = _formatNum(val);
    _justEvaluated = true;
    _entering = false;
    notifyListeners();
  }

  void toggleAngle() {
    angle = angle == AngleMode.degrees ? AngleMode.radians : AngleMode.degrees;
    notifyListeners();
  }

  void recallHistory(HistoryEntry entry) {
    display = entry.result;
    expr = entry.expression;
    _justEvaluated = true;
    _entering = false;
    error = false;
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    _saveHistory();
    notifyListeners();
  }

  void _addHistory(String expression, String result) {
    history.insert(0, HistoryEntry(expression, result));
    if (history.length > _maxHistory) history.removeLast();
    _saveHistory();
  }

  void _triggerError() {
    error = true;
    display = 'Error';
    expr = '';
    _pendingA = null;
    _pendingOp = null;
    _entering = false;
    _justEvaluated = false;
    notifyListeners();
  }

  double _toRad(double v) =>
      angle == AngleMode.degrees ? v * math.pi / 180.0 : v;

  double _fromRad(double v) =>
      angle == AngleMode.degrees ? v * 180.0 / math.pi : v;

  String _formatNum(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';
    if (v.abs() >= 1e12 || (v != 0 && v.abs() < 1e-6)) {
      return v.toStringAsExponential(6).replaceAll(RegExp(r'0+e'), 'e').replaceAll('.e', 'e');
    }
    final s = v.toStringAsFixed(9);
    final trimmed = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return trimmed.isEmpty ? '0' : trimmed;
  }

  String get angleModeLabel => angle == AngleMode.degrees ? 'Deg' : 'Rad';
  bool get hasPending => _pendingOp != null;
}
