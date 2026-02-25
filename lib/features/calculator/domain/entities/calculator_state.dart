// lib/features/calculator/domain/entities/calculator_state.dart

enum AngleMode { radians, degrees }

enum CalculatorError {
  none,
  divisionByZero,
  invalidExpression,
  overflow,
  domainError,
  factorialRange,
}

class CalculatorState {
  final String display;
  final String expression;
  final String livePreview;
  final AngleMode angleMode;
  final bool isSecondMode; // For 2nd function toggle (e.g., sin→asin)
  final bool showScientific;
  final CalculatorError error;
  final double? lastResult;
  final double memory;
  final bool hasMemory;

  const CalculatorState({
    this.display = '0',
    this.expression = '',
    this.livePreview = '',
    this.angleMode = AngleMode.radians,
    this.isSecondMode = false,
    this.showScientific = true,
    this.error = CalculatorError.none,
    this.lastResult,
    this.memory = 0,
    this.hasMemory = false,
  });

  bool get hasError => error != CalculatorError.none;

  String get errorMessage {
    switch (error) {
      case CalculatorError.divisionByZero:
        return 'Division by zero';
      case CalculatorError.invalidExpression:
        return 'Invalid expression';
      case CalculatorError.overflow:
        return 'Overflow';
      case CalculatorError.domainError:
        return 'Domain error';
      case CalculatorError.factorialRange:
        return 'Factorial too large';
      case CalculatorError.none:
        return '';
    }
  }

  CalculatorState copyWith({
    String? display,
    String? expression,
    String? livePreview,
    AngleMode? angleMode,
    bool? isSecondMode,
    bool? showScientific,
    CalculatorError? error,
    double? lastResult,
    double? memory,
    bool? hasMemory,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      expression: expression ?? this.expression,
      livePreview: livePreview ?? this.livePreview,
      angleMode: angleMode ?? this.angleMode,
      isSecondMode: isSecondMode ?? this.isSecondMode,
      showScientific: showScientific ?? this.showScientific,
      error: error ?? this.error,
      lastResult: lastResult ?? this.lastResult,
      memory: memory ?? this.memory,
      hasMemory: hasMemory ?? this.hasMemory,
    );
  }
}
