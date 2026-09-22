import '../../interface/sample_interface.dart';

/// Signals Pattern 架构的 [lib/app/routes/app_router.dart] 模板。
/// 预置 home 路由；保持 `class AppRouter {` 纯声明形式，
/// 便于后续以 appendClassContent/行插入方式追加 GoRoute。
class SignalsRouterSample extends Sample {
  SignalsRouterSample() : super('lib/app/routes/app_router.dart', overwrite: true);

  @override
  String get content => '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/home/home_view.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: Routes.home,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
}
''';
}
