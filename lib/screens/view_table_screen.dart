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
        elevation: 0,
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
          ? Container(
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
              child: Column(
                children: [
                  _buildDescriptionSection(tableData, tablesProvider),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inbox,
                              size: 64,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No records yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first record to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _addRecord(context, tableData, tablesProvider),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add Record'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
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
              child: Column(
                children: [
                  _buildDescriptionSection(tableData, tablesProvider),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 16,
                          dataRowHeight: 56,
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFF6366F1).withOpacity(0.1),
                          ),
                          headingRowHeight: 56,
                          columns: [
                            const DataColumn(
                              label: Text(
                                'ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            ...tableData.definition.columns.map(
                              (c) => DataColumn(
                                label: Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            tableData.records.length,
                            (displayIndex) {
                              final recordIndex =
                                  tableData.records.length - 1 - displayIndex;
                              final record = tableData.records[recordIndex];
                              return DataRow(
                                color: WidgetStateProperty.all(
                                  displayIndex.isEven
                                      ? Colors.white
                                      : const Color(
                                          0xFF6366F1,
                                        ).withOpacity(0.03),
                                ),
                                cells: [
                                  DataCell(
                                    Text(
                                      record.id?.toString() ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      record.recordDate
                                          .toLocal()
                                          .toString()
                                          .split('.')[0],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  ...tableData.definition.columns.map(
                                    (c) => DataCell(
                                      Text(
                                        record.data[c.name]?.toString() ?? '',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF6366F1,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                            color: const Color(0xFF6366F1),
                                            iconSize: 18,
                                            onPressed: () => _editRecord(
                                              context,
                                              tableData,
                                              recordIndex,
                                              record,
                                              tablesProvider,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            color: Colors.red[400],
                                            iconSize: 18,
                                            onPressed: () => _deleteRecord(
                                              context,
                                              tableData,
                                              recordIndex,
                                              tablesProvider,
                                            ),
                                          ),
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
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRecord(context, tableData, tablesProvider),
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _addRecord(
    BuildContext context,
    TableData tableData,
    TablesProvider tablesProvider,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataEntryScreen(
          tableName: widget.tableName,
          tableDefinition: tableData.definition,
          onRecordSaved: (record) {
            tablesProvider.addRecord(widget.tableName, record);
          },
        ),
      ),
    );
  }

  void _editRecord(
    BuildContext context,
    TableData tableData,
    int index,
    Record record,
    TablesProvider tablesProvider,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataEntryScreen(
          tableName: widget.tableName,
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

  void _deleteRecord(
    BuildContext context,
    TableData tableData,
    int index,
    TablesProvider tablesProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this record? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                const SnackBar(
                  content: Text('Record deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
    TableData tableData,
    TablesProvider tablesProvider,
  ) {
    final hasDescription = tableData.definition.description != null &&
        tableData.definition.description!.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
        ),
      ),
      child: hasDescription
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    tableData.definition.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () =>
                      _editDescription(context, tableData, tablesProvider),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    'No description',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _editDescription(context, tableData, tablesProvider),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Description'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
    );
  }

  void _editDescription(
    BuildContext context,
    TableData tableData,
    TablesProvider tablesProvider,
  ) {
    final controller = TextEditingController(
      text: tableData.definition.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Table Description'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter a description for this table',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FF),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final description = controller.text.trim();
              tablesProvider.updateTableDescription(
                widget.tableName,
                description.isEmpty ? null : description,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Description updated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(() => controller.dispose());
  }
}
