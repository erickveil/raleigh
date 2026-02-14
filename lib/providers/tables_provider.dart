import 'package:flutter/material.dart';
import '../models/table_data.dart';
import '../models/table_definition.dart';
import '../models/column.dart' as col;
import '../models/record.dart';
import '../repositories/tables_repository.dart';
import '../services/storage_service.dart';

class TablesProvider extends ChangeNotifier {
  final TablesRepository _repository = TablesRepository();
  final StorageService _storageService = StorageService();
  Map<String, TableData> _tables = {};

  Map<String, TableData> get tables => _tables;

  TablesProvider() {
    _loadTables();
  }

  Future<void> _loadTables() async {
    _tables = await _repository.getAllTables();
    notifyListeners();
  }

  Future<void> createTable(
    String name,
    List<col.ColumnDef> columns,
    String? description,
  ) async {
    final definition = TableDefinition(
      name: name,
      columns: columns,
      description: description,
    );
    await _repository.createTable(name, definition);
    _tables[name] = TableData(definition: definition, records: []);
    notifyListeners();
  }

  Future<void> deleteTable(String name) async {
    await _repository.deleteTable(name);
    _tables.remove(name);
    notifyListeners();
  }

  Future<void> updateTableDescription(
    String tableName,
    String? description,
  ) async {
    if (_tables.containsKey(tableName)) {
      final updatedDefinition = _tables[tableName]!.definition.copyWith(
        description: description,
      );
      _tables[tableName] = TableData(
        definition: updatedDefinition,
        records: _tables[tableName]!.records,
      );
      await _repository.saveTable(tableName, _tables[tableName]!);
      notifyListeners();
    }
  }

  Future<void> addColumn(
    String tableName,
    col.ColumnDef newColumn,
    dynamic defaultValue,
  ) async {
    if (_tables.containsKey(tableName)) {
      final tableData = _tables[tableName]!;
      final updatedColumns = [...tableData.definition.columns, newColumn];
      final updatedDefinition = tableData.definition.copyWith(
        columns: updatedColumns,
      );

      final updatedRecords = tableData.records.map((record) {
        final newData = Map<String, dynamic>.from(record.data);
        newData[newColumn.name] = defaultValue;
        return record.copyWith(data: newData);
      }).toList();

      _tables[tableName] = TableData(
        definition: updatedDefinition,
        records: updatedRecords,
      );
      await _repository.saveTable(tableName, _tables[tableName]!);
      notifyListeners();
    }
  }

  Future<void> updateColumnDescription(
    String tableName,
    String columnName,
    String? description,
  ) async {
    if (_tables.containsKey(tableName)) {
      final updatedColumns = _tables[tableName]!.definition.columns.map((col) {
        if (col.name == columnName) {
          return col.copyWith(description: description);
        }
        return col;
      }).toList();

      final updatedDefinition = _tables[tableName]!.definition.copyWith(
        columns: updatedColumns,
      );
      _tables[tableName] = TableData(
        definition: updatedDefinition,
        records: _tables[tableName]!.records,
      );
      await _repository.saveTable(tableName, _tables[tableName]!);
      notifyListeners();
    }
  }

  Future<void> addRecord(String tableName, Record record) async {
    if (_tables.containsKey(tableName)) {
      final lastId = _tables[tableName]!.records.isEmpty
          ? 0
          : _tables[tableName]!.records.fold<int>(
              0,
              (previousValue, record) =>
                  record.id != null && record.id! > previousValue
                  ? record.id!
                  : previousValue,
            );

      final newRecord = record.copyWith(id: lastId + 1);
      _tables[tableName]!.addRecord(newRecord);
      await _repository.saveTable(tableName, _tables[tableName]!);
      notifyListeners();
    }
  }

  Future<void> updateRecord(String tableName, int index, Record record) async {
    if (_tables.containsKey(tableName)) {
      final oldId = _tables[tableName]!.records[index].id;
      _tables[tableName]!.updateRecord(index, record.copyWith(id: oldId));
      await _repository.saveTable(tableName, _tables[tableName]!);
      notifyListeners();
    }
  }

  Future<void> deleteRecord(String tableName, int index) async {
    if (_tables.containsKey(tableName)) {
      _tables[tableName]!.deleteRecord(index);
      await _repository.saveTable(tableName, _tables[tableName]!);
      notifyListeners();
    }
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
