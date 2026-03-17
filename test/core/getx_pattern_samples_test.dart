import 'package:get_cli/samples/impl/getx_pattern/database.dart';
import 'package:get_cli/samples/impl/getx_pattern/http_client.dart';
import 'package:test/test.dart';

void main() {
  test('drift database sample targets the new database folder', () {
    final sample = DriftDatabaseSample();

    expect(sample.path, equals('lib/app/database/database.dart'));
    expect(sample.content, contains("package:drift/drift.dart"));
    expect(
        sample.content, contains("package:path_provider/path_provider.dart"));
    expect(sample.content, contains('class AppDatabaseConnection'));
    expect(sample.content, contains('NativeDatabase.createInBackground'));
  });

  test('retrofit http sample targets the new http folder', () {
    final sample = RetrofitHttpSample();

    expect(sample.path, equals('lib/app/http/app_http_client.dart'));
    expect(sample.content, contains("package:dio/dio.dart"));
    expect(sample.content, contains("package:retrofit/retrofit.dart"));
    expect(sample.content, contains('@RestApi()'));
    expect(sample.content, contains('abstract class AppHttpClient'));
  });
}
