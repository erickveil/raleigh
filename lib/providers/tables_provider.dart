import 'package:flutter/material.dart';
import '../models/table_data.dart';
import '../models/table_definition.dart';
import '../models/column.dart' as col;
import '../models/record.dart';
import '../services/storage_service.dart';

class TablesProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  Map<String, TableData> _tables = {};

  Map<String, TableData> get tables => _tables;

  TablesProvider() {
    _loadTables();
  }

  Future<void> _loadTables() async {
    _tables = await _storageService.loadAllTables();
    notifyListeners();
  }

  Future<void> createTable(String name, List<col.ColumnDef> columns) async {
    final definition = TableDefinition(
      name: name,
      columns: columns,
    );
    _tables[name] = TableData(
      definition: definition,
      records: [],
    );
    await _saveTables();
  }

  Future<void> deleteTable(String name) async {
    _tables.remove(name);
    await _saveTables();
  }

  Future<void> addRecord(String tableName, Record record) async {
    if (_tables.containsKey(tableName)) {
      final lastId = _tables[tableName]!.records.isEmpty
          ? 0
          : _tables[tableName]!.records.fold<int>(
              0, (previousValue, record) => record.id != null && record.id! > previousValue ? record.id! : previousValue);
      
      final newRecord = record.copyWith(id: lastId + 1);
      _tables[tableName]!.addRecord(newRecord);
      await _saveTables();
    }
  }

  Future<void> updateRecord(String tableName, int index, Record record) async {
    if (_tables.containsKey(tableName)) {
      final oldId = _tables[tableName]!.records[index].id;
      _tables[tableName]!.updateRecord(index, record.copyWith(id: oldId));
      await _saveTables();
    }
  }

  Future<void> deleteRecord(String tableName, int index) async {
    if (_tables.containsKey(tableName)) {
      _tables[tableName]!.deleteRecord(index);
      await _saveTables();
    }
  }

  Future<void> _saveTables() async {
    await _storageService.saveAllTables(_tables);
    notifyListeners();
  }

  Future<String> exportTableAsJson(String tableName) async {
    if (_tables.containsKey(tableName)) {
      return _storageService.exportToJson(_tables[tableName]!);
    }
    return '';
  }

  Future<String> exportTableAsCSV(String tableName) async {
    if (_tables.containsKey(tableName)) {
      return _storageService.exportToCsv(_tables[tableName]!);
    }
    return '';
  }
}
