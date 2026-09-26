import 'package:dart_console/dart_console.dart';
import 'package:meta/meta.dart';

/// 直接写入一行文本。
/// [Console.writeLine] 会按窗口宽度用空格补齐整行，导致复制菜单内容时
/// 行尾出现大量空白；菜单每次重绘都会清屏，无需补齐。
void _writeLine(Console console, String text) {
  console.write('$text${console.newLine}');
}

/// 生成单选菜单的选项行（含缩进与前缀，不含颜色）。
/// 选中与未选中前缀宽度一致时，两种状态的标签列保持对齐。
@visibleForTesting
String formatMenuChoiceLine(
  String label, {
  required bool selected,
  required String selectedPrefix,
  required String unselectedPrefix,
}) {
  return '  ${selected ? selectedPrefix : unselectedPrefix} $label';
}

/// 生成多选菜单的选项行（含缩进、光标与勾选框，不含颜色）。
@visibleForTesting
String formatMultiSelectChoiceLine(
  String label, {
  required bool highlighted,
  required bool checked,
}) {
  return '  ${highlighted ? '❯' : ' '} ${checked ? '[✓]' : '[ ]'} $label';
}

class Menu {
  final List<String> choices;
  final String title;
  final String? description;
  final String selectedPrefix;
  final String unselectedPrefix;
  final String descriptionPrefix;
  final bool emphasizeDescription;

  Menu(
    this.choices, {
    this.title = '',
    this.description,
    this.selectedPrefix = '❯',
    this.unselectedPrefix = ' ',
    this.descriptionPrefix = '',
    this.emphasizeDescription = false,
  });

  Answer choose() {
    if (choices.isEmpty) {
      throw StateError('Menu choices cannot be empty');
    }

    final console = Console();
    if (!console.hasTerminal) {
      return Answer(result: choices.first, index: 0);
    }

    final index = _ConsoleMenu(
      console,
      choices,
      title: title,
      description: description,
      selectedPrefix: selectedPrefix,
      unselectedPrefix: unselectedPrefix,
      descriptionPrefix: descriptionPrefix,
      emphasizeDescription: emphasizeDescription,
    ).chooseIndex();
    return Answer(result: choices[index], index: index);
  }
}

class MultiSelectMenu {
  final List<String> choices;
  final Set<int> selectedIndexes;
  final String title;
  final String? description;

  MultiSelectMenu(
    this.choices, {
    this.title = '',
    this.description,
    Iterable<int> initiallySelectedIndexes = const [],
  }) : selectedIndexes = initiallySelectedIndexes.toSet();

  MultiSelectAnswer choose() {
    final defaults = _normalizedSelectedIndexes();
    if (choices.isEmpty) {
      return const MultiSelectAnswer(results: [], indexes: []);
    }

    final console = Console();
    if (!console.hasTerminal) {
      return MultiSelectAnswer(
        results: defaults.map((index) => choices[index]).toList(),
        indexes: defaults,
      );
    }

    final indexes = _ConsoleMultiSelectMenu(
      console,
      choices,
      title: title,
      description: description,
      selectedIndexes: defaults.toSet(),
    ).chooseIndexes();

    return MultiSelectAnswer(
      results: indexes.map((index) => choices[index]).toList(),
      indexes: indexes,
    );
  }

  List<int> _normalizedSelectedIndexes() {
    final indexes = selectedIndexes
        .where((index) => index >= 0 && index < choices.length)
        .toList()
      ..sort();
    return indexes;
  }
}

class _ConsoleMenu {
  final Console console;
  final List<String> choices;
  final String title;
  final String? description;
  final String selectedPrefix;
  final String unselectedPrefix;
  final String descriptionPrefix;
  final bool emphasizeDescription;
  var _selectedIndex = 0;

  _ConsoleMenu(
    this.console,
    this.choices, {
    required this.title,
    required this.description,
    required this.selectedPrefix,
    required this.unselectedPrefix,
    required this.descriptionPrefix,
    required this.emphasizeDescription,
  });

  int chooseIndex() {
    _redraw();

    try {
      console.hideCursor();
      while (true) {
        final key = console.readKey();
        final handled = _handleControlKey(key);
        if (handled != null) {
          return handled;
        }
      }
    } finally {
      _restoreTerminal();
    }
  }

  int? _handleControlKey(Key key) {
    if (!key.isControl) {
      if (key.char == 'j' || key.char == 's') {
        _moveDown();
      } else if (key.char == 'k' || key.char == 'w') {
        _moveUp();
      }
      return null;
    }

    switch (key.controlChar) {
      case ControlCharacter.arrowUp:
        _moveUp();
      case ControlCharacter.arrowDown:
        _moveDown();
      case ControlCharacter.enter:
        return _selectedIndex;
      default:
        return null;
    }
    return null;
  }

  void _moveUp() {
    if (_selectedIndex == 0) {
      return;
    }
    _selectedIndex--;
    _redraw();
  }

  void _moveDown() {
    if (_selectedIndex >= choices.length - 1) {
      return;
    }
    _selectedIndex++;
    _redraw();
  }

