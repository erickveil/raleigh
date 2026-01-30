import 'package:hive/hive.dart';
import 'column_type.dart';

part 'column.g.dart';

@HiveType(typeId: 2)
class ColumnDef {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final ColumnType type;

  ColumnDef({
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
    };
  }

  factory ColumnDef.fromJson(Map<String, dynamic> json) {
    return ColumnDef(
      name: json['name'] as String,
      type: ColumnType.fromString(json['type'] as String? ?? 'string'),
    );
  }
}
