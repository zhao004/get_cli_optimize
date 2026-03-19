import '../../interface/sample_interface.dart';

class DriftDatabaseTableSample extends Sample {
  DriftDatabaseTableSample({String path = 'lib/app/database/tables/todos.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''import 'package:drift/drift.dart';

import '../enum/todo_status.dart';
import '../type/utc_date_time_converter.dart';

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().map(const UtcDateTimeConverter())();

  TextColumn get status =>
      textEnum<TodoStatus>().withDefault(const Constant(TodoStatus.pending))();
}
''';
}
