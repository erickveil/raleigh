import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table_data.dart';
import '../models/record.dart';
import '../providers/tables_provider.dart';
import 'data_entry_screen.dart';

class ViewTableScreen extends StatefulWidget {
  final String tableName;
  final Function() onExportJson;
  final Function() onExportCsv;

  const ViewTableScreen({
    super.key,
    required this.tableName,
    required this.onExportJson,
    required this.onExportCsv,
  });

  @override
  State<ViewTableScreen> createState() => _ViewTableScreenState();
}

class _ViewTableScreenState extends State<ViewTableScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TablesProvider>(
      builder: (context, tablesProvider, _) {
        final tableData = tablesProvider.tables[widget.tableName];
        if (tableData == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Table Not Found')),
            body: const Center(child: Text('Table not found')),
          );
        }

        return _buildTableView(context, tableData, tablesProvider);
      },
    );
  }

  Widget _buildTableView(
    BuildContext context,
    TableData tableData,
    TablesProvider tablesProvider,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tableData.definition.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: widget.onExportJson,
                child: const Text('Export as JSON'),
              ),
              PopupMenuItem(
                onTap: widget.onExportCsv,
                child: const Text('Export as CSV'),
              ),
            ],
          ),
        ],
      ),
      body: tableData.records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No records yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('ID')),
                    const DataColumn(label: Text('RecordDate')),
                    ...tableData.definition.columns
                        .map((c) => DataColumn(label: Text(c.name))),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: List<DataRow>.generate(
                    tableData.records.length,
                    (index) {
                      final record = tableData.records[index];
                      return DataRow(
                        cells: [
                          DataCell(Text(record.id?.toString() ?? '')),
                          DataCell(Text(
                            record.recordDate.toLocal().toString().split('.')[0],
                          )),
                          ...tableData.definition.columns
                              .map((c) => DataCell(
                                    Text(record.data[c.name]?.toString() ?? ''),
                                  )),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _editRecord(context, tableData, index, record, tablesProvider),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () =>
                                      _deleteRecord(context, tableData, index, tablesProvider),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRecord(context, tableData, tablesProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addRecord(BuildContext context, TableData tableData, TablesProvider tablesProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataEntryScreen(
          tableDefinition: tableData.definition,
          onRecordSaved: (record) {
            tablesProvider.addRecord(widget.tableName, record);
          },
        ),
      ),
    );
  }

  void _editRecord(BuildContext context, TableData tableData, int index, Record record, TablesProvider tablesProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataEntryScreen(
          tableDefinition: tableData.definition,
          onRecordSaved: (updatedRecord) {
            final newRecord = updatedRecord.copyWith(id: record.id);
            tablesProvider.updateRecord(widget.tableName, index, newRecord);
          },
        ),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  void _deleteRecord(BuildContext context, TableData tableData, int index, TablesProvider tablesProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              tablesProvider.deleteRecord(widget.tableName, index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
