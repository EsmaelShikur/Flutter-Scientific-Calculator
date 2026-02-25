// lib/features/calculator/domain/entities/history_entry.dart
import 'package:hive/hive.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 0)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String expression;

  @HiveField(1)
  final String result;

  @HiveField(2)
  final DateTime timestamp;

  HistoryEntry({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}
