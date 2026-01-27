import 'package:flutter/material.dart';
import '../models/column_type.dart';
import '../models/table_definition.dart';
import '../models/record.dart';

class DataEntryScreen extends StatefulWidget {
  final TableDefinition tableDefinition;
  final Function(Record record) onRecordSaved;

  const DataEntryScreen({
    super.key,
    required this.tableDefinition,
    required this.onRecordSaved,
  });

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final column in widget.tableDefinition.columns) {
      _controllers[column.name] = TextEditingController();
    }
  }

  void _saveRecord() {
    final data = <String, dynamic>{};
    bool hasError = false;

    for (final column in widget.tableDefinition.columns) {
      final value = _controllers[column.name]!.text.trim();

      if (value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${column.name} is required')),
        );
        hasError = true;
        break;
      }

      try {
        switch (column.type) {
          case ColumnType.string:
            data[column.name] = value;
            break;
          case ColumnType.integer:
            data[column.name] = int.parse(value);
            break;
          case ColumnType.double:
            data[column.name] = double.parse(value);
            break;
          case ColumnType.dateTime:
            data[column.name] = DateTime.parse(value).toIso8601String();
            break;
          case ColumnType.boolean:
            data[column.name] = value.toLowerCase() == 'true';
            break;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid ${column.type.displayName} for ${column.name}'),
          ),
        );
        hasError = true;
        break;
      }
    }

    if (!hasError) {
      final record = Record(data: data);
      widget.onRecordSaved(record);
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Record to ${widget.tableDefinition.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...widget.tableDefinition.columns.map((column) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _controllers[column.name],
                  decoration: InputDecoration(
                    labelText: column.name,
                    hintText: _getHintText(column.type),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: _getKeyboardType(column.type),
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Save Record',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText(ColumnType type) {
    switch (type) {
      case ColumnType.string:
        return 'Enter text';
      case ColumnType.integer:
        return 'Enter whole number';
      case ColumnType.double:
        return 'Enter decimal number';
      case ColumnType.dateTime:
        return 'YYYY-MM-DD HH:MM:SS';
      case ColumnType.boolean:
        return 'true or false';
    }
  }

  TextInputType _getKeyboardType(ColumnType type) {
    switch (type) {
      case ColumnType.string:
        return TextInputType.text;
      case ColumnType.integer:
      case ColumnType.double:
        return TextInputType.number;
      case ColumnType.dateTime:
        return TextInputType.datetime;
      case ColumnType.boolean:
        return TextInputType.text;
    }
  }
}
