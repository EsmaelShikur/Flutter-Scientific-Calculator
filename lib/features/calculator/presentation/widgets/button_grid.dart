// lib/features/calculator/presentation/widgets/button_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';
import 'calc_button.dart';
import '../../../../core/constants/calculator_constants.dart';

class ButtonGrid extends ConsumerWidget {
  final bool isLandscape;
  const ButtonGrid({super.key, this.isLandscape = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcState = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final isSecond = calcState.isSecondMode;

    if (isLandscape) {
      return _LandscapeButtonGrid(notifier: notifier, isSecond: isSecond);
    }
    return _PortraitButtonGrid(notifier: notifier, isSecond: isSecond);
  }
}

// ─────────────────────────────────────────
// PORTRAIT LAYOUT
// ─────────────────────────────────────────
class _PortraitButtonGrid extends StatelessWidget {
  final CalculatorNotifier notifier;
  final bool isSecond;

  const _PortraitButtonGrid({required this.notifier, required this.isSecond});

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate spacing to prevent overflow on small screens
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenHeight < 700
        ? 6.0
        : screenHeight < 800
            ? 8.0
            : 10.0;
    final bottomPad = screenHeight < 700 ? 8.0 : 12.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottomPad),
      child: Column(
        children: [
          // ── Row 1: Scientific (2nd, deg/rad, trig)
          Expanded(
              child: _buildRow([
            _btn('2nd', ButtonType.toggle,
                isActive: isSecond, onTap: notifier.toggleSecondMode),
            _btn(notifier.isRadians ? 'DEG' : 'RAD', ButtonType.toggle,
                onTap: notifier.toggleAngleMode),
            _btn(isSecond ? 'sin⁻¹' : 'sin', ButtonType.scientific,
                onTap: () => notifier.inputFunction(isSecond ? 'asin' : 'sin')),
            _btn(isSecond ? 'cos⁻¹' : 'cos', ButtonType.scientific,
                onTap: () => notifier.inputFunction(isSecond ? 'acos' : 'cos')),
            _btn(isSecond ? 'tan⁻¹' : 'tan', ButtonType.scientific,
                onTap: () => notifier.inputFunction(isSecond ? 'atan' : 'tan')),
          ], spacing)),

          SizedBox(height: spacing),

          // ── Row 2: More scientific
          Expanded(
              child: _buildRow([
            _btn(isSecond ? 'log₂' : 'log', ButtonType.scientific,
                onTap: () => notifier.inputFunction(isSecond ? 'log2' : 'log')),
            _btn(isSecond ? 'eˣ' : 'ln', ButtonType.scientific,
                onTap: () => notifier.inputFunction(isSecond ? 'exp' : 'ln')),
            _btn('√', ButtonType.scientific, onTap: notifier.squareRoot),
            _btn('x²', ButtonType.scientific, onTap: notifier.square),
            _btn('xʸ', ButtonType.scientific, onTap: notifier.inputPower),
          ], spacing)),

          SizedBox(height: spacing),

          // ── Row 3: π, e, (, ), MC
          Expanded(
              child: _buildRow([
            _btn('π', ButtonType.scientific, onTap: notifier.inputPi),
            _btn('e', ButtonType.scientific, onTap: notifier.inputE),
            _btn('(', ButtonType.scientific, onTap: notifier.inputOpenParen),
            _btn(')', ButtonType.scientific, onTap: notifier.inputCloseParen),
            _btn('MC', ButtonType.memory,
                subLabel: 'clear', onTap: notifier.memoryClear),
          ], spacing)),

          SizedBox(height: spacing),

          // ── Row 4: MR, M+, M-, MS, |x|
          Expanded(
              child: _buildRow([
            _btn('MR', ButtonType.memory,
                subLabel: 'recall', onTap: notifier.memoryRecall),
            _btn('M+', ButtonType.memory, onTap: notifier.memoryAdd),
            _btn('M−', ButtonType.memory, onTap: notifier.memorySub),
            _btn('MS', ButtonType.memory,
                subLabel: 'store', onTap: notifier.memoryStore),
            _btn('|x|', ButtonType.scientific, onTap: notifier.inputAbsValue),
          ], spacing)),

          SizedBox(height: spacing),

          // ── Row 5: AC, CE, %, ÷
          Expanded(
              child: _buildRow([
            _btn('AC', ButtonType.clear, onTap: notifier.clear),
            _btn('CE', ButtonType.clearEntry, onTap: notifier.clearEntry),
            _btn('⌫', ButtonType.clearEntry,
                onTap: notifier.backspace, onLongPress: notifier.clear),
            _btn('÷', ButtonType.operator,
                onTap: () => notifier.inputOperator('÷')),
          ], spacing, last4: true)),

          SizedBox(height: spacing),

          // ── Row 6: 7 8 9 ×
          Expanded(
              child: _buildRow([
            _btn('7', ButtonType.number, onTap: () => notifier.inputDigit('7')),
            _btn('8', ButtonType.number, onTap: () => notifier.inputDigit('8')),
            _btn('9', ButtonType.number, onTap: () => notifier.inputDigit('9')),
            _btn('×', ButtonType.operator,
                onTap: () => notifier.inputOperator('×')),
          ], spacing, last4: true)),

          SizedBox(height: spacing),

          // ── Row 7: 4 5 6 −
          Expanded(
              child: _buildRow([
            _btn('4', ButtonType.number, onTap: () => notifier.inputDigit('4')),
            _btn('5', ButtonType.number, onTap: () => notifier.inputDigit('5')),
            _btn('6', ButtonType.number, onTap: () => notifier.inputDigit('6')),
            _btn('−', ButtonType.operator,
                onTap: () => notifier.inputOperator('−')),
          ], spacing, last4: true)),

          SizedBox(height: spacing),

          // ── Row 8: 1 2 3 +
          Expanded(
              child: _buildRow([
            _btn('1', ButtonType.number, onTap: () => notifier.inputDigit('1')),
            _btn('2', ButtonType.number, onTap: () => notifier.inputDigit('2')),
            _btn('3', ButtonType.number, onTap: () => notifier.inputDigit('3')),
            _btn('+', ButtonType.operator,
                onTap: () => notifier.inputOperator('+')),
          ], spacing, last4: true)),

          SizedBox(height: spacing),

          // ── Row 9: +/- 0 . =
          Expanded(
              child: _buildRow([
            _btn('+/-', ButtonType.special, onTap: notifier.toggleSign),
            _btn('0', ButtonType.number, onTap: () => notifier.inputDigit('0')),
            _btn('.', ButtonType.number, onTap: notifier.inputDecimal),
            _btn('=', ButtonType.equals, onTap: notifier.evaluate),
          ], spacing, last4: true)),
        ],
      ),
    );
  }

  Widget _buildRow(List<_BtnDef> buttons, double spacing,
      {bool last4 = false}) {
    return Row(
      children: buttons.asMap().entries.map((entry) {
        final def = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key == 0 ? 0 : spacing / 2,
              right: entry.key == buttons.length - 1 ? 0 : spacing / 2,
            ),
            child: CalcButton(
              label: def.label,
              subLabel: def.subLabel,
              type: def.type,
              onTap: def.onTap,
              onLongPress: def.onLongPress,
              isActive: def.isActive,
              fontSize: last4 ? 24 : 17,
            ),
          ),
        );
      }).toList(),
    );
  }

  _BtnDef _btn(
    String label,
    ButtonType type, {
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isActive = false,
    String? subLabel,
  }) =>
      _BtnDef(
          label: label,
          type: type,
          onTap: onTap,
          onLongPress: onLongPress,
          isActive: isActive,
          subLabel: subLabel);
}

