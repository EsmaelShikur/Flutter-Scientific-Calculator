// lib/features/calculator/data/repositories/history_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/history_entry.dart';

abstract class IHistoryRepository {
  Future<void> addEntry(HistoryEntry entry);
  List<HistoryEntry> getHistory();
  Future<void> deleteEntry(int index);
  Future<void> clearAll();
  Future<String> exportAsCsv();
}

class HistoryRepository implements IHistoryRepository {
  static const String _boxName = 'calculator_history';
  late Box<HistoryEntry> _box;

  Future<void> init() async {
    _box = await Hive.openBox<HistoryEntry>(_boxName);
  }

  @override
  Future<void> addEntry(HistoryEntry entry) async {
    await _box.add(entry);
    // Keep max 200 entries
    if (_box.length > 200) {
      await _box.deleteAt(0);
    }
  }

  @override
  List<HistoryEntry> getHistory() {
    return _box.values.toList().reversed.toList();
  }

  @override
  Future<void> deleteEntry(int index) async {
    final entries = _box.values.toList().reversed.toList();
    if (index < entries.length) {
      await entries[index].delete();
    }
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }

  @override
  Future<String> exportAsCsv() async {
    final buffer = StringBuffer();
    buffer.writeln('Expression,Result,Timestamp');
    for (final entry in _box.values) {
      buffer.writeln(
        '"${entry.expression}","${entry.result}","${entry.timestamp.toIso8601String()}"',
      );
    }
    return buffer.toString();
  }
}
