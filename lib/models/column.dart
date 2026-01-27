import 'column_type.dart';

class ColumnDef {
  final String name;
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
