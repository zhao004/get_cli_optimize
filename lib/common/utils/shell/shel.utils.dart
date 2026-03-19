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
    final pubCommand = resolvePubCommand();
    LogService.info('Adding package $package …');
    await run('$pubCommand add $package', verbose: true);
  }

  static Future<void> removePackage(String package) async {
    final pubCommand = resolvePubCommand();
    LogService.info('Removing package $package …');
    await run('$pubCommand remove $package', verbose: true);
  }

  static Future<FlutterToolchainInfo?> detectFlutterToolchain() async {
    if (resolvePubCommand() != 'flutter pub') {
      return null;
    }

    try {
      final result = await Process.run('flutter', ['--version', '--machine']);
      if (result.exitCode != 0) {
        return null;
      }

      final stdout = result.stdout;
      if (stdout is! String || stdout.trim().isEmpty) {
        return null;
      }

      return FlutterToolchainInfo.fromMachineJson(stdout);
    } on Exception {
      return null;
    }
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
