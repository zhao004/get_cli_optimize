import '../../interface/sample_interface.dart';

class DriftDatabaseEnumSample extends Sample {
  DriftDatabaseEnumSample(
      {String path = 'lib/app/database/enum/todo_status.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''enum TodoStatus {
  pending,
  inProgress,
  done,
}
''';
}
