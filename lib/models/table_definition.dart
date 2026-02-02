import 'package:hive/hive.dart';
import 'column.dart';

part 'table_definition.g.dart';

@HiveType(typeId: 3)
class TableDefinition {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<ColumnDef> columns;

  @HiveField(2)
  final String? description;

  TableDefinition({
    required this.name,
    required this.columns,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'columns': columns.map((col) => col.toJson()).toList(),
      if (description != null) 'description': description,
    };
  }

  factory TableDefinition.fromJson(Map<String, dynamic> json) {
    return TableDefinition(
      name: json['name'] as String,
      columns:
          (json['columns'] as List<dynamic>?)
              ?.map((col) => ColumnDef.fromJson(col as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
    );
  }
}
