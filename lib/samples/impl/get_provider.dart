import 'package:recase/recase.dart';

import '../../common/utils/pubspec/pubspec_utils.dart';
import '../interface/sample_interface.dart';

/// [Sample] file from Provider file creation.
class ProviderSample extends Sample {
  final String _fileName;
  final bool isServer;
  final bool createEndpoints;
  final String modelPath;
  String? _namePascal;
  String? _nameSnake;

  ProviderSample(this._fileName,
      {bool overwrite = false,
      this.createEndpoints = false,
      this.modelPath = '',
      this.isServer = false,
      String path = ''})
      : super(path, overwrite: overwrite) {
    _namePascal = _fileName.pascalCase;
    _nameSnake = _fileName.snakeCase;
  }

  String get _serverImport => "import 'package:get_server/get_server.dart';";

  String get _flutterImport => '''import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';''';

  String get _importModelPath => createEndpoints
      ? "import 'package:${PubspecUtils.projectName}/$modelPath';\n"
      : '\n';

  @override
  String get content => isServer ? _serverContent : _flutterContent;

  String get _serverContent => '''$_serverImport
$_importModelPath
class ${_fileName.pascalCase}Provider extends GetConnect {
@override
void onInit() {
$_defaultEncoder httpClient.baseUrl = 'YOUR-API-URL';
}
$_legacyEndpoint}
''';

  String get _flutterContent => '''$_flutterImport
$_importModelPath
@RestApi()
abstract class ${_fileName.pascalCase}Provider {
$_retrofitEndpoint}

Dio create${_fileName.pascalCase}ProviderDio({
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

  String get _retrofitEndpoint => createEndpoints
      ? '''
  @GET('/$_nameSnake/{id}')
  Future<HttpResponse<$_namePascal>> get$_namePascal(
    @Path('id') int id,
  );

  @POST('/$_nameSnake')
  Future<HttpResponse<$_namePascal>> create$_namePascal(
    @Body() $_namePascal body,
  );

  @DELETE('/$_nameSnake/{id}')
  Future<HttpResponse<void>> delete$_namePascal(
    @Path('id') int id,
  );
'''
      : '''
  @GET('/$_nameSnake/{id}')
  Future<HttpResponse<Map<String, dynamic>>> get$_namePascal(
    @Path('id') int id,
  );

  @POST('/$_nameSnake')
  Future<HttpResponse<Map<String, dynamic>>> create$_namePascal(
    @Body() Map<String, dynamic> body,
  );
''';

  String get _legacyEndpoint => createEndpoints
      ? '''
\tFuture<$_namePascal?> get$_namePascal(int id) async {
\t\tfinal response = await get('$_nameSnake/\$id');
\t\treturn response.body;
}

\tFuture<Response<$_namePascal>> post$_namePascal($_namePascal body) async => 
\t\tawait post('$_nameSnake', body);
\tFuture<Response> delete$_namePascal(int id) async => 
\t\tawait delete('$_nameSnake/\$id');
'''
      : '\n';

  String get _defaultEncoder => createEndpoints
      ? '''\t\thttpClient.defaultDecoder = (map){
if(map is Map<String, dynamic>) return $_namePascal.fromJson(map); 
if(map is List) return map.map((item)=> $_namePascal.fromJson(item)).toList();
};\n'''
      : '\n';
}
