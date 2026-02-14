import 'package:flutter/material.dart';
import '../models/column.dart' as col;
import '../models/column_type.dart';

class AddColumnDialog extends StatefulWidget {
  final Function(col.ColumnDef newColumn, dynamic defaultValue) onSave;

  const AddColumnDialog({super.key, required this.onSave});

  @override
  State<AddColumnDialog> createState() => _AddColumnDialogState();
}

class _AddColumnDialogState extends State<AddColumnDialog> {
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
