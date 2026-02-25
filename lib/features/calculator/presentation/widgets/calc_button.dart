// lib/features/calculator/presentation/widgets/calc_button.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/calculator_constants.dart';

class CalcButton extends StatefulWidget {
  final String label;
  final String? subLabel;
  final ButtonType type;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isActive;
  final bool isWide;
  final double fontSize;

  const CalcButton({
    super.key,
    required this.label,
    this.subLabel,
    required this.type,
    required this.onTap,
    this.onLongPress,
    this.isActive = false,
    this.isWide = false,
    this.fontSize = 20,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() => _controller.reverse();

  Color _getButtonColor(bool isDark) {
    if (widget.isActive) return AppColors.accent.withOpacity(0.2);
    switch (widget.type) {
      case ButtonType.number:
        return isDark ? AppColors.btnNumber : AppColors.btnNumberLight;
      case ButtonType.operator:
        return isDark ? AppColors.btnOperator : AppColors.btnOperatorLight;
      case ButtonType.scientific:
      case ButtonType.memory:
      case ButtonType.toggle:
        return isDark ? AppColors.btnScientific : AppColors.btnScientificLight;
      case ButtonType.equals:
        return AppColors.accent;
      case ButtonType.clear:
        return isDark ? AppColors.btnClear : AppColors.btnClearLight;
      case ButtonType.clearEntry:
        return isDark ? AppColors.btnNumber : AppColors.btnNumberLight;
      case ButtonType.special:
        return isDark ? AppColors.btnOperator : AppColors.btnOperatorLight;
    }
  }

  Color _getTextColor(bool isDark) {
    switch (widget.type) {
      case ButtonType.equals:
        return Colors.white;
      case ButtonType.clear:
        return isDark ? AppColors.btnClearText : AppColors.btnClearTextLight;
      case ButtonType.operator:
        return AppColors.accent;
      case ButtonType.scientific:
      case ButtonType.memory:
        return isDark ? AppColors.textSecondary : AppColors.textDarkSecondary;
      case ButtonType.toggle:
        return widget.isActive
            ? AppColors.accent
            : (isDark ? AppColors.textSecondary : AppColors.textDarkSecondary);
      default:
        return isDark ? Colors.white : AppColors.textDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _getButtonColor(isDark);
    final textColor = _getTextColor(isDark);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.06),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.type == ButtonType.equals
                        ? AppColors.accent
                        : Colors.black)
                    .withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Center(
            child: widget.subLabel != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.subLabel!,
                        style: TextStyle(
                          fontSize: 9,
                          color: textColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: widget.fontSize - 4,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: textColor,
                      fontWeight: widget.type == ButtonType.number
                          ? FontWeight.w400
                          : FontWeight.w600,
                      letterSpacing: widget.label.length > 2 ? -0.5 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}
