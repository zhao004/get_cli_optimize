import 'package:get_cli/samples/impl/get_provider.dart';
import 'package:test/test.dart';

void main() {
  test('flutter provider sample uses retrofit and dio', () {
    final sample = ProviderSample('user');

    expect(sample.content, contains("package:dio/dio.dart"));
    expect(sample.content, contains("package:retrofit/retrofit.dart"));
    expect(sample.content, contains('abstract class UserProvider'));
    expect(sample.content, contains("@GET('/user/{id}')"));
    expect(sample.content, contains('createUserProviderDio'));
    expect(sample.content, isNot(contains('extends GetConnect')));
  });

  test('typed provider sample imports the generated model', () {
    final sample = ProviderSample(
      'user',
      createEndpoints: true,
      modelPath: 'app/models/user_model.dart',
    );

    expect(
      sample.content,
      contains("import 'package:get_cli/app/models/user_model.dart';"),
    );
    expect(sample.content, contains('Future<HttpResponse<User>> getUser'));
    expect(sample.content, contains('Future<HttpResponse<User>> createUser'));
    expect(sample.content, contains('Future<HttpResponse<void>> deleteUser'));
  });
}
