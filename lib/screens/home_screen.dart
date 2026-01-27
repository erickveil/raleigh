import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../providers/tables_provider.dart';
import '../services/storage_service.dart';
import 'create_table_screen.dart';
import 'view_table_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();

  void _createNewTable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTableScreen(
          onTableCreated: (name, columns) {
            context.read<TablesProvider>().createTable(name, columns);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Table "$name" created')),
            );
          },
        ),
      ),
    );
  }

  void _viewTable(BuildContext context, String tableName) {
    final tableData = context.read<TablesProvider>().tables[tableName];
    if (tableData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewTableScreen(
            tableData: tableData,
            onRecordAdded: (record) {
              context.read<TablesProvider>().addRecord(tableName, record);
            },
            onRecordUpdated: (index, record) {
              context.read<TablesProvider>().updateRecord(tableName, index, record);
            },
            onRecordDeleted: (index) {
              context.read<TablesProvider>().deleteRecord(tableName, index);
            },
            onExportJson: () => _exportTable(context, tableName, 'json'),
            onExportCsv: () => _exportTable(context, tableName, 'csv'),
          ),
        ),
      );
    }
  }

  void _exportTable(BuildContext context, String tableName, String format) async {
    final provider = context.read<TablesProvider>();
    try {
      String content;
      String extension;

      if (format == 'json') {
        content = await provider.exportTableAsJson(tableName);
        extension = 'json';
      } else {
        content = await provider.exportTableAsCSV(tableName);
        extension = 'csv';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${tableName}_$timestamp.$extension';

      final directory = await _storageService.getExportsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to $fileName')),
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

  void _deleteTable(BuildContext context, String tableName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Table'),
        content: Text('Are you sure you want to delete "$tableName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TablesProvider>().deleteTable(tableName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Table "$tableName" deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _importTable(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final importedData = await _storageService.importFromJsonFile(file);

        if (importedData != null && mounted) {
          final tableName = importedData.definition.name;
          final provider = context.read<TablesProvider>();

          // Check if table already exists
          if (provider.tables.containsKey(tableName)) {
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Table Exists'),
                content: Text(
                  'A table named "$tableName" already exists. Do you want to replace it?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.deleteTable(tableName);
                      provider.createTable(
                        tableName,
                        importedData.definition.columns,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Table "$tableName" imported')),
                      );
                    },
                    child: const Text('Replace'),
                  ),
                ],
              ),
            );
          } else {
            await provider.createTable(
              tableName,
              importedData.definition.columns,
            );
            // Add records
            for (final record in importedData.records) {
              await provider.addRecord(tableName, record);
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Table "$tableName" imported successfully')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raleigh Data Tracker'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _importTable(context),
                child: const Text('Import Table'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TablesProvider>(
        builder: (context, provider, _) {
          final tables = provider.tables;

          if (tables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_chart,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tables yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _createNewTable(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Table'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final tableName = tables.keys.toList()[index];
              final tableData = tables[tableName]!;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListTile(
                  title: Text(
                    tableName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${tableData.records.length} records • ${tableData.definition.columns.length} columns',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _deleteTable(context, tableName),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                  onTap: () => _viewTable(context, tableName),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewTable(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