  void _printHeader() {
    if (title.isNotEmpty) {
      console.setTextStyle(bold: true);
      console.setForegroundColor(ConsoleColor.brightWhite);
      _writeLine(console, title);
      console.resetColorAttributes();
    }
    if (description != null && description!.isNotEmpty) {
      if (emphasizeDescription) {
        console.setTextStyle(bold: true);
        console.setForegroundColor(ConsoleColor.brightYellow);
      }
      _writeLine(console, '$descriptionPrefix${description!}');
      console.resetColorAttributes();
    }
    if (title.isNotEmpty || (description != null && description!.isNotEmpty)) {
      _writeLine(console, '');
    }
  }

  void _redraw() {
    console.clearScreen();
    console.resetCursorPosition();
    _printHeader();
    _renderChoices();
  }

  void _renderChoices() {
    for (var i = 0; i < choices.length; i++) {
      final line = formatMenuChoiceLine(
        choices[i],
        selected: i == _selectedIndex,
        selectedPrefix: selectedPrefix,
        unselectedPrefix: unselectedPrefix,
      );
      if (i == _selectedIndex) {
        console.setTextStyle(bold: true);
        console.setForegroundColor(ConsoleColor.brightGreen);
        _writeLine(console, line);
        console.resetColorAttributes();
      } else {
        _writeLine(console, line);
      }
    }

    if (choices.length > 1) {
      console.setForegroundColor(ConsoleColor.brightBlack);
      _writeLine(console, '  ↑/↓ move · Enter confirm');
      console.resetColorAttributes();
    }
  }

  void _restoreTerminal() {
    console.rawMode = false;
    console.resetColorAttributes();
    console.showCursor();
    console.writeLine();
  }
}

class _ConsoleMultiSelectMenu {
  final Console console;
  final List<String> choices;
  final String title;
  final String? description;
  final Set<int> selectedIndexes;
  var _cursorIndex = 0;

  _ConsoleMultiSelectMenu(
    this.console,
    this.choices, {
    required this.title,
    required this.description,
    required this.selectedIndexes,
  });

  List<int> chooseIndexes() {
    _redraw();

    try {
      console.hideCursor();
      while (true) {
        final key = console.readKey();
        final handled = _handleControlKey(key);
        if (handled != null) {
          return handled;
        }
      }
    } finally {
      _restoreTerminal();
    }
  }

  List<int>? _handleControlKey(Key key) {
    if (!key.isControl) {
      if (key.char == 'j' || key.char == 's') {
        _moveDown();
      } else if (key.char == 'k' || key.char == 'w') {
        _moveUp();
      } else if (key.char == ' ') {
        _toggleCurrent();
      }
      return null;
    }

    switch (key.controlChar) {
      case ControlCharacter.arrowUp:
        _moveUp();
      case ControlCharacter.arrowDown:
        _moveDown();
      case ControlCharacter.enter:
        return selectedIndexes.toList()..sort();
      default:
        return null;
    }
    return null;
  }

  void _moveUp() {
    if (_cursorIndex == 0) {
      return;
    }
    _cursorIndex--;
    _redraw();
  }

  void _moveDown() {
    if (_cursorIndex >= choices.length - 1) {
      return;
    }
    _cursorIndex++;
    _redraw();
  }

  void _toggleCurrent() {
    if (selectedIndexes.contains(_cursorIndex)) {
      selectedIndexes.remove(_cursorIndex);
    } else {
      selectedIndexes.add(_cursorIndex);
    }
    _redraw();
  }

  void _printHeader() {
    if (title.isNotEmpty) {
      console.setTextStyle(bold: true);
      console.setForegroundColor(ConsoleColor.brightWhite);
      _writeLine(console, title);
      console.resetColorAttributes();
    }
    if (description != null && description!.isNotEmpty) {
      _writeLine(console, description!);
    }
    if (title.isNotEmpty || (description != null && description!.isNotEmpty)) {
      _writeLine(console, '');
    }
  }

  void _redraw() {
    console.clearScreen();
    console.resetCursorPosition();
    _printHeader();
    _renderChoices();
  }

  void _renderChoices() {
    for (var i = 0; i < choices.length; i++) {
      final line = formatMultiSelectChoiceLine(
        choices[i],
        highlighted: i == _cursorIndex,
        checked: selectedIndexes.contains(i),
      );
      if (i == _cursorIndex) {
        console.setTextStyle(bold: true);
        console.setForegroundColor(ConsoleColor.brightGreen);
        _writeLine(console, line);
        console.resetColorAttributes();
      } else {
        _writeLine(console, line);
      }
    }
  }

  void _restoreTerminal() {
    console.rawMode = false;
    console.resetColorAttributes();
    console.showCursor();
    console.writeLine();
  }
}

class Answer {
  final String result;
  final int index;

  const Answer({required this.result, required this.index});
}

class MultiSelectAnswer {
  final List<String> results;
  final List<int> indexes;

  const MultiSelectAnswer({required this.results, required this.indexes});
}
