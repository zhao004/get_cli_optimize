import '../../interface/sample_interface.dart';

/// Riverpod Pattern 架构的 [lib/main.dart] 模板。
/// 启动前先通过 get_it 注册服务，再以 [ProviderScope] 承载 Riverpod
/// 状态容器，导航交给 go_router。
class RiverpodMainSample extends Sample {
  RiverpodMainSample() : super('lib/main.dart', overwrite: true);

  @override
  String get content => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/di/injector.dart';
import 'app/routes/app_router.dart';

void main() {
  Injector.registerAll();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Application',
      routerConfig: AppRouter.router,
    );
  }
}
''';
}
