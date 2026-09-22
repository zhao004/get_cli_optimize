import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:yaml/yaml.dart';

import '../flutter/flutter_toolchain.dart';
import '../../../core/generator.dart';
import '../../../core/internationalization.dart';
import '../../../core/locales.g.dart';
import '../../../exception_handler/exceptions/cli_exception.dart';
import '../logger/log_utils.dart';
import '../pub_dev/pub_dev_api.dart';
import '../pubspec/pubspec_lock.dart';

class ShellUtils {
  static Future<void> pubGet() async {
    final pubCommand = resolvePubCommand();
    LogService.info('Running `$pubCommand get` …');
    await run('$pubCommand get', verbose: true);
  }

  static Future<void> addPackage(String package) async {
    await addPackages([package]);
  }

  static Future<void> addPackages(List<String> packages) async {
    if (packages.isEmpty) {
      return;
    }

    LogService.info('Adding packages ${packages.join(', ')} …');
    await run(resolveAddPackagesCommand(packages), verbose: true);
  }

  static Future<void> removePackage(String package) async {
    final pubCommand = resolvePubCommand();
    LogService.info('Removing package $package …');
    await run("$pubCommand remove '${_shellEscape(package)}'", verbose: true);
  }

  static Future<void> runBuildRunner() async {
    final command = resolveBuildRunnerCommand();
    LogService.info('Running `$command` …');
    await run(command, verbose: true);
  }

  static Future<FlutterToolchainInfo?> detectFlutterToolchain() async {
    if (resolvePubCommand() != 'flutter pub') {
      return null;
    }

    final result = await _runFlutterVersionMachine();
    if (result == null || result.exitCode != 0) {
      return null;
    }

    final stdout = result.stdout;
    if (stdout is! String || stdout.trim().isEmpty) {
      return null;
    }

    return FlutterToolchainInfo.fromMachineJson(stdout);
  }

  /// Windows 上 flutter 是 flutter.bat，Process.run 无法直接启动裸名 'flutter'，
  /// 需显式使用带扩展名的可执行文件；失败时逐个候选回退。
  static Future<ProcessResult?> _runFlutterVersionMachine() async {
    final candidates =
        Platform.isWindows ? ['flutter.bat', 'flutter'] : const ['flutter'];
    for (final candidate in candidates) {
      try {
        return await Process.run(candidate, ['--version', '--machine']);
      } on Exception catch (_) {
        // 尝试下一个候选
      }
    }
    return null;
  }

  static String resolvePubCommand([String? pubspecContent]) {
    try {
      final content = pubspecContent ??
          (File('pubspec.yaml').existsSync()
              ? File('pubspec.yaml').readAsStringSync()
              : null);
      if (content == null || content.trim().isEmpty) {
        return 'dart pub';
      }

      final yaml = loadYaml(content);
      if (yaml is! YamlMap) {
        return 'dart pub';
      }

      if (yaml.containsKey('flutter') || _hasFlutterDependency(yaml)) {
        return 'flutter pub';
      }
    } on Exception catch (_) {}

    return 'dart pub';
  }

  /// `flutter pub run` 已被 Flutter 弃用，统一改用 dart run 执行 build_runner。
  static String resolveBuildRunnerCommand() {
    return 'dart run build_runner build --delete-conflicting-outputs';
  }

  static String resolveAddPackagesCommand(
    List<String> packages, [
    String? pubspecContent,
  ]) {
    if (packages.isEmpty) {
      throw ArgumentError.value(packages, 'packages', 'Cannot be empty');
    }

    final pubCommand = resolvePubCommand(pubspecContent);
    final formattedPackages = packages
        .map((package) => '"${_shellEscape(package)}"')
        .join(' ');
    return '$pubCommand add $formattedPackages';
  }

  static bool _hasFlutterDependency(YamlMap yaml) {
    for (final sectionName in ['dependencies', 'dev_dependencies']) {
      final section = yaml[sectionName];
      if (section is! YamlMap || !section.containsKey('flutter')) {
        continue;
      }

      final dependency = section['flutter'];
      if (dependency is YamlMap) {
        return dependency['sdk'] == 'flutter';
      }

      return true;
    }

    return false;
  }

  static String _shellEscape(String value) {
    return value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  }

  static Future<void> flutterCreate(
    String path,
    String? org,
    String iosLang,
    String androidLang,
  ) async {
    LogService.info('Running `flutter create $path` …');

    // Note: -i and -a flags are only supported for --template=plugin
    // For regular Flutter projects, Flutter uses Swift/Kotlin by default
    await run('flutter create --no-pub --org $org "$path"', verbose: true);
  }

  static Future<void> update(
      [bool isGit = false, bool forceUpdate = false]) async {
    isGit = GetCli.arguments.contains('--git');
    forceUpdate = GetCli.arguments.contains('-f');
    if (!isGit && !forceUpdate) {
      var versionInPubDev =
          await PubDevApi.getLatestVersionFromPackage('get_cli');

      var versionInstalled = await PubspecLock.getVersionCli(disableLog: true);

      if (versionInstalled != null && versionInstalled == versionInPubDev) {
        return LogService.info(
            Translation(LocaleKeys.info_cli_last_version_already_installed.tr)
                .toString());
      }
    }

    LogService.info('Upgrading get_cli …');

    try {
      if (Platform.script.path.contains('flutter')) {
        if (isGit) {
          await run(
              'flutter pub global activate -sgit https://github.com/jonataslaw/get_cli/',
              verbose: true);
        } else {
          await run('flutter pub global activate get_cli', verbose: true);
        }
      } else {
        if (isGit) {
          await run(
              'flutter pub global activate -sgit https://github.com/jonataslaw/get_cli/',
              verbose: true);
        } else {
          await run('flutter pub global activate get_cli', verbose: true);
        }
      }
      return LogService.success(LocaleKeys.sucess_update_cli.tr);
    } on Exception catch (err) {
      throw CliException('${LocaleKeys.error_update_cli.tr}: $err');
    }
  }
}
