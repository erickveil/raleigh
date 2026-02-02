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
        elevation: 0,
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ...widget.tableDefinition.columns.asMap().entries.map((entry) {
                final index = entry.key;
                final column = entry.value;
                final colors = [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFEC4899),
                  const Color(0xFFF59E0B),
                  const Color(0xFF10B981),
                ];
                final columnColor = colors[index % colors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: columnColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              column.type.displayName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: columnColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  column.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                if (column.description != null &&
                                    column.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      column.description!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    column.type.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controllers[column.name],
                        decoration: InputDecoration(
                          hintText: _getHintText(column.type),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: columnColor,
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
                        keyboardType: _getKeyboardType(column.type),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Record',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
