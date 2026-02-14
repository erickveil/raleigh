/// This file contains the [AddColumnDialog] widget, which provides a user interface
/// for adding a new column to an existing table.
/// 
/// The dialog allows users to specify:
/// 1. The name of the new column.
/// 2. The data type of the column (String, Integer, Double, DateTime, Boolean).
/// 3. A default value that will be applied to all existing records in the table.
/// 4. An optional description for the column.
///
/// ---
/// ### Manual QA Tests:
/// 
/// **Test 1: Basic Column Creation**
/// 1. Open a table and select "Add Column" from the menu.
/// 2. Enter "Category" as the Column Name.
/// 3. Leave the Data Type as "String".
/// 4. Enter "General" as the Default Value.
/// 5. Click "Add Column".
/// 6. **Verification:** The dialog should close, a success snackbar should appear, 
///    and a new column "Category" should appear in the table with "General" in every row.
/// 
/// **Test 2: Validation Check (Empty Name)**
/// 1. Open "Add Column" dialog.
/// 2. Leave the Column Name empty.
/// 3. Click "Add Column".
/// 4. **Verification:** A snackbar should appear saying "Please enter a column name". 
///    The dialog should remain open.
/// 
/// **Test 3: Type Validation (Invalid Integer)**
/// 1. Open "Add Column" dialog.
/// 2. Enter "Age" as Column Name.
/// 3. Change Data Type to "Integer".
/// 4. Enter "abc" as the Default Value.
/// 5. Click "Add Column".
/// 6. **Verification:** A snackbar should appear saying "Invalid default value for Integer".
///    The dialog should remain open.
/// 
/// **Test 4: Boolean Type UI**
/// 1. Open "Add Column" dialog.
/// 2. Change Data Type to "Boolean".
/// 3. **Verification:** The "Default Value" text field should be replaced by a checkbox.
/// 4. Toggle the checkbox and click "Add Column".
/// 5. **Verification:** Existing records should now have the selected boolean value in the new column.

library;

import 'package:flutter/material.dart';
import '../models/column.dart' as col;
import '../models/column_type.dart';

/// A dialog widget that collects information for a new table column.
/// 
/// This widget is used in the `ViewTableScreen` when a user chooses to expand
/// the schema of an existing table. It captures the column definition and a 
/// default value to maintain data integrity for existing records.
class AddColumnDialog extends StatefulWidget {
  /// Callback triggered when the user clicks the "Add Column" button and 
  /// all inputs are validated.
  /// 
  /// Returns the constructed [col.ColumnDef] and the parsed [defaultValue].
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

  /// Validates the form input and invokes the [onSave] callback.
  /// 
  /// This method is called when the "Add Column" button is pressed.
  /// It performs the following:
  /// 1. Ensures the column name is not empty.
  /// 2. Parses the default value string into the correct type based on [_selectedType].
  /// 3. Displays error messages via [ScaffoldMessenger] if validation fails.
  /// 4. Returns the result to the caller via [onSave] and closes the dialog.
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

  /// Standard Flutter lifecycle method to clean up resources.
  /// 
  /// Disposes of all [TextEditingController] instances to prevent memory leaks
  /// when the dialog is removed from the widget tree.
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _defaultValueController.dispose();
    super.dispose();
  }

  /// Describes the part of the user interface represented by this widget.
  /// 
  /// Builds an [AlertDialog] containing:
  /// - A [TextField] for the column name.
  /// - A [DropdownButton] for selecting the [ColumnType].
  /// - A conditional input field (Checkbox or TextField) for the default value.
  /// - A [TextField] for the optional description.
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

  /// Returns a user-friendly hint string for the default value field based on the type.
  /// 
  /// This helps the user understand what format is expected for different data types.
  String _getHintText(ColumnType type) {
    switch (type) {
      case ColumnType.string: return 'Default text';
      case ColumnType.integer: return '0';
      case ColumnType.double: return '0.0';
      case ColumnType.dateTime: return 'YYYY-MM-DD';
      case ColumnType.boolean: return '';
    }
  }

  /// Returns the appropriate [TextInputType] for the mobile keyboard based on the column type.
  /// 
  /// Used to show numeric keyboards for numbers and date keyboards for dates, 
  /// improving the user experience on mobile devices.
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
