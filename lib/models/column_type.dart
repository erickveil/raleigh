enum ColumnType {
  string('String'),
  integer('Integer'),
  double('Double'),
  dateTime('DateTime'),
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
