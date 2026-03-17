import 'dart:convert';
import 'dart:io';

import 'package:get_cli/core/locales.g.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  test('generated locales register every translation file', () {
    final localeFiles = Directory('translations')
        .listSync()
        .whereType<File>()
        .where((file) => path.extension(file.path) == '.json')
        .map((file) => path.basenameWithoutExtension(file.path))
        .toSet();

    expect(AppTranslation.translations.keys.toSet(), equals(localeFiles));
  });

  test('all translation files expose the same flattened keys', () {
    final englishKeys = _readFlattenedTranslationKeys('translations/en.json');
    final translationFiles = Directory('translations')
        .listSync()
        .whereType<File>()
        .where((file) => path.extension(file.path) == '.json');

    for (final file in translationFiles) {
      expect(
        _readFlattenedTranslationKeys(file.path),
        equals(englishKeys),
        reason: '${path.basename(file.path)} is out of sync with en.json',
      );
    }
  });
}

Set<String> _readFlattenedTranslationKeys(String filePath) {
  final content = File(filePath).readAsStringSync();
  final json = jsonDecode(content) as Map<String, dynamic>;
  final flattened = <String>{};

  _flatten(json, flattened);

  return flattened;
}

void _flatten(
  Map<String, dynamic> value,
  Set<String> flattened, [
  String? prefix,
]) {
  final keys = value.keys.toList()..sort();
  for (final key in keys) {
    final nextKey = prefix == null ? key : '${prefix}_$key';
    final nextValue = value[key];
    if (nextValue is Map<String, dynamic>) {
      _flatten(nextValue, flattened, nextKey);
      continue;
    }

    flattened.add(nextKey);
  }
}
