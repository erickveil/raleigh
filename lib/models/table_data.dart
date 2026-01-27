import 'record.dart';
import 'table_definition.dart';

class TableData {
  final TableDefinition definition;
  final List<Record> records;

  TableData({
    required this.definition,
    required this.records,
  });

  Map<String, dynamic> toJson() {
    return {
      'definition': definition.toJson(),
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  factory TableData.fromJson(Map<String, dynamic> json) {
    return TableData(
      definition: TableDefinition.fromJson(json['definition'] as Map<String, dynamic>),
      records: (json['records'] as List<dynamic>?)
              ?.map((record) => Record.fromJson(record as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  void addRecord(Record record) {
    records.add(record);
  }

  void updateRecord(int index, Record record) {
    if (index >= 0 && index < records.length) {
      records[index] = record;
    }
  }

  void deleteRecord(int index) {
    if (index >= 0 && index < records.length) {
      records.removeAt(index);
    }
  }
}
