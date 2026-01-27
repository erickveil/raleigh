import 'package:flutter/material.dart';
import '../models/table_data.dart';
import '../models/record.dart';
import 'data_entry_screen.dart';

class ViewTableScreen extends StatefulWidget {
  final TableData tableData;
  final Function(Record record) onRecordAdded;
  final Function(int index, Record record) onRecordUpdated;
  final Function(int index) onRecordDeleted;
  final Function() onExportJson;
  final Function() onExportCsv;

  const ViewTableScreen({
    super.key,
    required this.tableData,
    required this.onRecordAdded,
    required this.onRecordUpdated,
    required this.onRecordDeleted,
    required this.onExportJson,
    required this.onExportCsv,
  });

  @override
  State<ViewTableScreen> createState() => _ViewTableScreenState();
}

class _ViewTableScreenState extends State<ViewTableScreen> {
  late TableData _tableData;

  @override
  void initState() {
    super.initState();
    _tableData = widget.tableData;
  }

  void _addRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataEntryScreen(
          tableDefinition: _tableData.definition,
          onRecordSaved: (record) {
            widget.onRecordAdded(record);
            setState(() {
              _tableData.addRecord(record);
            });
          },
        ),
      ),
    );
  }

  void _editRecord(int index, Record record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataEntryScreen(
          tableDefinition: _tableData.definition,
          onRecordSaved: (updatedRecord) {
            final newRecord = updatedRecord.copyWith(id: record.id);
            widget.onRecordUpdated(index, newRecord);
            setState(() {
              _tableData.updateRecord(index, newRecord);
            });
          },
        ),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  void _deleteRecord(int index) {
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
              widget.onRecordDeleted(index);
              setState(() {
                _tableData.deleteRecord(index);
              });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tableData.definition.name),
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
      body: _tableData.records.isEmpty
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
                    ..._tableData.definition.columns
                        .map((c) => DataColumn(label: Text(c.name))),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: List<DataRow>.generate(
                    _tableData.records.length,
                    (index) {
                      final record = _tableData.records[index];
                      return DataRow(
                        cells: [
                          DataCell(Text(record.id?.toString() ?? '')),
                          DataCell(Text(
                            record.recordDate.toLocal().toString().split('.')[0],
                          )),
                          ..._tableData.definition.columns
                              .map((c) => DataCell(
                                    Text(record.data[c.name]?.toString() ?? ''),
                                  )),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _editRecord(index, record),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () => _deleteRecord(index),
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
        onPressed: _addRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}
