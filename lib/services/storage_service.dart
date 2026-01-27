import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/table_data.dart';

class StorageService {
  static const String _appDirectory = 'raleigh';
  static const String _dataFileName = 'tables_data.json';

  Future<Directory> _getAppDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${documentsDirectory.path}/$_appDirectory');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  Future<File> _getDataFile() async {
    final appDir = await _getAppDirectory();
    return File('${appDir.path}/$_dataFileName');
  }

  Future<Map<String, TableData>> loadAllTables() async {
    try {
      final file = await _getDataFile();
      if (!await file.exists()) {
        return {};
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      
      final tables = <String, TableData>{};
      json.forEach((key, value) {
        tables[key] = TableData.fromJson(value as Map<String, dynamic>);
      });
      
      return tables;
    } catch (e) {
      debugPrint('Error loading tables: $e');
      return {};
    }
  }

  Future<void> saveAllTables(Map<String, TableData> tables) async {
    try {
      final file = await _getDataFile();
      final json = <String, dynamic>{};
      
      tables.forEach((key, tableData) {
        json[key] = tableData.toJson();
      });
      
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      debugPrint('Error saving tables: $e');
      rethrow;
    }
  }

  Future<String> exportToJson(TableData tableData) async {
    return jsonEncode(tableData.toJson());
  }

  Future<File?> exportToJsonFile(TableData tableData, String fileName) async {
    try {
      final appDir = await _getAppDirectory();
      final file = File('${appDir.path}/$fileName');
      await file.writeAsString(jsonEncode(tableData.toJson()));
      return file;
    } catch (e) {
      debugPrint('Error exporting to JSON: $e');
      return null;
    }
  }

  Future<TableData?> importFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TableData.fromJson(json);
    } catch (e) {
      debugPrint('Error importing JSON: $e');
      return null;
    }
  }

  Future<TableData?> importFromJsonFile(File file) async {
    try {
      final contents = await file.readAsString();
      return importFromJson(contents);
    } catch (e) {
      debugPrint('Error importing from file: $e');
      return null;
    }
  }

  Future<String> exportToCsv(TableData tableData) async {
    final definition = tableData.definition;
    final records = tableData.records;

    final lines = <String>[];

    // Header
    final headerColumns = ['ID', 'RecordDate', ...definition.columns.map((col) => col.name)];
    lines.add(headerColumns.map(_escapeCsv).join(','));

    // Data rows
    for (final record in records) {
      final row = [
        record.id?.toString() ?? '',
        record.recordDate.toIso8601String(),
        ...definition.columns.map((col) {
          final value = record.data[col.name];
          return _escapeCsv(value?.toString() ?? '');
        }),
      ];
      lines.add(row.join(','));
    }

    return lines.join('\n');
  }

  Future<File?> exportToCsvFile(TableData tableData, String fileName) async {
    try {
      final appDir = await _getAppDirectory();
      final file = File('${appDir.path}/$fileName');
      final csv = await exportToCsv(tableData);
      await file.writeAsString(csv);
      return file;
    } catch (e) {
      debugPrint('Error exporting to CSV: $e');
      return null;
    }
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<Directory> getExportsDirectory() async {
    return _getAppDirectory();
  }
}
