import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('unknown command exits with code 1', () async {
    final result = await _runCli(['wat']);

    expect(result.exitCode, 1);
    expect(result.stdout, contains('command not found'));
  });

  test('remove without package exits with code 1', () async {
    final result = await _runCli(['remove']);

    expect(result.exitCode, 1);
    expect(result.stdout, contains('Enter the name of the package'));
  });

  test('missing locales directory exits with code 1', () async {
    final result = await _runCli(['generate', 'locales', 'does-not-exist']);

    expect(result.exitCode, 1);
    expect(result.stdout, contains('does-not-exist directory does not exist'));
  });
}

Future<ProcessResult> _runCli(List<String> arguments) {
  return Process.run(
    Platform.resolvedExecutable,
    ['run', 'bin/get.dart', ...arguments],
    workingDirectory: Directory.current.path,
  );
}
