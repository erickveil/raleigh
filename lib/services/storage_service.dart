import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/table_data.dart';

class StorageService {
  static const String _appDirectory = 'raleigh';

  Future<Directory> _getAppDirectory() async {
    Directory? baseDirectory;

    // Android: prefer public Downloads directory for user accessibility
    if (Platform.isAndroid) {
      try {
        final downloadsDirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (downloadsDirs != null && downloadsDirs.isNotEmpty) {
          baseDirectory = downloadsDirs.first;
        }
      } catch (e) {
        debugPrint('Android downloads directory not available: $e');
      }
    } else {
      // Desktop: try Downloads directory first (accessible to user)
      try {
        baseDirectory = await getDownloadsDirectory();
      } catch (e) {
        debugPrint('Downloads directory not available: $e');
      }
    }

    // Fall back to Documents directory if Downloads is not available
    baseDirectory ??= await getApplicationDocumentsDirectory();

    final appDir = Directory('${baseDirectory.path}/$_appDirectory');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    debugPrint('StorageService app directory: ${appDir.path}');
    return appDir;
  }

  /// Export table as JSON string
  Future<String> exportToJson(TableData tableData) async {
    return jsonEncode(tableData.toJson());
  }

  /// Export table as JSON file
  Future<File?> exportToJsonFile(TableData tableData, String fileName) async {
    try {
      final appDir = await _getAppDirectory();
      final file = File('${appDir.path}/$fileName');
      await file.writeAsString(jsonEncode(tableData.toJson()));
      debugPrint('Exported JSON file to: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('Error exporting to JSON: $e');
      return null;
    }
  }

  /// Import table from JSON string
  Future<TableData?> importFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TableData.fromJson(json);
    } catch (e) {
      debugPrint('Error importing JSON: $e');
      return null;
    }
  }

  /// Import table from JSON file
  Future<TableData?> importFromJsonFile(File file) async {
    try {
      final contents = await file.readAsString();
      return importFromJson(contents);
    } catch (e) {
      debugPrint('Error importing from file: $e');
      return null;
    }
  }

  /// Export table as CSV string
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

  /// Export table as CSV file
  Future<File?> exportToCsvFile(TableData tableData, String fileName) async {
    try {
      final appDir = await _getAppDirectory();
      final file = File('${appDir.path}/$fileName');
      final csv = await exportToCsv(tableData);
      await file.writeAsString(csv);
      debugPrint('Exported CSV file to: ${file.path}');
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

  /// Get the exports directory
  Future<Directory> getExportsDirectory() async {
    final dir = await _getAppDirectory();
    debugPrint('Exports directory resolved to: ${dir.path}');
    return dir;
  }
}
