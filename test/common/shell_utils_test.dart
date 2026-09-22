import 'dart:io';

import 'package:get_cli/common/utils/shell/shel.utils.dart';
import 'package:path/path.dart' as p;
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

  test('returns dart run build_runner command', () {
    expect(
      ShellUtils.resolveBuildRunnerCommand(),
      equals('dart run build_runner build --delete-conflicting-outputs'),
    );
  });

  test('resolves a directly executable dart binary', () {
    // 测试本身由 dart 运行，因此应能解析出可直调的真实 dart 可执行文件
    final dartExecutable = ShellUtils.resolveDartExecutable();

    expect(dartExecutable, isNotNull);
    expect(File(dartExecutable!).existsSync(), isTrue);
    expect(
      p.basenameWithoutExtension(dartExecutable).toLowerCase(),
      equals('dart'),
    );
  });

  test('builds one pub add command for multiple packages', () {
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
      ShellUtils.resolveAddPackagesCommand(
        [
          'dio:>=5.9.2 <6.0.0',
          'dev:build_runner:>=2.4.13 <2.7.0',
        ],
        flutterPubspec,
      ),
      equals(
        'flutter pub add "dio:>=5.9.2 <6.0.0" '
        '"dev:build_runner:>=2.4.13 <2.7.0"',
      ),
    );
  });
}
