import 'column.dart';

class TableDefinition {
  final String name;
  final List<ColumnDef> columns;

  TableDefinition({
    required this.name,
    required this.columns,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'columns': columns.map((col) => col.toJson()).toList(),
    };
  }

  factory TableDefinition.fromJson(Map<String, dynamic> json) {
    return TableDefinition(
      name: json['name'] as String,
      columns: (json['columns'] as List<dynamic>?)
              ?.map((col) => ColumnDef.fromJson(col as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
