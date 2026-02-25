// lib/features/calculator/presentation/widgets/display_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';
import '../../../../core/theme/app_theme.dart';

class CalculatorDisplay extends ConsumerStatefulWidget {
  const CalculatorDisplay({super.key});

  @override
  ConsumerState<CalculatorDisplay> createState() => _CalculatorDisplayState();
}

class _CalculatorDisplayState extends ConsumerState<CalculatorDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  String _lastDisplay = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger pulse on result change
    if (calcState.display != _lastDisplay) {
      _lastDisplay = calcState.display;
      if (calcState.expression.endsWith('=')) {
        _pulseController.forward().then((_) => _pulseController.reverse());
      }
    }

    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subColor =
        isDark ? AppColors.textSecondary : AppColors.textDarkSecondary;

    // Adaptive font size based on display length
    double resultFontSize = 64;
    if (calcState.display.length > 10) resultFontSize = 52;
    if (calcState.display.length > 15) resultFontSize = 40;
    if (calcState.display.length > 20) resultFontSize = 32;

    return GestureDetector(
      onLongPress: () => _copyToClipboard(context, calcState.display),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Angle Mode + Memory Badge row
            Row(
              children: [
                _ModeBadge(
                  label: calcState.angleMode.name.toUpperCase().substring(0, 3),
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                if (calcState.hasMemory)
                  const _ModeBadge(
                    label: 'M',
                    color: AppColors.accentSecondary,
                  ),
                const Spacer(),
                // Copy hint
                Icon(Icons.copy_rounded, size: 14, color: subColor),
                const SizedBox(width: 4),
                Text('Hold to copy',
                    style: TextStyle(fontSize: 11, color: subColor)),
              ],
            ),
            const SizedBox(height: 16),

            // Expression line
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: calcState.expression.isNotEmpty
                  ? Align(
                      key: ValueKey(calcState.expression),
                      alignment: Alignment.centerRight,
                      child: Text(
                        calcState.expression,
                        style: TextStyle(
                          fontSize: 18,
                          color: subColor,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),

            const SizedBox(height: 4),

            // Main display
            ScaleTransition(
              scale: _pulseAnim,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  key: ValueKey(calcState.display),
                  calcState.hasError
                      ? calcState.errorMessage
                      : calcState.display,
                  style: TextStyle(
                    fontSize: resultFontSize,
                    fontWeight: FontWeight.w300,
                    color: calcState.hasError ? AppColors.error : textColor,
                    letterSpacing: -2,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Live preview
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: calcState.livePreview.isNotEmpty
                  ? Align(
                      key: ValueKey(calcState.livePreview),
                      alignment: Alignment.centerRight,
                      child: Text(
                        '= ${calcState.livePreview}',
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.accent.withOpacity(0.7),
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-preview')),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _ModeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
