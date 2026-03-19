import 'dart:io';

import '../../common/menu/menu.dart';
import '../../common/utils/logger/log_utils.dart';
import '../../core/internationalization.dart';
import '../../core/locales.g.dart';
import '../../core/structure.dart';

Future<bool> createMain() async {
  var newFileModel = Structure.model('', 'init', false);

  var main = File('${newFileModel.path}main.dart');

  if (main.existsSync()) {
    /// apenas quem chama essa função é o create project e o init,
    /// ambas funções iniciam um projeto e sobrescreve os arquivos

    final promptLines = LocaleKeys.ask_lib_not_empty.tr
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final promptDescription = promptLines.length > 1
        ? _normalizePromptDescription(promptLines.skip(1).join(' '))
        : null;
    final menu = Menu([LocaleKeys.options_yes.tr, LocaleKeys.options_no.tr],
        title: promptLines.isNotEmpty ? promptLines.first : '',
        description: promptDescription,
        descriptionPrefix: '! ',
        emphasizeDescription: true,
        selectedPrefix: '›',
        unselectedPrefix: ' ');
    final result = menu.choose();
    if (result.index == 1) {
      LogService.info(LocaleKeys.info_no_file_overwritten.tr);
      return false;
    }
    await Directory('lib/').delete(recursive: true);
  }
  return true;
}

String _normalizePromptDescription(String value) {
  return value
      .replaceAllMapped(
        RegExp(r'([:：])(?=\S)'),
        (match) => '${match.group(1)} ',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