// ─────────────────────────────────────────
// LANDSCAPE LAYOUT
// ─────────────────────────────────────────
class _LandscapeButtonGrid extends StatelessWidget {
  final CalculatorNotifier notifier;
  final bool isSecond;

  const _LandscapeButtonGrid({required this.notifier, required this.isSecond});

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          // Scientific panel (left half)
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(
                    child: _buildSciRow([
                  _btn('2nd', ButtonType.toggle,
                      isActive: isSecond, onTap: notifier.toggleSecondMode),
                  _btn(notifier.isRadians ? 'DEG' : 'RAD', ButtonType.toggle,
                      onTap: notifier.toggleAngleMode),
                  _btn(isSecond ? 'sin⁻¹' : 'sin', ButtonType.scientific,
                      onTap: () =>
                          notifier.inputFunction(isSecond ? 'asin' : 'sin')),
                  _btn(isSecond ? 'cos⁻¹' : 'cos', ButtonType.scientific,
                      onTap: () =>
                          notifier.inputFunction(isSecond ? 'acos' : 'cos')),
                  _btn(isSecond ? 'tan⁻¹' : 'tan', ButtonType.scientific,
                      onTap: () =>
                          notifier.inputFunction(isSecond ? 'atan' : 'tan')),
                ], spacing)),
                const SizedBox(height: spacing),
                Expanded(
                    child: _buildSciRow([
                  _btn('log', ButtonType.scientific,
                      onTap: () => notifier.inputFunction('log')),
                  _btn('ln', ButtonType.scientific,
                      onTap: () => notifier.inputFunction('ln')),
                  _btn('√', ButtonType.scientific, onTap: notifier.squareRoot),
                  _btn('x²', ButtonType.scientific, onTap: notifier.square),
                  _btn('xʸ', ButtonType.scientific, onTap: notifier.inputPower),
                ], spacing)),
                const SizedBox(height: spacing),
                Expanded(
                    child: _buildSciRow([
                  _btn('π', ButtonType.scientific, onTap: notifier.inputPi),
                  _btn('e', ButtonType.scientific, onTap: notifier.inputE),
                  _btn('(', ButtonType.scientific,
                      onTap: notifier.inputOpenParen),
                  _btn(')', ButtonType.scientific,
                      onTap: notifier.inputCloseParen),
                  _btn('|x|', ButtonType.scientific,
                      onTap: notifier.inputAbsValue),
                ], spacing)),
                const SizedBox(height: spacing),
                Expanded(
                    child: _buildSciRow([
                  _btn('MR', ButtonType.memory, onTap: notifier.memoryRecall),
                  _btn('M+', ButtonType.memory, onTap: notifier.memoryAdd),
                  _btn('M−', ButtonType.memory, onTap: notifier.memorySub),
                  _btn('MC', ButtonType.memory, onTap: notifier.memoryClear),
                  _btn('n!', ButtonType.scientific, onTap: notifier.factorial),
                ], spacing)),
                const SizedBox(height: spacing),
                Expanded(
                    child: _buildSciRow([
                  _btn('sinh', ButtonType.scientific,
                      onTap: () => notifier.inputFunction('sinh')),
                  _btn('cosh', ButtonType.scientific,
                      onTap: () => notifier.inputFunction('cosh')),
                  _btn('tanh', ButtonType.scientific,
                      onTap: () => notifier.inputFunction('tanh')),
                  _btn('exp', ButtonType.scientific,
                      onTap: () => notifier.inputFunction('exp')),
                  _btn('%', ButtonType.operator, onTap: notifier.percent),
                ], spacing)),
              ],
            ),
          ),

          const SizedBox(width: spacing * 1.5),

          // Basic panel (right half)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                    child: _buildSciRow([
                  _btn('AC', ButtonType.clear, onTap: notifier.clear),
                  _btn('CE', ButtonType.clearEntry, onTap: notifier.clearEntry),
                  _btn('⌫', ButtonType.clearEntry, onTap: notifier.backspace),
                  _btn('÷', ButtonType.operator,
                      onTap: () => notifier.inputOperator('÷')),
                ], spacing)),
                const SizedBox(height: spacing),
                Expanded(
                    child: _buildSciRow([
                  _btn('7', ButtonType.number,
                      onTap: () => notifier.inputDigit('7')),
                  _btn('8', ButtonType.number,
                      onTap: () => notifier.inputDigit('8')),
                  _btn('9', ButtonType.number,
                      onTap: () => notifier.inputDigit('9')),
                  _btn('×', ButtonType.operator,
                      onTap: () => notifier.inputOperator('×')),
                ], spacing)),
                const SizedBox(height: spacing),
                Expanded(
                    child: _buildSciRow([
                  _btn('4', ButtonType.number,
                      onTap: () => notifier.inputDigit('4')),
                  _btn('5', ButtonType.number,
                      onTap: () => notifier.inputDigit('5')),
                  _btn('6', ButtonType.number,
                      onTap: () => notifier.inputDigit('6')),
                  _btn('−', ButtonType.operator,
                      onTap: () => notifier.inputOperator('−')),
                ], spacing)),
                const SizedBox(height: spacing),
                Expanded(
                    child: _buildSciRow([
                  _btn('1', ButtonType.number,
                      onTap: () => notifier.inputDigit('1')),
                  _btn('2', ButtonType.number,
                      onTap: () => notifier.inputDigit('2')),
                  _btn('3', ButtonType.number,
                      onTap: () => notifier.inputDigit('3')),
                  _btn('+', ButtonType.operator,
                      onTap: () => notifier.inputOperator('+')),
                ], spacing)),
                const SizedBox(height: spacing),
                Expanded(
                    child: _buildSciRow([
                  _btn('+/-', ButtonType.special, onTap: notifier.toggleSign),
                  _btn('0', ButtonType.number,
                      onTap: () => notifier.inputDigit('0')),
                  _btn('.', ButtonType.number, onTap: notifier.inputDecimal),
                  _btn('=', ButtonType.equals, onTap: notifier.evaluate),
                ], spacing)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSciRow(List<_BtnDef> buttons, double spacing) {
    return Row(
      children: buttons.asMap().entries.map((e) {
        final def = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: e.key == 0 ? 0 : spacing / 2,
              right: e.key == buttons.length - 1 ? 0 : spacing / 2,
            ),
            child: CalcButton(
              label: def.label,
              subLabel: def.subLabel,
              type: def.type,
              onTap: def.onTap,
              onLongPress: def.onLongPress,
              isActive: def.isActive,
              fontSize: 15,
            ),
          ),
        );
      }).toList(),
    );
  }

  _BtnDef _btn(
    String label,
    ButtonType type, {
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isActive = false,
    String? subLabel,
  }) =>
      _BtnDef(
          label: label,
          type: type,
          onTap: onTap,
          onLongPress: onLongPress,
          isActive: isActive,
          subLabel: subLabel);
}

// Helper class for button definitions
class _BtnDef {
  final String label;
  final String? subLabel;
  final ButtonType type;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isActive;

  _BtnDef({
    required this.label,
    this.subLabel,
    required this.type,
    required this.onTap,
    this.onLongPress,
    this.isActive = false,
  });
}

// Extension to access isRadians
extension on CalculatorNotifier {
  bool get isRadians {
    // Access through state - we need to expose this
    return true; // Will be updated via state
  }
}
