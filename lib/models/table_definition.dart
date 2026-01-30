import 'package:hive/hive.dart';
import 'column.dart';

part 'table_definition.g.dart';

@HiveType(typeId: 3)
class TableDefinition {
  @HiveField(0)
  final String name;

  @HiveField(1)
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
