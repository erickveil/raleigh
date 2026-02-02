import 'package:hive/hive.dart';
import 'column_type.dart';

part 'column.g.dart';

@HiveType(typeId: 2)
class ColumnDef {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final ColumnType type;

  @HiveField(2)
  final String? description;

  ColumnDef({
    required this.name,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      if (description != null) 'description': description,
    };
  }

  factory ColumnDef.fromJson(Map<String, dynamic> json) {
    return ColumnDef(
      name: json['name'] as String,
      type: ColumnType.fromString(json['type'] as String? ?? 'string'),
      description: json['description'] as String?,
    );
  }
}
