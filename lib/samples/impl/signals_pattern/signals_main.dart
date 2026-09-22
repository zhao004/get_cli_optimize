import '../../interface/sample_interface.dart';

/// Signals Pattern 架构的 [lib/main.dart] 模板。
/// 通过 MaterialApp.router 接入 go_router，启动前先完成 get_it 依赖注册。
class SignalsMainSample extends Sample {
  SignalsMainSample() : super('lib/main.dart', overwrite: true);

  @override
  String get content => '''
import 'package:flutter/material.dart';

import 'app/di/injector.dart';
import 'app/routes/app_router.dart';

void main() {
  Injector.registerAll();
  runApp(const MyApp());
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
