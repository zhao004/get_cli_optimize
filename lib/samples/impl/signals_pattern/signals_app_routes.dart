import '../../interface/sample_interface.dart';

/// Signals Pattern 架构的 [lib/app/routes/app_routes.dart] 模板。
/// 与 GetX 的 Routes/_Paths 不同，go_router 直接以路径常量命名路由。
class SignalsRoutesSample extends Sample {
  SignalsRoutesSample()
      : super('lib/app/routes/app_routes.dart', overwrite: true);

  @override
  String get content => '''
class Routes {
  Routes._();

  static const String home = '/';
}
''';
}
