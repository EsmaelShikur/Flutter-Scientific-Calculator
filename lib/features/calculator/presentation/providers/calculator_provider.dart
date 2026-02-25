// lib/features/calculator/presentation/providers/calculator_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/calculator_state.dart';
import '../../domain/entities/history_entry.dart';
import '../../data/repositories/history_repository.dart';
import '../../../../core/utils/math_engine.dart';

// ─── Providers ───────────────────────────────────────────────
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return CalculatorNotifier(repo);
});

final historyProvider = StateProvider<List<HistoryEntry>>((ref) => []);

final themeModeProvider = StateProvider<bool>((ref) => true); // true = dark

// ─── CalculatorNotifier ───────────────────────────────────────
class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final HistoryRepository _historyRepo;
  late MathEngine _engine;
  String _rawExpression = ''; // The raw expression being typed
  bool _justEvaluated = false; // After = was pressed

  CalculatorNotifier(this._historyRepo) : super(const CalculatorState()) {
    _engine = MathEngine(isRadians: true);
    _initHistory();
  }

  Future<void> _initHistory() async {
    await _historyRepo.init();
  }

  // ─────────── Input Handlers ───────────────────────────────

  void inputDigit(String digit) {
    if (_justEvaluated) {
      // Start fresh number entry after evaluation
      _rawExpression = digit;
      _justEvaluated = false;
    } else {
      _rawExpression += digit;
    }
    _updateDisplay();
  }

  void inputDecimal() {
    if (_justEvaluated) {
      _rawExpression = '0.';
      _justEvaluated = false;
    } else {
      // Check if current segment already has a decimal
      final lastNum = RegExp(r'[\d.]+$').stringMatch(_rawExpression);
      if (lastNum != null && lastNum.contains('.')) return;
      _rawExpression += _rawExpression.isEmpty ? '0.' : '.';
    }
    _updateDisplay();
  }

  void inputOperator(String op) {
    _justEvaluated = false;
    // Replace trailing operator if present
    _rawExpression = _rawExpression.replaceFirst(RegExp(r'[+\-×÷%]$'), '');
    _rawExpression += op;
    _updateDisplay();
  }

  void inputFunction(String func) {
    if (_justEvaluated && state.lastResult != null) {
      final r = MathEngine.formatResult(state.lastResult!);
      _rawExpression = '$func($r)';
    } else {
      _rawExpression += '$func(';
    }
    _justEvaluated = false;
    _updateDisplay();
  }

  void inputConstant(String constant, double value) {
    if (_justEvaluated) {
      _rawExpression = constant;
      _justEvaluated = false;
    } else {
      _rawExpression += constant;
    }
    _updateDisplay();
  }

  void inputOpenParen() {
    _rawExpression += '(';
    _justEvaluated = false;
    _updateDisplay();
  }

  void inputCloseParen() {
    _rawExpression += ')';
    _updateDisplay();
  }

  void backspace() {
    if (_justEvaluated) {
      clear();
      return;
    }
    if (_rawExpression.isNotEmpty) {
      // Remove last character (or last function name)
      final fnMatch = RegExp(r'[a-z]+\($').firstMatch(_rawExpression);
      if (fnMatch != null) {
        _rawExpression = _rawExpression.substring(0, fnMatch.start);
      } else {
        _rawExpression = _rawExpression.substring(0, _rawExpression.length - 1);
      }
    }
    _updateDisplay();
  }

  void clear() {
    _rawExpression = '';
    _justEvaluated = false;
    state = const CalculatorState();
  }

  void clearEntry() {
    if (_rawExpression.isNotEmpty) {
      // Remove last number or token
      _rawExpression = _rawExpression.replaceFirst(RegExp(r'[\d.]+$'), '');
      if (_rawExpression.isEmpty) {
        state = state.copyWith(display: '0', expression: '', livePreview: '');
      } else {
        _updateDisplay();
      }
    }
  }

  void toggleSign() {
    // Toggle sign of last number in expression
    final match = RegExp(r'(-?\d+\.?\d*)$').firstMatch(_rawExpression);
    if (match != null) {
      final num = match.group(0)!;
      final toggled = num.startsWith('-') ? num.substring(1) : '-$num';
      _rawExpression = _rawExpression.substring(0, match.start) + toggled;
      _updateDisplay();
    }
  }

  void percent() {
    _rawExpression += '%';
    _updateDisplay();
  }

  void toggleAngleMode() {
    final newMode = state.angleMode == AngleMode.radians
        ? AngleMode.degrees
        : AngleMode.radians;
    _engine = MathEngine(isRadians: newMode == AngleMode.radians);
    state = state.copyWith(angleMode: newMode);
    // Re-evaluate live preview with new mode
    _updateDisplay();
  }

  void toggleSecondMode() {
    state = state.copyWith(isSecondMode: !state.isSecondMode);
  }

  void squareRoot() {
    _rawExpression += 'sqrt(';
    _justEvaluated = false;
    _updateDisplay();
  }

  void square() {
    _rawExpression += '²';
    _updateDisplay();
  }

  void factorial() {
    _rawExpression += '!';
    _updateDisplay();
  }

  void inputAbsValue() {
    _rawExpression += 'abs(';
    _updateDisplay();
  }

  void inputPi() => inputConstant('π', 3.141592653589793);
  void inputE() => inputConstant('e', 2.718281828459045);

  // Memory operations
  void memoryClear() => state = state.copyWith(memory: 0, hasMemory: false);
  void memoryRecall() {
    if (state.hasMemory) {
      final val = MathEngine.formatResult(state.memory);
      if (_justEvaluated) {
        _rawExpression = val;
        _justEvaluated = false;
      } else {
        _rawExpression += val;
      }
      _updateDisplay();
    }
  }

  void memoryAdd() {
    final result = _engine.evaluate(_preprocessExpression(_rawExpression));
    if (result != null) {
      state = state.copyWith(
        memory: state.memory + result,
        hasMemory: true,
      );
    }
  }

  void memorySub() {
    final result = _engine.evaluate(_preprocessExpression(_rawExpression));
    if (result != null) {
      state = state.copyWith(
        memory: state.memory - result,
        hasMemory: true,
      );
    }
  }

  void memoryStore() {
    final result = _engine.evaluate(_preprocessExpression(_rawExpression));
    if (result != null) {
      state = state.copyWith(memory: result, hasMemory: true);
    }
  }

  // Power
  void inputPower() {
    _rawExpression += '^';
    _updateDisplay();
  }

  void inputYthRoot() {
    _rawExpression += '^(1/';
    _updateDisplay();
  }

  // Evaluate
  void evaluate() {
    if (_rawExpression.isEmpty) return;

    final exprForEngine = _preprocessExpression(_rawExpression);
    final result = _engine.evaluate(exprForEngine);

    if (result == null) {
      state = state.copyWith(
        display: 'Error',
        expression: '${_buildDisplayExpression(_rawExpression)} =',
        error: CalculatorError.invalidExpression,
        livePreview: '',
      );
      return;
    }

    if (result.isNaN) {
      state = state.copyWith(
          display: 'Not a number', error: CalculatorError.invalidExpression);
      return;
    }

    if (result.isInfinite) {
      state = state.copyWith(
        display: result > 0 ? '∞' : '-∞',
        error: CalculatorError.divisionByZero,
      );
      return;
    }

    final formatted = MathEngine.formatResult(result);
    final displayExpr = _buildDisplayExpression(_rawExpression);

    // Save to history
    _historyRepo.addEntry(HistoryEntry(
      expression: displayExpr,
      result: formatted,
      timestamp: DateTime.now(),
    ));

    state = state.copyWith(
      display: formatted,
      expression: '$displayExpr =',
      livePreview: '',
      lastResult: result,
      error: CalculatorError.none,
    );
    _rawExpression = formatted;
    _justEvaluated = true;
  }

  // ─────────── Internal Helpers ──────────────────────────────

  void _updateDisplay() {
    if (_rawExpression.isEmpty) {
      state = state.copyWith(display: '0', expression: '', livePreview: '');
      return;
    }

    final display = _buildDisplayExpression(_rawExpression);

    // Try live preview evaluation
    String preview = '';
    try {
      final processed = _preprocessExpression(_rawExpression);
      final result = _engine.evaluate(processed);
      if (result != null && !result.isNaN && !result.isInfinite) {
        final formatted = MathEngine.formatResult(result);
        // Only show preview if different from what's displayed
        if (formatted != display) preview = formatted;
      }
    } catch (_) {}

    state = state.copyWith(
      display: display,
      expression: '',
      livePreview: preview,
      error: CalculatorError.none,
    );
  }

  /// Convert user-visible expression to engine-parseable string
  String _preprocessExpression(String expr) {
    return expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('²', '**2')
        .replaceAll('!', ')') // factorial placeholder
        .replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)\)'), (m) {
      // Detect factorial pattern like "5)"
      return 'fact(${m[1]})';
    }).replaceAll('!', ''); // cleanup
  }

  /// Build a pretty display string from raw expression
  String _buildDisplayExpression(String raw) {
    return raw
        .replaceAll('*', '×')
        .replaceAll('/', '÷')
        .replaceAll(RegExp(r'\*\*2'), '²')
        .replaceAll('^', 'ˆ');
  }

  List<HistoryEntry> getHistory() => _historyRepo.getHistory();

  Future<void> deleteHistoryEntry(int index) async {
    await _historyRepo.deleteEntry(index);
  }

  Future<void> clearHistory() async {
    await _historyRepo.clearAll();
  }

  Future<String> exportHistoryCsv() => _historyRepo.exportAsCsv();

  void useHistoryResult(String result) {
    _rawExpression = result;
    _justEvaluated = false;
    _updateDisplay();
  }
}
