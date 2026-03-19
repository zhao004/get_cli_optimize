import 'package:get_cli/samples/impl/getx_pattern/database.dart';
import 'package:get_cli/samples/impl/getx_pattern/database_enum.dart';
import 'package:get_cli/samples/impl/getx_pattern/database_table.dart';
import 'package:get_cli/samples/impl/getx_pattern/database_type.dart';
import 'package:get_cli/samples/impl/getx_pattern/http_client.dart';
import 'package:get_cli/samples/impl/getx_pattern/json_serializable_model.dart';
import 'package:test/test.dart';

void main() {
  test('drift database sample targets the new database folder', () {
    final sample = DriftDatabaseSample();

    expect(sample.path, equals('lib/app/database/database.dart'));
    expect(sample.content, contains("package:drift/drift.dart"));
    expect(
        sample.content, contains("package:path_provider/path_provider.dart"));
    expect(sample.content, contains("part 'database.g.dart';"));
    expect(sample.content, contains('@DriftDatabase(tables: [Todos])'));
    expect(
        sample.content, contains('class AppDatabase extends _\$AppDatabase'));
    expect(sample.content, contains('Future<List<Todo>> getAllTodos()'));
    expect(sample.content, contains('NativeDatabase.createInBackground'));
  });

  test('retrofit http sample targets the new http folder', () {
    final sample = RetrofitHttpSample();

    expect(sample.path, equals('lib/app/http/app_http_client.dart'));
    expect(sample.content, contains("package:dio/dio.dart"));
    expect(sample.content, contains("package:retrofit/retrofit.dart"));
    expect(sample.content, contains("part 'app_http_client.g.dart';"));
    expect(sample.content, contains('@RestApi()'));
    expect(sample.content, contains('abstract class AppHttpClient'));
    expect(
      sample.content,
      contains('factory AppHttpClient(Dio dio, {String baseUrl})'),
    );
    expect(sample.content, contains('LogInterceptor('));
  });

  test('retrofit http sample uses custom file name for part output', () {
    final sample = RetrofitHttpSample(path: 'lib/app/http/project_api.dart');

    expect(sample.content, contains("part 'project_api.g.dart';"));
  });

  test('database support samples target enum, tables and type folders', () {
    final enumSample = DriftDatabaseEnumSample();
    final tableSample = DriftDatabaseTableSample();
    final typeSample = DriftDatabaseTypeSample();

    expect(enumSample.path, equals('lib/app/database/enum/todo_status.dart'));
    expect(enumSample.content, contains('enum TodoStatus'));

    expect(tableSample.path, equals('lib/app/database/tables/todos.dart'));
    expect(tableSample.content, contains('class Todos extends Table'));
    expect(tableSample.content, contains('textEnum<TodoStatus>()'));

    expect(
      typeSample.path,
      equals('lib/app/database/type/utc_date_time_converter.dart'),
    );
    expect(
      typeSample.content,
      contains('class UtcDateTimeConverter extends TypeConverter'),
    );
  });

  test('json serializable model sample targets the models folder', () {
    final sample = JsonSerializableModelSample();

    expect(sample.path, equals('lib/app/models/app_user.dart'));
    expect(
      sample.content,
      contains("import 'package:json_annotation/json_annotation.dart';"),
    );
    expect(sample.content, contains("part 'app_user.g.dart';"));
    expect(sample.content, contains('@JsonSerializable()'));
    expect(sample.content, contains('class AppUser'));
    expect(sample.content, contains('factory AppUser.fromJson'));
    expect(sample.content, contains('Map<String, dynamic> toJson()'));
  });
}
