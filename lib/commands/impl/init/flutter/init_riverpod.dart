import 'dart:io';

import '../../../../common/utils/flutter/flutter_init_features.dart';
import '../../../../common/utils/flutter/flutter_toolchain.dart';
import '../../../../common/utils/flutter/riverpod_lint_setup.dart';
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
import '../../../../samples/impl/riverpod_pattern/riverpod_analysis_options.dart';
import '../../../../samples/impl/riverpod_pattern/riverpod_app_router.dart';
import '../../../../samples/impl/riverpod_pattern/riverpod_app_routes.dart';
import '../../../../samples/impl/riverpod_pattern/riverpod_controller.dart';
import '../../../../samples/impl/riverpod_pattern/riverpod_injector.dart';
import '../../../../samples/impl/riverpod_pattern/riverpod_main.dart';
import '../../../../samples/impl/riverpod_pattern/riverpod_service.dart';
import '../../../../samples/impl/riverpod_pattern/riverpod_view.dart';

const _defaultHttpClientFileName = 'app_http_client.dart';

/// Riverpod Pattern 架构（riverpod_generator + get_it + go_router）的初始化流程。
/// 与 Signals 流程一致：不运行 CreatePageCommand（其模板硬编码 GetX），
/// home 示例页由模板直接生成并预置好路由；可选集成默认不预选。
/// 与 Signals 不同：riverpod_generator 的 part 文件为运行必需，
/// 无论是否选择可选集成都会执行一次 build_runner。
/// get_it 只注册服务/仓储，UI 状态由 Riverpod 管理。
Future<void> createInitRiverpodPattern() async {
  if (PubspecUtils.isServerProject) {
    LogService.info(
      'Riverpod Pattern is only supported for Flutter projects.',
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

  await _installCoreDependencies();
  await _installOptionalDependencies(dependencyBundle, selectedFeatures);
  await _installRiverpodLint();

  RiverpodMainSample().create();
  RiverpodInjectorSample().create();
  RiverpodServiceSample().create();
  RiverpodRoutesSample().create();
  RiverpodRouterSample().create();
  RiverpodControllerSample().create();
  RiverpodViewSample().create();
  _createFeatureSamples(selectedFeatures);

  createListDirectory(_riverpodDirectories(selectedFeatures));

  await ShellUtils.runBuildRunner();

  LogService.success('Riverpod Pattern structure successfully generated.');
}

/// 核心依赖一次安装：get_it 负责服务定位，go_router 负责导航，
/// Riverpod codegen 负责 UI 状态；不加版本约束，由当前 SDK 解析兼容版本。
Future<void> _installCoreDependencies() async {
  await ShellUtils.addPackages([
    'get_it',
    'go_router',
    'flutter_riverpod',
    'riverpod_annotation',
    'dev:build_runner',
    'dev:riverpod_generator',
  ]);
}

/// 可选集成沿用工具链版本约束，共享包去重后一次安装。
Future<void> _installOptionalDependencies(
  FlutterInitDependencyBundle dependencyBundle,
  Set<FlutterInitFeature> selectedFeatures,
) async {
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

/// 安装 riverpod_lint 并按解析出的主版本生成 analysis_options.yaml。
/// Lint 属于增强能力，安装失败时只提示并跳过，不阻断架构生成。
Future<void> _installRiverpodLint() async {
  try {
    await ShellUtils.addPackages(['dev:riverpod_lint']);
    final constraint = PubspecUtils.dependencyVersion('riverpod_lint', true);
    if (constraint == null || constraint.isEmpty) {
      return;
    }

    if (!RiverpodLintSetup.usesAnalysisServerPlugin(constraint)) {
      await ShellUtils.addPackages(['dev:custom_lint']);
    }

    _writeAnalysisOptions(constraint);
  } on Exception catch (error) {
    LogService.info(
      'Skipped riverpod_lint setup: $error',
      false,
      false,
    );
  }
}

/// 写入 riverpod_lint 配置：文件不存在时直接生成；
/// 已存在时仅安全追加顶层配置，避免冲掉用户或 create project
/// 写入的 lint 配置；无法安全合并时提示手动处理。
void _writeAnalysisOptions(String constraint) {
  final analysisOptions = File('analysis_options.yaml');
  if (!analysisOptions.existsSync()) {
    RiverpodAnalysisOptionsSample(riverpodLintConstraint: constraint).create();
    return;
  }

  final merged = RiverpodLintSetup.mergeIntoExisting(
    analysisOptions.readAsStringSync(),
    constraint,
  );
  if (merged == null) {
    LogService.info(
      'analysis_options.yaml already has analyzer/plugin configuration; '
      'verify the riverpod_lint setup manually.',
      false,
      false,
    );
    return;
  }

  analysisOptions.writeAsStringSync(merged);
  LogService.success(
    'analysis_options.yaml updated with the riverpod_lint configuration.',
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

/// Riverpod Pattern 架构的基础目录骨架。
/// di/routes/pages/services 已由模板写入文件，这里补齐空目录保持结构完整。
final List<Directory> _riverpodBaseDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/di/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/routes/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/pages/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/services/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/models/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/utils/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/widgets/')),
];

final List<Directory> _riverpodDatabaseDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/enum/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/tables/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/type/')),
];

final List<Directory> _riverpodHttpDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/http/')),
];

final List<Directory> _riverpodAiDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/ai/')),
];

List<Directory> _riverpodDirectories(Set<FlutterInitFeature> selectedFeatures) {
  final directories = <Directory>[
    ..._riverpodBaseDirectories,
  ];

  if (selectedFeatures.contains(FlutterInitFeature.drift)) {
    directories.addAll(_riverpodDatabaseDirectories);
  }
  if (selectedFeatures.contains(FlutterInitFeature.retrofit)) {
    directories.addAll(_riverpodHttpDirectories);
  }
  if (selectedFeatures.contains(FlutterInitFeature.langChain)) {
    directories.addAll(_riverpodAiDirectories);
  }

  return directories;
}
