import '../../interface/sample_interface.dart';

class DriftDatabaseSample extends Sample {
  DriftDatabaseSample({String path = 'lib/app/database/database.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/todos.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Todos])
class AppDatabase extends _\$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Todo>> getAllTodos() => select(todos).get();

  Future<int> createTodo(TodosCompanion todo) => into(todos).insert(todo);

  Future<bool> updateTodo(Todo todo) => update(todos).replace(todo);

  Future<int> deleteTodo(int id) =>
      (delete(todos)..where((table) => table.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('\${directory.path}/app_database.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}
''';
}
