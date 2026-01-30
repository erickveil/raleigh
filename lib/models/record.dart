import 'package:hive/hive.dart';

part 'record.g.dart';

@HiveType(typeId: 0)
class Record {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final DateTime recordDate;

  @HiveField(2)
  final Map<String, dynamic> data;

  Record({
    this.id,
    DateTime? recordDate,
    required this.data,
  }) : recordDate = recordDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordDate': recordDate.toIso8601String(),
      ...data,
    };
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    final jsonCopy = Map<String, dynamic>.from(json);
    final id = jsonCopy.remove('id') as int?;
    final recordDate = jsonCopy.remove('recordDate') as String?;

    return Record(
      id: id,
      recordDate:
          recordDate != null ? DateTime.parse(recordDate) : DateTime.now(),
      data: jsonCopy,
    );
  }

  Record copyWith({
    int? id,
    DateTime? recordDate,
    Map<String, dynamic>? data,
  }) {
    return Record(
      id: id ?? this.id,
      recordDate: recordDate ?? this.recordDate,
      data: data ?? this.data,
    );
  }
}
