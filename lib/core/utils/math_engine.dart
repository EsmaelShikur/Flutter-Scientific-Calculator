// lib/core/utils/math_engine.dart
import 'dart:math' as math;

/// Robust math expression evaluator with proper operator precedence,
/// parentheses support, scientific functions, and error handling.
class MathEngine {
  bool isRadians;

  MathEngine({this.isRadians = true});

  /// Evaluate a math expression string and return the result.
  /// Returns null on error.
  double? evaluate(String expression) {
    try {
      final cleaned = _preprocess(expression);
      if (cleaned.isEmpty) return null;
      final tokens = _tokenize(cleaned);
      final rpn = _toRPN(tokens);
      return _evaluateRPN(rpn);
    } catch (e) {
      return null;
    }
  }

  /// Preprocess: replace constants, clean up notation
  String _preprocess(String expr) {
    return expr
        .trim()
        .replaceAll('π', '(${math.pi})')
        .replaceAll('e', '(${math.e})')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('^', '**')
        .replaceAll('²', '**2')
        .replaceAll('√(', 'sqrt(')
        .replaceAll('√', 'sqrt(')
        // Implicit multiplication: 2(3) -> 2*(3), 2sin -> 2*sin
        .replaceAllMapped(RegExp(r'(\d)\('), (m) => '${m[1]}*(')
        .replaceAllMapped(RegExp(r'\)(\d)'), (m) => ')*${m[1]}')
        .replaceAllMapped(RegExp(r'\)\('), (m) => ')*(');
  }

  /// Tokenize the expression into numbers, operators, and function names
  List<_Token> _tokenize(String expr) {
    final tokens = <_Token>[];
    int i = 0;
    while (i < expr.length) {
      final ch = expr[i];

      // Skip whitespace
      if (ch == ' ') {
        i++;
        continue;
      }

      // Numbers (including scientific notation)
      if (ch.isNumber ||
          (ch == '.' && i + 1 < expr.length && expr[i + 1].isNumber)) {
        final start = i;
        while (i < expr.length && (expr[i].isNumber || expr[i] == '.')) {
          i++;
        }
        // Scientific notation e.g. 1.5e10
        if (i < expr.length &&
            expr[i].toLowerCase() == 'e' &&
            i + 1 < expr.length &&
            (expr[i + 1].isNumber ||
                expr[i + 1] == '-' ||
                expr[i + 1] == '+')) {
          i++; // skip 'e'
          if (expr[i] == '-' || expr[i] == '+') i++;
          while (i < expr.length && expr[i].isNumber) {
            i++;
          }
        }
        tokens.add(_Token.number(double.parse(expr.substring(start, i))));
        continue;
      }

      // Functions and identifiers
      if (ch.isAlpha) {
        final start = i;
        while (i < expr.length && (expr[i].isAlpha || expr[i].isNumber)) {
          i++;
        }
        tokens.add(_Token.function(expr.substring(start, i)));
        continue;
      }

      // Operators and brackets
      switch (ch) {
        case '+':
          // Unary + (ignore)
          if (tokens.isEmpty ||
              tokens.last.type == _TokenType.leftParen ||
              tokens.last.type == _TokenType.op) {
            i++;
            continue;
          }
          tokens.add(_Token.op('+'));
          break;
        case '-':
          // Unary minus
          if (tokens.isEmpty ||
              tokens.last.type == _TokenType.leftParen ||
              tokens.last.type == _TokenType.op) {
            tokens.add(_Token.function('neg'));
          } else {
            tokens.add(_Token.op('-'));
          }
          break;
        case '*':
          if (i + 1 < expr.length && expr[i + 1] == '*') {
            tokens.add(_Token.op('**'));
            i += 2;
            continue;
          }
          tokens.add(_Token.op('*'));
          break;
        case '/':
          tokens.add(_Token.op('/'));
          break;
        case '%':
          tokens.add(_Token.op('%'));
          break;
        case '(':
          tokens.add(_Token(type: _TokenType.leftParen));
          break;
        case ')':
          tokens.add(_Token(type: _TokenType.rightParen));
          break;
        case ',':
          tokens.add(_Token(type: _TokenType.comma));
          break;
      }
      i++;
    }
    return tokens;
  }

  /// Shunting-Yard algorithm to convert to Reverse Polish Notation
  List<_Token> _toRPN(List<_Token> tokens) {
    final output = <_Token>[];
    final opStack = <_Token>[];

    for (final token in tokens) {
      if (token.type == _TokenType.number) {
        output.add(token);
      } else if (token.type == _TokenType.function) {
        opStack.add(token);
      } else if (token.type == _TokenType.op) {
        while (opStack.isNotEmpty &&
            opStack.last.type == _TokenType.op &&
            _hasHigherPrecedence(opStack.last.value!, token.value!)) {
          output.add(opStack.removeLast());
        }
        opStack.add(token);
      } else if (token.type == _TokenType.leftParen) {
        opStack.add(token);
      } else if (token.type == _TokenType.rightParen) {
        while (
            opStack.isNotEmpty && opStack.last.type != _TokenType.leftParen) {
          output.add(opStack.removeLast());
        }
        if (opStack.isNotEmpty) opStack.removeLast(); // remove '('
        if (opStack.isNotEmpty && opStack.last.type == _TokenType.function) {
          output.add(opStack.removeLast());
        }
      } else if (token.type == _TokenType.comma) {
        while (
            opStack.isNotEmpty && opStack.last.type != _TokenType.leftParen) {
          output.add(opStack.removeLast());
        }
      }
    }

    while (opStack.isNotEmpty) {
      output.add(opStack.removeLast());
    }
    return output;
  }

