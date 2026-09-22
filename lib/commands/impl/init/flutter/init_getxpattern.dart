import 'dart:io';

import '../../../../common/utils/flutter/flutter_init_features.dart';
import '../../../../common/utils/flutter/flutter_toolchain.dart';
import '../../../../common/utils/logger/log_utils.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../common/utils/shell/shel.utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../functions/create/create_list_directory.dart';
import '../../../../functions/create/create_main.dart';
import '../../../../samples/impl/getx_pattern/database.dart';
import '../../../../samples/impl/getx_pattern/database_enum.dart';
import '../../../../samples/impl/getx_pattern/database_table.dart';
import '../../../../samples/impl/getx_pattern/database_type.dart';
import '../../../../samples/impl/getx_pattern/get_main.dart';
import '../../../../samples/impl/getx_pattern/http_client.dart';
import '../../../../samples/impl/getx_pattern/json_serializable_model.dart';
import '../../../../samples/impl/getx_pattern/langchain_agent.dart';
import '../../commads_export.dart';
import '../../install/install_get.dart';

Future<void> createInitGetxPattern() async {
  var canContinue = await createMain();
  if (!canContinue) return;

  var isServerProject = PubspecUtils.isServerProject;
  var httpFileName = _defaultHttpClientFileName;
  final selectedFeatures = <FlutterInitFeature>{};
  if (!isServerProject) {
    final dependencyBundle = await _resolveFlutterInitDependencies();
    selectedFeatures.addAll(
      FlutterInitFeatures.ask(dependencyBundle, initiallySelectAll: true),
    );
    await _installFlutterInitDependencies(dependencyBundle, selectedFeatures);
  }
  var initialDirs = isServerProject
      ? _serverDirectories
      : _flutterDirectories(selectedFeatures);
  GetXMainSample(isServer: isServerProject).create();
  if (!isServerProject) {
    if (selectedFeatures.contains(FlutterInitFeature.drift)) {
      DriftDatabaseEnumSample().create();
      DriftDatabaseTypeSample().create();
      DriftDatabaseTableSample().create();
      DriftDatabaseSample().create();
    }
    if (selectedFeatures.contains(FlutterInitFeature.retrofit)) {
      RetrofitHttpSample(
        path: 'lib/app/http/$httpFileName',
      ).create();
    }
    if (selectedFeatures.contains(FlutterInitFeature.jsonSerializable)) {
      JsonSerializableModelSample().create();
    }
    if (selectedFeatures.contains(FlutterInitFeature.langChain)) {
      LangChainAgentSample().create();
    }
  }
  await Future.wait([
    CreatePageCommand().execute(),
  ]);
  createListDirectory(initialDirs);
  if (!isServerProject &&
      FlutterInitFeatures.shouldRunBuildRunner(selectedFeatures)) {
    await ShellUtils.runBuildRunner();
  }

  LogService.success(Translation(LocaleKeys.sucess_getx_pattern_generated));
}

final List<Directory> _flutterBaseDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/controller/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/models/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/utils/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/widgets/')),
];

final List<Directory> _flutterDatabaseDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/enum/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/tables/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/type/')),
];

final List<Directory> _flutterHttpDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/http/')),
];

final List<Directory> _flutterAiDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/ai/')),
];

final List<Directory> _serverDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/pages/')),
];

const _defaultHttpClientFileName = 'app_http_client.dart';

Future<FlutterInitDependencyBundle> _resolveFlutterInitDependencies() async {
  final toolchain = await ShellUtils.detectFlutterToolchain();
  return FlutterInitDependencyResolver.resolve(toolchain);
}

Future<void> _installFlutterInitDependencies(
    FlutterInitDependencyBundle dependencyBundle,
    Set<FlutterInitFeature> selectedFeatures) async {
  await installGet(false, '>=4.7.3 <5.0.0');

  await PubspecUtils.ensureDependencies(
    FlutterInitFeatures.resolveSelectedDependencies(
            dependencyBundle, selectedFeatures)
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

List<Directory> _flutterDirectories(Set<FlutterInitFeature> selectedFeatures) {
  final directories = <Directory>[
    ..._flutterBaseDirectories,
  ];

  if (selectedFeatures.contains(FlutterInitFeature.drift)) {
    directories.addAll(_flutterDatabaseDirectories);
  }
  if (selectedFeatures.contains(FlutterInitFeature.retrofit)) {
    directories.addAll(_flutterHttpDirectories);
  }
  if (selectedFeatures.contains(FlutterInitFeature.langChain)) {
    directories.addAll(_flutterAiDirectories);
  }

  return directories;
}
