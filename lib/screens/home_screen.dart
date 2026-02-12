import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../providers/tables_provider.dart';
import '../services/storage_service.dart';
import '../widgets/contribution_graph.dart';
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
          onTableCreated: (name, columns, description) {
            context.read<TablesProvider>().createTable(
              name,
              columns,
              description,
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Table "$name" created')));
          },
        ),
      ),
    );
  }

  void _viewTable(BuildContext context, String tableName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewTableScreen(
          tableName: tableName,
          onExportJson: () => _exportTable(context, tableName, 'json'),
          onExportCsv: () => _exportTable(context, tableName, 'csv'),
        ),
      ),
    );
  }

  void _exportTable(
    BuildContext context,
    String tableName,
    String format,
  ) async {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Exported to $fileName')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
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
                        importedData.definition.description,
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
              importedData.definition.description,
            );
            // Add records
            for (final record in importedData.records) {
              await provider.addRecord(tableName, record);
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Table "$tableName" imported successfully'),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raleigh Data Tracker'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: 'Import Table',
              onPressed: () => _importTable(context),
            ),
          ),
        ],
      ),
      body: Consumer<TablesProvider>(
        builder: (context, provider, _) {
          final tables = provider.tables;

          // Aggregate contributions
          final Map<DateTime, int> contributionCounts = {};
          for (final table in tables.values) {
            for (final record in table.records) {
              final date = DateTime(
                record.recordDate.year,
                record.recordDate.month,
                record.recordDate.day,
              );
              contributionCounts[date] = (contributionCounts[date] ?? 0) + 1;
            }
          }

          if (tables.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (contributionCounts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: ContributionGraph(
                          contributionCounts: contributionCounts,
                          endDate: DateTime.now(),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.table_chart,
                        size: 64,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No tables yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first table to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _createNewTable(context),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Create New Table'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tables.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ContributionGraph(
                      contributionCounts: contributionCounts,
                      endDate: DateTime.now(),
                    ),
                  );
                }

                final tableIndex = index - 1;
                final tableName = tables.keys.toList()[tableIndex];
                final tableData = tables[tableName]!;
                final colors = [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFEC4899),
                  const Color(0xFFF59E0B),
                  const Color(0xFF10B981),
                ];
                final cardColor = colors[index % colors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _viewTable(context, tableName),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cardColor.withOpacity(0.1),
                              cardColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.table_chart,
                                color: cardColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tableName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cardColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '${tableData.records.length} records',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: cardColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${tableData.definition.columns.length} columns',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<void>(
                              itemBuilder: (context) => [
                                PopupMenuItem<void>(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () {
                                      _exportTable(context, tableName, 'json');
                                    });
                                  },
                                  child: const Text('Export as JSON'),
                                ),
                                PopupMenuItem<void>(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () {
                                      _exportTable(context, tableName, 'csv');
                                    });
                                  },
                                  child: const Text('Export as CSV'),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem<void>(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () {
                                      _deleteTable(context, tableName);
                                    });
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewTable(context),
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
