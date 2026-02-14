import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table_data.dart';
import '../models/record.dart';
import '../models/column_type.dart';
import '../models/column.dart' as col;
import '../providers/tables_provider.dart';
import '../widgets/contribution_graph.dart';
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

        // Aggregate contributions for this table only
        final Map<DateTime, int> contributionCounts = {};
        for (final record in tableData.records) {
          final date = DateTime(
            record.recordDate.year,
            record.recordDate.month,
            record.recordDate.day,
          );
          contributionCounts[date] = (contributionCounts[date] ?? 0) + 1;
        }

        return _buildTableView(
          context,
          tableData,
          tablesProvider,
          contributionCounts,
        );
      },
    );
  }

  Widget _buildTableView(
    BuildContext context,
    TableData tableData,
    TablesProvider tablesProvider,
    Map<DateTime, int> contributionCounts,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tableData.definition.name),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _addColumn(context, tableData, tablesProvider),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 20, color: Color(0xFF6366F1)),
                    SizedBox(width: 8),
                    Text('Add Column'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: widget.onExportJson,
                child: const Row(
                  children: [
                    Icon(Icons.code, size: 20, color: Color(0xFF6366F1)),
                    SizedBox(width: 8),
                    Text('Export as JSON'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: widget.onExportCsv,
                child: const Row(
                  children: [
                    Icon(Icons.table_chart, size: 20, color: Color(0xFF6366F1)),
                    SizedBox(width: 8),
                    Text('Export as CSV'),
                  ],
                ),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ContributionGraph(
                      contributionCounts: contributionCounts,
                      endDate: DateTime.now(),
                    ),
                  ),
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
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDescriptionSection(tableData, tablesProvider),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ContributionGraph(
                            contributionCounts: contributionCounts,
                            endDate: DateTime.now(),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
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
                      ],
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
          record: record,
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

  void _addColumn(
    BuildContext context,
    TableData tableData,
    TablesProvider tablesProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _AddColumnDialog(
        onSave: (newColumn, defaultValue) {
          tablesProvider.addColumn(widget.tableName, newColumn, defaultValue);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Column "${newColumn.name}" added to all records'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}

class _AddColumnDialog extends StatefulWidget {
  final Function(col.ColumnDef newColumn, dynamic defaultValue) onSave;

  const _AddColumnDialog({required this.onSave});

  @override
  State<_AddColumnDialog> createState() => _AddColumnDialogState();
}

class _AddColumnDialogState extends State<_AddColumnDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _defaultValueController = TextEditingController();
  ColumnType _selectedType = ColumnType.string;
  bool _boolDefaultValue = false;

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a column name')),
      );
      return;
    }

    dynamic defaultValue;
    final defaultText = _defaultValueController.text.trim();

    try {
      switch (_selectedType) {
        case ColumnType.string:
          defaultValue = defaultText;
          break;
        case ColumnType.integer:
          defaultValue = int.parse(defaultText);
          break;
        case ColumnType.double:
          defaultValue = double.parse(defaultText);
          break;
        case ColumnType.dateTime:
          defaultValue = DateTime.parse(defaultText).toIso8601String();
          break;
        case ColumnType.boolean:
          defaultValue = _boolDefaultValue;
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid default value for ${_selectedType.displayName}'),
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    widget.onSave(
      col.ColumnDef(
        name: name,
        type: _selectedType,
        description: description.isEmpty ? null : description,
      ),
      defaultValue,
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _defaultValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Column'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Column Name',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Email, Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data Type',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<ColumnType>(
                isExpanded: true,
                underline: const SizedBox(),
                value: _selectedType,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: ColumnType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Default Value',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_selectedType == ColumnType.boolean)
              CheckboxListTile(
                title: const Text('True'),
                value: _boolDefaultValue,
                onChanged: (value) => setState(() => _boolDefaultValue = value ?? false),
                contentPadding: EdgeInsets.zero,
              )
            else
              TextField(
                controller: _defaultValueController,
                decoration: InputDecoration(
                  hintText: _getHintText(_selectedType),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FF),
                ),
                keyboardType: _getKeyboardType(_selectedType),
              ),
            const SizedBox(height: 16),
            const Text(
              'Description (Optional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Describe this column',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Add Column')),
      ],
    );
  }

  String _getHintText(ColumnType type) {
    switch (type) {
      case ColumnType.string: return 'Default text';
      case ColumnType.integer: return '0';
      case ColumnType.double: return '0.0';
      case ColumnType.dateTime: return 'YYYY-MM-DD';
      case ColumnType.boolean: return '';
    }
  }

  TextInputType _getKeyboardType(ColumnType type) {
    switch (type) {
      case ColumnType.string: return TextInputType.text;
      case ColumnType.integer: return TextInputType.number;
      case ColumnType.double: return const TextInputType.numberWithOptions(decimal: true);
      case ColumnType.dateTime: return TextInputType.datetime;
      case ColumnType.boolean: return TextInputType.text;
    }
  }
}
