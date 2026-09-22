import 'dart:io';

import '../../../../common/utils/logger/log_utils.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../core/structure.dart';
import '../../../../functions/create/create_list_directory.dart';
import '../../../../functions/create/create_main.dart';
import '../../../../samples/impl/signals_pattern/signals_app_router.dart';
import '../../../../samples/impl/signals_pattern/signals_app_routes.dart';
import '../../../../samples/impl/signals_pattern/signals_controller.dart';
import '../../../../samples/impl/signals_pattern/signals_injector.dart';
import '../../../../samples/impl/signals_pattern/signals_main.dart';
import '../../../../samples/impl/signals_pattern/signals_view.dart';

/// Signals Pattern 架构（get_it + go_router + Signals）的初始化流程。
/// 与 GetX 流程不同：不运行 CreatePageCommand（其模板硬编码 GetX），
/// home 示例页由模板直接生成并预置好路由与依赖注册。
Future<void> createInitSignalsPattern() async {
  if (PubspecUtils.isServerProject) {
    LogService.info(
      'Signals Pattern is only supported for Flutter projects.',
      false,
      false,
    );
    return;
  }

  var canContinue = await createMain();
  if (!canContinue) return;

  // 依赖不加版本约束，由当前 SDK 解析兼容版本；pub get 由 InitCommand 统一执行
  await PubspecUtils.addDependencies(
    'get_it',
    promptIfExists: false,
    runPubGet: false,
  );
  await PubspecUtils.addDependencies(
    'go_router',
    promptIfExists: false,
    runPubGet: false,
  );
  await PubspecUtils.addDependencies(
    'signals',
    promptIfExists: false,
    runPubGet: false,
  );

  SignalsMainSample().create();
  SignalsInjectorSample().create();
  SignalsRoutesSample().create();
  SignalsRouterSample().create();
  SignalsControllerSample().create();
  SignalsViewSample().create();

  createListDirectory(_signalsDirectories);

  LogService.success('Signals Pattern structure successfully generated.');
}

/// Signals Pattern 架构的基础目录骨架。
/// di/routes/pages 已由模板写入文件，这里补齐空目录保持结构完整。
final List<Directory> _signalsDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/di/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/routes/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/pages/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/models/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/utils/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/widgets/')),
];
