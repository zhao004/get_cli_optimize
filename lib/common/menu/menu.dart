import 'package:dart_console/dart_console.dart';

class Menu {
  final List<String> choices;
  final String title;

  Menu(this.choices, {this.title = ''});

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
  var _selectedIndex = 0;

  _ConsoleMenu(
    this.console,
    this.choices, {
    required this.title,
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
      console.showCursor();
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
    console.writeLine();
    if (title.isNotEmpty) {
      console.writeLine(title);
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
      if (i == _selectedIndex) {
        console.setForegroundColor(ConsoleColor.brightGreen);
        console.writeLine('> ${choices[i]}');
        console.resetColorAttributes();
      } else {
        console.writeLine('  ${choices[i]}');
      }
    }
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
      console.showCursor();
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
    console.writeLine();
    if (title.isNotEmpty) {
      console.writeLine(title);
    }
    if (description != null && description!.isNotEmpty) {
      console.writeLine(description!);
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
      final marker = selectedIndexes.contains(i) ? '[√]' : '[ ]';
      final prefix = i == _cursorIndex ? '>' : ' ';
      final line = '$prefix $marker ${choices[i]}';
      if (i == _cursorIndex) {
        console.setForegroundColor(ConsoleColor.brightGreen);
        console.writeLine(line);
        console.resetColorAttributes();
      } else {
        console.writeLine(line);
      }
    }
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
