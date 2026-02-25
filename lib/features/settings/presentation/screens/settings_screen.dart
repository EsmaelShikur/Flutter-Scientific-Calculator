// lib/features/settings/presentation/screens/settings_screen.dart
// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../calculator/presentation/providers/calculator_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/calculator_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance', isDark),
          _buildCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                value: isDarkMode,
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).state = v,
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between dark and light theme'),
                activeColor: AppColors.accent,
                secondary: const Icon(Icons.dark_mode_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Scientific Constants', isDark),
          _buildCard(
            isDark: isDark,
            children: MathConstants.scientificConstants.entries.map((e) {
              final name = e.key;
              final data = e.value;
              return ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      data['symbol'] as String,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  data['description'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  _formatConstant(data['value'] as double),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textDarkSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('About', isDark),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentSecondary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calculate_rounded,
                      color: Colors.white, size: 22),
                ),
                title: const Text('SciCalc Pro',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Version 1.0.0'),
              ),
              const Divider(height: 1, indent: 16),
              const ListTile(
                dense: true,
                leading: Icon(Icons.code_rounded, size: 20),
                title:
                    Text('Built with Flutter', style: TextStyle(fontSize: 14)),
                subtitle: Text('Clean Architecture + Riverpod',
                    style: TextStyle(fontSize: 12)),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.functions_rounded, size: 20),
                title:
                    const Text('Math Engine', style: TextStyle(fontSize: 14)),
                subtitle: const Text(
                    'Custom Shunting-Yard expression evaluator',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Keyboard Shortcuts & Tips', isDark),
          _buildCard(
            isDark: isDark,
            children: [
              _buildTip('Hold ⌫', 'Clear all', isDark),
              _buildTip('Hold result', 'Copy to clipboard', isDark),
              _buildTip('Tap history item', 'Use result in calculator', isDark),
              _buildTip('2nd button', 'Toggle inverse trig functions', isDark),
              _buildTip('Live preview', 'See result as you type', isDark),
              _buildTip('Landscape mode', 'Reveals more functions', isDark),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? AppColors.textSecondary : AppColors.textDarkSecondary,
        ),
      ),
    );
  }

  Widget _buildCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTip(String shortcut, String desc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(desc, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatConstant(double v) {
    if (v.abs() >= 1e6 || (v.abs() < 0.001 && v != 0)) {
      return v.toStringAsExponential(3);
    }
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsPrecision(6);
  }
}
