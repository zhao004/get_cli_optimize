import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:recase/recase.dart';

import '../../../../common/menu/menu.dart';
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
  final selectedFeatures = <_FlutterInitFeature>{};
  if (!isServerProject) {
    final dependencyBundle = await _resolveFlutterInitDependencies();
    selectedFeatures.addAll(_askFlutterInitFeatures());
    await _installFlutterInitDependencies(dependencyBundle, selectedFeatures);
    if (selectedFeatures.contains(_FlutterInitFeature.retrofit)) {
      httpFileName = _askHttpFileName();
    }
  }
  var initialDirs = isServerProject
      ? _serverDirectories
      : _flutterDirectories(selectedFeatures);
  GetXMainSample(isServer: isServerProject).create();
  if (!isServerProject) {
    if (selectedFeatures.contains(_FlutterInitFeature.drift)) {
      DriftDatabaseEnumSample().create();
      DriftDatabaseTypeSample().create();
      DriftDatabaseTableSample().create();
      DriftDatabaseSample().create();
    }
    if (selectedFeatures.contains(_FlutterInitFeature.retrofit)) {
      RetrofitHttpSample(
        path: 'lib/app/http/$httpFileName.dart',
      ).create();
    }
    if (selectedFeatures.contains(_FlutterInitFeature.jsonSerializable)) {
      JsonSerializableModelSample().create();
    }
    if (selectedFeatures.contains(_FlutterInitFeature.langChain)) {
      LangChainAgentSample().create();
    }
  }
  await Future.wait([
    CreatePageCommand().execute(),
  ]);
  createListDirectory(initialDirs);

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

const _defaultHttpClientFileName = 'app_http_client';

Future<FlutterInitDependencyBundle> _resolveFlutterInitDependencies() async {
  final toolchain = await ShellUtils.detectFlutterToolchain();
  return FlutterInitDependencyResolver.resolve(toolchain);
}

Future<void> _installFlutterInitDependencies(
    FlutterInitDependencyBundle dependencyBundle,
    Set<_FlutterInitFeature> selectedFeatures) async {
  await installGet(false, '4.7.3');

  for (final dependency
      in _resolveSelectedDependencies(dependencyBundle, selectedFeatures)) {
    await PubspecUtils.ensureDependency(
      dependency.package,
      version: dependency.version,
      isDev: dependency.isDev,
      runPubGet: false,
    );
  }
}

List<Directory> _flutterDirectories(Set<_FlutterInitFeature> selectedFeatures) {
  final directories = <Directory>[
    ..._flutterBaseDirectories,
  ];

  if (selectedFeatures.contains(_FlutterInitFeature.drift)) {
    directories.addAll(_flutterDatabaseDirectories);
  }
  if (selectedFeatures.contains(_FlutterInitFeature.retrofit)) {
    directories.addAll(_flutterHttpDirectories);
  }
  if (selectedFeatures.contains(_FlutterInitFeature.langChain)) {
    directories.addAll(_flutterAiDirectories);
  }

  return directories;
}

Set<_FlutterInitFeature> _askFlutterInitFeatures() {
  final answer = MultiSelectMenu(
    _flutterInitFeatureOptions.map((option) => option.label).toList(),
    title: 'Select optional integrations',
    description: 'Use ↑/↓ to move, Space to toggle, Enter to confirm.',
    initiallySelectedIndexes: List<int>.generate(
      _flutterInitFeatureOptions.length,
      (index) => index,
    ),
  ).choose();

  return answer.indexes
      .map((index) => _flutterInitFeatureOptions[index].feature)
      .toSet();
}

List<FlutterInitDependencySpec> _resolveSelectedDependencies(
  FlutterInitDependencyBundle dependencyBundle,
  Set<_FlutterInitFeature> selectedFeatures,
) {
  final dependenciesByPackage = <String, FlutterInitDependencySpec>{};

  for (final feature in selectedFeatures) {
    for (final package in _packagesForFeature(feature)) {
      dependenciesByPackage[package] = dependencyBundle.dependency(package);
    }
  }

  return dependenciesByPackage.values.toList();
}

Iterable<String> _packagesForFeature(_FlutterInitFeature feature) sync* {
  if (feature == _FlutterInitFeature.drift) {
    yield 'build_runner';
    yield 'drift';
    yield 'drift_dev';
    yield 'path_provider';
    yield 'sqlite3_flutter_libs';
  }

  if (feature == _FlutterInitFeature.retrofit) {
    yield 'build_runner';
    yield 'dio';
    yield 'retrofit';
    yield 'retrofit_generator';
  }

  if (feature == _FlutterInitFeature.jsonSerializable) {
    yield 'build_runner';
    yield 'json_annotation';
    yield 'json_serializable';
  }

  if (feature == _FlutterInitFeature.langChain) {
    yield 'langchain';
    yield 'langchain_openai';
  }
}

String _askHttpFileName() {
  final rawValue = ask(
    'Http client file name',
    defaultValue: _defaultHttpClientFileName,
  );
  final sanitized = rawValue.trim().replaceAll('.dart', '');
  if (sanitized.isEmpty) {
    return _defaultHttpClientFileName;
  }
  return ReCase(sanitized).snakeCase;
}

enum _FlutterInitFeature {
  drift,
  jsonSerializable,
  langChain,
  retrofit,
}

class _FlutterInitFeatureOption {
  final _FlutterInitFeature feature;
  final String label;

  const _FlutterInitFeatureOption(this.feature, this.label);
}

const _flutterInitFeatureOptions = [
  _FlutterInitFeatureOption(
    _FlutterInitFeature.drift,
    'Drift database (drift, drift_dev, sqlite3_flutter_libs, path_provider)',
  ),
  _FlutterInitFeatureOption(
    _FlutterInitFeature.jsonSerializable,
    'JSON serialization (json_annotation, json_serializable)',
  ),
  _FlutterInitFeatureOption(
    _FlutterInitFeature.langChain,
    'LangChain AI agent (langchain, langchain_openai)',
  ),
  _FlutterInitFeatureOption(
    _FlutterInitFeature.retrofit,
    'Retrofit HTTP (dio, retrofit, retrofit_generator)',
  ),
];
