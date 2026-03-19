import 'package:path/path.dart' as p;

import '../../interface/sample_interface.dart';

class RetrofitHttpSample extends Sample {
  RetrofitHttpSample({String path = 'lib/app/http/app_http_client.dart'})
      : super(path, overwrite: true);

  String get _outputFileName => p.basenameWithoutExtension(path);

  @override
  String get content => '''import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part '$_outputFileName.g.dart';

@RestApi()
abstract class AppHttpClient {
  factory AppHttpClient(Dio dio, {String baseUrl}) = _AppHttpClient;

  @GET('/health')
  Future<HttpResponse<Map<String, dynamic>>> health();
}

Dio createAppHttpClientDio({
  String baseUrl = 'https://example.com/api',
}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  )..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
}
''';
}
