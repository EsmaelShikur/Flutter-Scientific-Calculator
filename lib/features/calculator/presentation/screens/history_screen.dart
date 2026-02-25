// lib/features/calculator/presentation/screens/history_screen.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';
import '../../domain/entities/history_entry.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<HistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final notifier = ref.read(calculatorProvider.notifier);
    setState(() => _history = notifier.getHistory());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = ref.read(calculatorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          if (_history.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () => _exportCsv(context, notifier),
              tooltip: 'Export CSV',
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppColors.error),
              onPressed: () => _confirmClearAll(context, notifier),
              tooltip: 'Clear All',
            ),
          ],
        ],
      ),
      body: _history.isEmpty
          ? _buildEmpty(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (ctx, i) =>
                  _buildHistoryItem(ctx, i, isDark, notifier),
            ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 72,
            color:
                isDark ? AppColors.textSecondary : AppColors.textDarkSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No calculations yet',
            style: TextStyle(
              fontSize: 18,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textDarkSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your calculation history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: (isDark
                      ? AppColors.textSecondary
                      : AppColors.textDarkSecondary)
                  .withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    int index,
    bool isDark,
    CalculatorNotifier notifier,
  ) {
    final entry = _history[index];
    final bgColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final dateStr = _formatDate(entry.timestamp);

    return Dismissible(
      key: Key('${entry.expression}_${entry.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        await notifier.deleteHistoryEntry(index);
        setState(() => _history.removeAt(index));
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry deleted')),
          );
        }
      },
      child: GestureDetector(
        onTap: () => _useResult(context, entry.result, notifier),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textDarkSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: entry.result));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Result copied')),
                          );
                        },
                        child: const Icon(Icons.copy_rounded,
                            size: 16, color: AppColors.accent),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.expression,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textDarkSecondary,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 4),
              Text(
                entry.result,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white : AppColors.textDark,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  void _useResult(
      BuildContext context, String result, CalculatorNotifier notifier) {
    notifier.useHistoryResult(result);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Using result: $result')),
    );
  }

  Future<void> _exportCsv(
      BuildContext context, CalculatorNotifier notifier) async {
    try {
      final csv = await notifier.exportHistoryCsv();
      // In a real app, use path_provider + share_plus to save/share
      await Clipboard.setData(ClipboardData(text: csv));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History CSV copied to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmClearAll(
      BuildContext context, CalculatorNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content:
            const Text('Are you sure you want to delete all history entries?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await notifier.clearHistory();
      setState(() => _history = []);
    }
  }
}
