import 'package:get_cli/common/utils/shell/shel.utils.dart';
import 'package:test/test.dart';

void main() {
  test('uses flutter pub for flutter projects', () {
    const flutterPubspec = '''
name: flutter_project
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
flutter:
  uses-material-design: true
''';

    expect(ShellUtils.resolvePubCommand(flutterPubspec), equals('flutter pub'));
  });

  test('uses dart pub for pure dart projects', () {
    const dartPubspec = '''
name: dart_project
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  args: 2.5.0
''';

    expect(ShellUtils.resolvePubCommand(dartPubspec), equals('dart pub'));
  });

  test('uses flutter build_runner command for flutter projects', () {
    const flutterPubspec = '''
name: flutter_project
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
flutter:
  uses-material-design: true
''';

    expect(
      ShellUtils.resolveBuildRunnerCommand(flutterPubspec),
      equals('flutter pub run build_runner build '
          '--delete-conflicting-outputs'),
    );
  });

  test('uses dart build_runner command for pure dart projects', () {
    const dartPubspec = '''
name: dart_project
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  args: 2.5.0
''';

    expect(
      ShellUtils.resolveBuildRunnerCommand(dartPubspec),
      equals('dart run build_runner build --delete-conflicting-outputs'),
    );
  });
}
