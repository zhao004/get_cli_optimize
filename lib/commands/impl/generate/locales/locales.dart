import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import '../../../../common/utils/logger/log_utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../exception_handler/exceptions/cli_exception.dart';
import '../../../../samples/impl/generate_locales.dart';
import '../../../interface/command.dart';

class GenerateLocalesCommand extends Command {
  @override
  String get commandName => 'locales';
  @override
  String? get hint => Translation(LocaleKeys.hint_generate_locales).tr;

  @override
  bool validate() {
    return true;
  }

  @override
  Future<void> execute() async {
    final inputPath =
        args.isNotEmpty ? args.first : await _defaultInputDirectory();

    if (!await Directory(inputPath).exists()) {
      throw CliException(
        LocaleKeys.error_nonexistent_directory.trArgs([inputPath]),
      );
    }

    final files = await Directory(inputPath)
        .list(recursive: false)
        .where((entry) => entry.path.endsWith('.json'))
        .toList();
    files.sort((first, second) => first.path.compareTo(second.path));

    if (files.isEmpty) {
      throw CliException(LocaleKeys.error_empty_directory.trArgs([inputPath]));
    }

    final maps = <String, Map<String, dynamic>?>{};
    for (var file in files) {
      try {
        final map = jsonDecode(await File(file.path).readAsString());
        final localeKey = basenameWithoutExtension(file.path);
        maps[localeKey] = map as Map<String, dynamic>?;
      } on Exception catch (_) {
        throw CliException(LocaleKeys.error_invalid_json.trArgs([file.path]));
      }
    }

    final locales = <String, Map<String, String>>{};
    maps.forEach((key, value) {
      final result = <String, String>{};
      _resolve(value!, result);
      locales[key] = result;
    });

    final keys = <String>{};
    locales.forEach((key, value) {
      value.forEach((key, value) {
        keys.add(key);
      });
    });

    final sortedTranslationKeys = keys.toList()..sort();
    final parsedKeys = sortedTranslationKeys
        .map((key) => '\tstatic const $key = \'$key\';')
        .join('\n');

    final parsedLocales = StringBuffer('\n');
    final translationsKeys = StringBuffer();
    final localeNames = locales.keys.toList()..sort();
    for (final localeName in localeNames) {
      final values = locales[localeName]!;
      parsedLocales.writeln('\tstatic const $localeName = {');
      translationsKeys.writeln('\t\t\'$localeName\': Locales.$localeName,');

      final localeKeys = values.keys.toList()..sort();
      for (final key in localeKeys) {
        var value = values[key]!;
        value = _replaceValue(value);
        if (RegExp(r'^[0-9]|[!@#<>?":`~;[\]\\|=+)(*&^%-\s]').hasMatch(key)) {
          throw CliException(
              LocaleKeys.error_special_characters_in_key.trArgs([key]));
        }
        parsedLocales.writeln('\t\t\'$key\': \'$value\',');
      }
      parsedLocales.writeln('\t};');
    }

    var newFileModel =
        Structure.model('locales', 'generate_locales', false, on: onCommand);

    GenerateLocalesSample(
            parsedKeys, parsedLocales.toString(), translationsKeys.toString(),
            path: '${newFileModel.path}.g.dart')
        .create();

    LogService.success(LocaleKeys.sucess_locale_generate.tr);
  }

  void _resolve(Map<String, dynamic> localization, Map<String, String?> result,
      [String? accKey]) {
    final sortedKeys = localization.keys.toList();

    for (var key in sortedKeys) {
      if (localization[key] is Map) {
        var nextAccKey = key;
        if (accKey != null) {
          nextAccKey = '${accKey}_$key';
        }
        _resolve(localization[key] as Map<String, dynamic>, result, nextAccKey);
      } else {
        result[accKey != null ? '${accKey}_$key' : key] =
            localization[key] as String?;
      }
    }
  }

  @override
  String? get codeSample =>
      LogService.code('get generate locales translations \n'
          'get generate locales translations on core');

  @override
  int get maxParameters => 1;

  Future<String> _defaultInputDirectory() async {
    const repoTranslations = 'translations';
    if (await Directory(repoTranslations).exists()) {
      return repoTranslations;
    }

    return 'assets/locales';
  }
}

String _replaceValue(String value) {
  return value
      .replaceAll("'", "\\'")
      .replaceAll('\n', '\\n')
      .replaceAll('\$', '\\\$');
}
