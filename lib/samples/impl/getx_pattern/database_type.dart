import '../../interface/sample_interface.dart';

class DriftDatabaseTypeSample extends Sample {
  DriftDatabaseTypeSample(
      {String path = 'lib/app/database/type/utc_date_time_converter.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''import 'package:drift/drift.dart';

class UtcDateTimeConverter extends TypeConverter<DateTime, DateTime> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(DateTime fromDb) => fromDb.toLocal();

  @override
  DateTime toSql(DateTime value) => value.toUtc();
}
''';
}
