import 'dart:io';

import 'package:dart_console/dart_console.dart';

class PromptUtils {
  static String ask(
    String prompt, {
    String? defaultValue,
  }) {
    final console = Console();
    if (console.hasTerminal) {
      console.rawMode = false;
      console.resetColorAttributes();
      console.showCursor();
    }

    final promptSuffix = defaultValue == null || defaultValue.isEmpty
        ? ' '
        : ' [$defaultValue] ';
    stdout.write('$prompt$promptSuffix');
    stdout.flush();

    try {
      final rawValue = stdin.readLineSync()?.trim() ?? '';
      if (rawValue.isEmpty) {
        return defaultValue ?? '';
      }
      return rawValue;
    } on StdinException {
      return defaultValue ?? '';
    }
  }
}
