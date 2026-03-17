import '../../interface/sample_interface.dart';

class DriftDatabaseSample extends Sample {
  DriftDatabaseSample({String path = 'lib/app/database/database.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabaseConnection {
  const AppDatabaseConnection._();

  static QueryExecutor openConnection({
    String fileName = 'app_database.sqlite',
  }) {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('\${directory.path}/\$fileName');
      return NativeDatabase.createInBackground(file);
    });
  }
}
''';
}
