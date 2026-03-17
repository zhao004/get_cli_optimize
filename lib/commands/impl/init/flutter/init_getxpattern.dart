import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:recase/recase.dart';

import '../../../../common/utils/logger/log_utils.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../functions/create/create_list_directory.dart';
import '../../../../functions/create/create_main.dart';
import '../../../../samples/impl/getx_pattern/database.dart';
import '../../../../samples/impl/getx_pattern/get_main.dart';
import '../../../../samples/impl/getx_pattern/http_client.dart';
import '../../commads_export.dart';
import '../../install/install_get.dart';

Future<void> createInitGetxPattern() async {
  var canContinue = await createMain();
  if (!canContinue) return;

  var isServerProject = PubspecUtils.isServerProject;
  var httpFileName = _defaultHttpClientFileName;
  if (!isServerProject) {
    await _installFlutterInitDependencies();
    httpFileName = _askHttpFileName();
  }
  var initialDirs = isServerProject ? _serverDirectories : _flutterDirectories;
  GetXMainSample(isServer: isServerProject).create();
  if (!isServerProject) {
    DriftDatabaseSample().create();
    RetrofitHttpSample(
      path: 'lib/app/http/$httpFileName.dart',
    ).create();
  }
  await Future.wait([
    CreatePageCommand().execute(),
  ]);
  createListDirectory(initialDirs);

  LogService.success(Translation(LocaleKeys.sucess_getx_pattern_generated));
}

const List<_InitDependency> _flutterDependencies = [
  _InitDependency('dio', version: '5.9.2'),
  _InitDependency('drift', version: '2.22.1'),
  _InitDependency('path_provider', version: '2.1.4'),
  _InitDependency('retrofit', version: '4.5.0'),
  _InitDependency('sqlite3_flutter_libs', version: '0.5.42'),
];

final List<Directory> _flutterDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/controller/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/enum/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/tables/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/database/type/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/http/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/models/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/utils/')),
  Directory(Structure.replaceAsExpected(path: 'lib/app/widgets/')),
];

final List<Directory> _serverDirectories = [
  Directory(Structure.replaceAsExpected(path: 'lib/app/pages/')),
];

const _defaultHttpClientFileName = 'app_http_client';

Future<void> _installFlutterInitDependencies() async {
  await installGet(false, '4.7.3');

  for (final dependency in _flutterDependencies) {
    if (PubspecUtils.containsPackage(dependency.package)) {
      continue;
    }
    await PubspecUtils.addDependencies(
      dependency.package,
      version: dependency.version,
      runPubGet: false,
    );
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

class _InitDependency {
  final String package;
  final String version;

  const _InitDependency(
    this.package, {
    required this.version,
  });
}
