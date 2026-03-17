import '../../interface/sample_interface.dart';

class RetrofitHttpSample extends Sample {
  RetrofitHttpSample({String path = 'lib/app/http/app_http_client.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

@RestApi()
abstract class AppHttpClient {
  @GET('/health')
  Future<HttpResponse<Map<String, dynamic>>> getHealth();
}

Dio createAppDio({
  String baseUrl = 'https://example.com',
}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );
}
''';
}
