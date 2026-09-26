import 'package:get_cli/common/utils/flutter/riverpod_lint_setup.dart';
import 'package:test/test.dart';

void main() {
  test('riverpod_lint 3.x uses the analysis_server_plugin configuration', () {
    expect(RiverpodLintSetup.usesAnalysisServerPlugin('^3.1.9'), isTrue);

    final content = RiverpodLintSetup.analysisOptionsContent('^3.1.9');
    expect(content, contains('plugins:'));
    expect(content, contains('riverpod_lint: ^3.1.9'));
    expect(content, isNot(contains('custom_lint')));
  });

  test('riverpod_lint 2.x requires custom_lint', () {
    expect(RiverpodLintSetup.usesAnalysisServerPlugin('^2.6.1'), isFalse);

    final content = RiverpodLintSetup.analysisOptionsContent('^2.6.1');
    expect(content, contains('analyzer:'));
    expect(content, contains('- custom_lint'));
    expect(content, isNot(contains('riverpod_lint:')));
  });

  test('version resolution handles ranges, bare versions and junk', () {
    expect(RiverpodLintSetup.resolveMajorVersion('>=3.0.0 <4.0.0'), equals(3));
    expect(RiverpodLintSetup.resolveMajorVersion('3.1.9'), equals(3));
    expect(RiverpodLintSetup.resolveMajorVersion('^10.0.0'), equals(10));
    expect(RiverpodLintSetup.resolveMajorVersion(''), isNull);
  });

  /// flutter create 生成的工程自带 analysis_options.yaml，
  /// 合并时必须保留原有 include 等配置。
  test('merge appends plugins into an existing flutter_lints config', () {
    const existing = 'include: package:flutter_lints/flutter.yaml\n\n'
        'linter:\n  rules:\n    avoid_print: false\n';

    final merged = RiverpodLintSetup.mergeIntoExisting(existing, '^3.1.9');

    expect(merged, isNotNull);
    expect(merged, contains('include: package:flutter_lints/flutter.yaml'));
    expect(merged, contains('plugins:\n  riverpod_lint: ^3.1.9'));
  });

  test('merge appends custom_lint analyzer block for riverpod_lint 2.x', () {
    const existing = 'include: package:flutter_lints/flutter.yaml\n';

    final merged = RiverpodLintSetup.mergeIntoExisting(existing, '^2.6.1');

    expect(merged, isNotNull);
    expect(merged, contains('analyzer:\n  plugins:\n    - custom_lint'));
  });

  test('merge refuses configs that already declare related plugins', () {
    expect(
      RiverpodLintSetup.mergeIntoExisting('plugins:\n  other_lint: ^1.0.0\n',
          '^3.1.9'),
      isNull,
    );
    expect(
      RiverpodLintSetup.mergeIntoExisting(
          'plugins:\n  riverpod_lint: ^3.1.9\n', '^3.1.9'),
      isNull,
    );
    expect(
      RiverpodLintSetup.mergeIntoExisting('analyzer:\n  errors:\n', '^2.6.1'),
      isNull,
    );
  });
}
