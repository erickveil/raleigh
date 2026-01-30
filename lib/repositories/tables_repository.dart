import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/table_data.dart';
import '../models/table_definition.dart';

class TablesRepository {
  static const String _tableName = 'tables';
  static late Box<TableData> _tablesBox;

  static Future<void> initialize() async {
    _tablesBox = await Hive.openBox<TableData>(_tableName);
  }

  Future<Map<String, TableData>> getAllTables() async {
    try {
      final tables = <String, TableData>{};
      for (var key in _tablesBox.keys) {
        final table = _tablesBox.get(key);
        if (table != null) {
          tables[key.toString()] = table;
        }
      }
      return tables;
    } catch (e) {
      debugPrint('Error loading all tables: $e');
      return {};
    }
  }

  Future<TableData?> getTable(String name) async {
    try {
      return _tablesBox.get(name);
    } catch (e) {
      debugPrint('Error getting table $name: $e');
      return null;
    }
  }

  Future<void> createTable(
    String name,
    TableDefinition definition,
  ) async {
    try {
      final tableData = TableData(
        definition: definition,
        records: [],
      );
      await _tablesBox.put(name, tableData);
    } catch (e) {
      debugPrint('Error creating table $name: $e');
      rethrow;
    }
  }

  Future<void> deleteTable(String name) async {
    try {
      await _tablesBox.delete(name);
    } catch (e) {
      debugPrint('Error deleting table $name: $e');
      rethrow;
    }
  }

  Future<void> saveTable(String name, TableData tableData) async {
    try {
      await _tablesBox.put(name, tableData);
    } catch (e) {
      debugPrint('Error saving table $name: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _tablesBox.close();
  }
}
