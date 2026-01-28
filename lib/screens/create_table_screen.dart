import 'package:flutter/material.dart';
import '../models/column.dart' as col;
import '../models/column_type.dart';

class CreateTableScreen extends StatefulWidget {
  final Function(String name, List<col.ColumnDef> columns) onTableCreated;

  const CreateTableScreen({
    super.key,
    required this.onTableCreated,
  });

  @override
  State<CreateTableScreen> createState() => _CreateTableScreenState();
}

class _CreateTableScreenState extends State<CreateTableScreen> {
  final _tableNameController = TextEditingController();
  final List<col.ColumnDef> _columns = [];

  void _addColumn() {
    showDialog(
      context: context,
      builder: (context) => _ColumnDialog(
        onSave: (columnName, columnType) {
          setState(() {
            _columns.add(col.ColumnDef(name: columnName, type: columnType));
          });
        },
      ),
    );
  }

  void _deleteColumn(int index) {
    setState(() {
      _columns.removeAt(index);
    });
  }

  void _createTable() {
    final tableName = _tableNameController.text.trim();
    if (tableName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a table name')),
      );
      return;
    }
    if (_columns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one column')),
      );
      return;
    }

    widget.onTableCreated(tableName, _columns);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tableNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Table'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tableNameController,
              decoration: const InputDecoration(
                labelText: 'Table Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Columns',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_columns.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No columns added yet'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _columns.length,
                itemBuilder: (context, index) {
                  final column = _columns[index];
                  return Card(
                    child: ListTile(
                      title: Text(column.name),
                      subtitle: Text(column.type.displayName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteColumn(index),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addColumn,
                icon: const Icon(Icons.add),
                label: const Text('Add Column'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createTable,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Create Table',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnDialog extends StatefulWidget {
  final Function(String name, ColumnType type) onSave;

  const _ColumnDialog({required this.onSave});

  @override
  State<_ColumnDialog> createState() => _ColumnDialogState();
}

class _ColumnDialogState extends State<_ColumnDialog> {
  final _columnNameController = TextEditingController();
  ColumnType _selectedType = ColumnType.string;

  void _save() {
    final columnName = _columnNameController.text.trim();
    if (columnName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a column name')),
      );
      return;
    }

    widget.onSave(columnName, _selectedType);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _columnNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Column'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _columnNameController,
            decoration: const InputDecoration(
              labelText: 'Column Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButton<ColumnType>(
            isExpanded: true,
            value: _selectedType,
            items: ColumnType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