  bool _hasHigherPrecedence(String op1, String op2) {
    final p1 = _precedence(op1);
    final p2 = _precedence(op2);
    if (p1 == p2) return _isLeftAssociative(op1);
    return p1 > p2;
  }

  int _precedence(String op) {
    switch (op) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
      case '%':
        return 2;
      case '**':
        return 3;
      default:
        return 0;
    }
  }

  bool _isLeftAssociative(String op) => op != '**';

  /// Evaluate RPN tokens
  double _evaluateRPN(List<_Token> rpn) {
    final stack = <double>[];

    for (final token in rpn) {
      if (token.type == _TokenType.number) {
        stack.add(token.numValue!);
      } else if (token.type == _TokenType.op) {
        if (stack.length < 2) throw Exception('Invalid expression');
        final b = stack.removeLast();
        final a = stack.removeLast();
        stack.add(_applyOp(token.value!, a, b));
      } else if (token.type == _TokenType.function) {
        stack.add(_applyFunc(token.value!, stack));
      }
    }

    if (stack.length != 1) throw Exception('Invalid expression');
    return stack.first;
  }

  double _applyOp(String op, double a, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) throw Exception('Division by zero');
        return a / b;
      case '%':
        return a % b;
      case '**':
        return math.pow(a, b).toDouble();
      default:
        throw Exception('Unknown operator: $op');
    }
  }

  double _applyFunc(String func, List<double> stack) {
    double toAngle(double v) => isRadians ? v : v * math.pi / 180;
    double fromAngle(double v) => isRadians ? v : v * 180 / math.pi;

    switch (func.toLowerCase()) {
      case 'neg':
        if (stack.isEmpty) throw Exception('Missing operand');
        return -stack.removeLast();

      case 'sin':
        return math.sin(toAngle(stack.removeLast()));
      case 'cos':
        return math.cos(toAngle(stack.removeLast()));
      case 'tan':
        final angle = toAngle(stack.removeLast());
        return math.tan(angle);

      case 'asin':
      case 'arcsin':
        return fromAngle(math.asin(stack.removeLast()));
      case 'acos':
      case 'arccos':
        return fromAngle(math.acos(stack.removeLast()));
      case 'atan':
      case 'arctan':
        return fromAngle(math.atan(stack.removeLast()));
      case 'atan2':
        if (stack.length < 2) throw Exception('atan2 requires 2 args');
        final y = stack.removeLast();
        final x = stack.removeLast();
        return fromAngle(math.atan2(x, y));

      case 'sinh':
        return (math.exp(stack.last) - math.exp(-stack.removeLast())) / 2;
      case 'cosh':
        return (math.exp(stack.last) + math.exp(-stack.removeLast())) / 2;
      case 'tanh':
        final v = stack.removeLast();
        return (math.exp(v) - math.exp(-v)) / (math.exp(v) + math.exp(-v));

      case 'log':
        return math.log(stack.removeLast()) / math.ln10;
      case 'log2':
        return math.log(stack.removeLast()) / math.ln2;
      case 'ln':
        return math.log(stack.removeLast());
      case 'exp':
        return math.exp(stack.removeLast());

      case 'sqrt':
        final v = stack.removeLast();
        if (v < 0) throw Exception('√ of negative');
        return math.sqrt(v);
      case 'cbrt':
        final v = stack.removeLast();
        return v < 0
            ? -math.pow(-v, 1 / 3).toDouble()
            : math.pow(v, 1 / 3).toDouble();

      case 'abs':
        return stack.removeLast().abs();
      case 'ceil':
        return stack.removeLast().ceilToDouble();
      case 'floor':
        return stack.removeLast().floorToDouble();
      case 'round':
        return stack.removeLast().roundToDouble();

      case 'fact':
      case 'factorial':
        final n = stack.removeLast().toInt();
        if (n < 0 || n > 170) throw Exception('Factorial out of range');
        return _factorial(n).toDouble();

      case 'sign':
        return stack.removeLast().sign;
      case 'max':
        if (stack.length < 2) throw Exception('max requires 2 args');
        final b = stack.removeLast();
        final a = stack.removeLast();
        return math.max(a, b);
      case 'min':
        if (stack.length < 2) throw Exception('min requires 2 args');
        final b = stack.removeLast();
        final a = stack.removeLast();
        return math.min(a, b);
      case 'pow':
        if (stack.length < 2) throw Exception('pow requires 2 args');
        final exp = stack.removeLast();
        final base = stack.removeLast();
        return math.pow(base, exp).toDouble();

      default:
        throw Exception('Unknown function: $func');
    }
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  /// Format a double result cleanly
  static String formatResult(double value) {
    if (value.isNaN) return 'Not a number';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    // Check if it's an integer
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    // Use exponential for very large or very small numbers
    if (value.abs() >= 1e12 || (value.abs() < 1e-6 && value != 0)) {
      return value
          .toStringAsExponential(6)
          .replaceAll(RegExp(r'\.?0+(e)'), r'$1');
    }

    // Normal decimal - limit to 10 significant figures
    String result = value.toStringAsPrecision(10);
    // Remove trailing zeros after decimal
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'\.?0+$'), '');
    }
    return result;
  }
}

extension _StringCharChecks on String {
  bool get isNumber => RegExp(r'[0-9]').hasMatch(this);
  bool get isAlpha => RegExp(r'[a-zA-Z_]').hasMatch(this);
}

enum _TokenType { number, op, function, leftParen, rightParen, comma }

class _Token {
  final _TokenType type;
  final String? value;
  final double? numValue;

  _Token({required this.type, this.value, this.numValue});
  factory _Token.number(double v) =>
      _Token(type: _TokenType.number, numValue: v);
  factory _Token.op(String v) => _Token(type: _TokenType.op, value: v);
  factory _Token.function(String v) =>
      _Token(type: _TokenType.function, value: v);
}
