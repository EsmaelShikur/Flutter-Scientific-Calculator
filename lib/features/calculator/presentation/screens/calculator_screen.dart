// lib/features/calculator/presentation/screens/calculator_screen.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/display_widget.dart';
import '../widgets/button_grid.dart';
import '../providers/calculator_provider.dart';
import '../../domain/entities/calculator_state.dart';
import '../../../../core/theme/app_theme.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final isDark = ref.watch(themeModeProvider);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isTablet = size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: isLandscape
            ? _buildLandscape(context, isTablet)
            : _buildPortrait(context, isTablet),
      ),
    );
  }

  Widget _buildPortrait(BuildContext context, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        // Give display a fixed minimum, buttons get the rest
        // This prevents overflow by letting Flutter measure real available space
        final displayHeight = (totalHeight * 0.33).clamp(160.0, 280.0);

        return Column(
          children: [
            // Display — fixed calculated height
            SizedBox(
              height: displayHeight,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: const CalculatorDisplay(),
              ),
            ),

            // Divider
            Container(
              height: 1,
              color: Theme.of(context).dividerColor,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),

            // Buttons — take exactly the remaining space
            Expanded(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : double.infinity,
                ),
                child: const ButtonGrid(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLandscape(BuildContext context, bool isTablet) {
    return Row(
      children: [
        // Left: display
        Expanded(
          flex: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: const CalculatorDisplay(),
          ),
        ),

        // Right: buttons
        const Expanded(
          flex: 60,
          child: ButtonGrid(isLandscape: true),
        ),
      ],
    );
  }
}
