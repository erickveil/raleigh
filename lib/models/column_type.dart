import 'package:hive/hive.dart';

part 'column_type.g.dart';

@HiveType(typeId: 1)
enum ColumnType {
  @HiveField(0)
  string('String'),
  @HiveField(1)
  integer('Integer'),
  @HiveField(2)
  double('Double'),
  @HiveField(3)
  dateTime('DateTime'),
  @HiveField(4)
  boolean('Boolean');

  final String displayName;

  const ColumnType(this.displayName);

  static ColumnType fromString(String value) {
    return ColumnType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ColumnType.string,
    );
  }
}
