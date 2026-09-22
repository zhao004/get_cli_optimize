import 'dart:io';

import '../../../../common/utils/flutter/flutter_init_features.dart';
import '../../../../common/utils/flutter/flutter_toolchain.dart';
import '../../../../common/utils/logger/log_utils.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../common/utils/shell/shel.utils.dart';
import '../../../../core/structure.dart';
import '../../../../functions/create/create_list_directory.dart';
import '../../../../functions/create/create_main.dart';
import '../../../../samples/impl/getx_pattern/database.dart';
import '../../../../samples/impl/getx_pattern/database_enum.dart';
import '../../../../samples/impl/getx_pattern/database_table.dart';
import '../../../../samples/impl/getx_pattern/database_type.dart';
import '../../../../samples/impl/getx_pattern/http_client.dart';
import '../../../../samples/impl/getx_pattern/json_serializable_model.dart';
import '../../../../samples/impl/getx_pattern/langchain_agent.dart';
import '../../../../samples/impl/signals_pattern/signals_app_router.dart';
import '../../../../samples/impl/signals_pattern/signals_app_routes.dart';
import '../../../../samples/impl/signals_pattern/signals_controller.dart';
import '../../../../samples/impl/signals_pattern/signals_injector.dart';
import '../../../../samples/impl/signals_pattern/signals_main.dart';
import '../../../../samples/impl/signals_pattern/signals_view.dart';

const _defaultHttpClientFileName = 'app_http_client.dart';

/// Signals Pattern 架构（get_it + go_router + Signals）的初始化流程。
/// 与 GetX 流程不同：不运行 CreatePageCommand（其模板硬编码 GetX），
/// home 示例页由模板直接生成并预置好路由与依赖注册；
/// 可选集成（drift/json_serializable/retrofit/langchain）默认不预选。
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

  final dependencyBundle = await _resolveFlutterInitDependencies();
  final selectedFeatures =
      FlutterInitFeatures.ask(dependencyBundle, initiallySelectAll: false);

  await _installDependencies(dependencyBundle, selectedFeatures);

  SignalsMainSample().create();
  SignalsInjectorSample().create();
  SignalsRoutesSample().create();
  SignalsRouterSample().create();
  SignalsControllerSample().create();
  SignalsViewSample().create();
  _createFeatureSamples(selectedFeatures);

  createListDirectory(_signalsDirectories(selectedFeatures));

  if (FlutterInitFeatures.shouldRunBuildRunner(selectedFeatures)) {
    await ShellUtils.runBuildRunner();
  }

  LogService.success('Signals Pattern structure successfully generated.');
}

Future<void> _installDependencies(
  FlutterInitDependencyBundle dependencyBundle,
  Set<FlutterInitFeature> selectedFeatures,
) async {
  // 核心三件套不加版本约束，由当前 SDK 解析兼容版本；pub get 由 InitCommand 统一执行
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

  // 可选集成沿用工具链版本约束
  await PubspecUtils.ensureDependencies(
    FlutterInitFeatures.resolveSelectedDependencies(
      dependencyBundle,
      selectedFeatures,
    )
        .map(
          (dependency) => PubspecDependencyRequest(
            package: dependency.package,
            constraint: dependency.constraint,
            isDev: dependency.isDev,
          ),
        )
        .toList(),
    runPubGet: false,
  );
}

/// 按选中的可选集成生成对应模板文件。
/// 这些模板不依赖 GetX，与 GetX Pattern 流程复用同一套文件。
void _createFeatureSamples(Set<FlutterInitFeature> selectedFeatures) {
  if (selectedFeatures.contains(FlutterInitFeature.drift)) {
    DriftDatabaseEnumSample().create();
    DriftDatabaseTypeSample().create();
    DriftDatabaseTableSample().create();
    DriftDatabaseSample().create();
  }
  if (selectedFeatures.contains(FlutterInitFeature.retrofit)) {
    RetrofitHttpSample(
      path: 'lib/app/http/$_defaultHttpClientFileName',
    ).create();
  }
  if (selectedFeatures.contains(FlutterInitFeature.jsonSerializable)) {
    JsonSerializableModelSample().create();
  }
  if (selectedFeatures.contains(FlutterInitFeature.langChain)) {
    LangChainAgentSample().create();
  }
}

Future<FlutterInitDependencyBundle> _resolveFlutterInitDependencies() async {
  final toolchain = await ShellUtils.detectFlutterToolchain();
  return FlutterInitDependencyResolver.resolve(toolchain);
}

/// Signals Pattern 架构的基础目录骨架。
/// di/routes/pages 已由模板写入文件，这里补齐空目录保持结构完整。
final List<Directory> _signalsBaseDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/di/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/routes/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/pages/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/models/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/utils/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/widgets/')),
];

final List<Directory> _signalsDatabaseDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/enum/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/tables/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/type/')),
];

final List<Directory> _signalsHttpDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/http/')),
];

final List<Directory> _signalsAiDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/ai/')),
];

List<Directory> _signalsDirectories(Set<FlutterInitFeature> selectedFeatures) {
  final directories = <Directory>[
    ..._signalsBaseDirectories,
  ];

  if (selectedFeatures.contains(FlutterInitFeature.drift)) {
    directories.addAll(_signalsDatabaseDirectories);
  }
  if (selectedFeatures.contains(FlutterInitFeature.retrofit)) {
    directories.addAll(_signalsHttpDirectories);
  }
  if (selectedFeatures.contains(FlutterInitFeature.langChain)) {
    directories.addAll(_signalsAiDirectories);
  }

  return directories;
}
