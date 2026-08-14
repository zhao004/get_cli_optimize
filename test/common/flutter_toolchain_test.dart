import 'package:get_cli/common/utils/flutter/flutter_toolchain.dart';
import 'package:test/test.dart';

void main() {
  test('parses flutter machine output', () {
    const source = '''
{
  "frameworkVersion": "3.22.3",
  "channel": "stable",
  "dartSdkVersion": "3.4.4"
}
''';

    final toolchain = FlutterToolchainInfo.fromMachineJson(source);

    expect(toolchain.flutterVersion.toString(), equals('3.22.3'));
    expect(toolchain.dartVersion.toString(), equals('3.4.4'));
    expect(toolchain.channel, equals('stable'));
  });

  test('parses version tokens with extra labels', () {
    final version = FlutterToolchainInfo.parseVersion(
      '3.5.0 (stable) (Tue Jul 30 00:00:00 2024)',
    );

    expect(version.toString(), equals('3.5.0'));
  });

  test('falls back to legacy bundle when toolchain is unknown', () {
    const toolchain = FlutterToolchainInfo(
      dartVersion: null,
    );
    final bundle = FlutterInitDependencyResolver.resolve(toolchain);

    expect(bundle.name, equals('legacy'));
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'drift')
          .constraint,
      equals('^2.0.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .constraint,
      equals('^2.0.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'json_annotation')
          .constraint,
      equals('^4.7.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'json_serializable')
          .constraint,
      equals('^6.5.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere(
            (dependency) => dependency.package == 'retrofit_generator',
          )
          .constraint,
      equals('^4.2.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'dio')
          .constraint,
      equals('^4.0.6'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'retrofit')
          .constraint,
      equals('^3.3.1'),
    );
    expect(bundle.supportsPackage('langchain'), isFalse);
  });

  test('uses transitional bundle for Flutter 3.22 and newer', () {
    final bundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        flutterVersion: FlutterToolchainInfo.parseVersion('3.22.0'),
      ),
    );

    expect(bundle.name, equals('transitional'));
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain')
          .constraint,
      equals('>=0.5.0 <0.6.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'build_runner')
          .constraint,
      equals('^2.4.0'),
    );
  });

  test('uses modern bundle for Flutter 3.24 and newer', () {
    final bundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        flutterVersion: FlutterToolchainInfo.parseVersion('3.24.0'),
      ),
    );

    expect(bundle.name, equals('modern'));
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain')
          .constraint,
      equals('>=0.6.0 <0.7.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'build_runner')
          .constraint,
      equals('^2.4.0'),
    );
  });

  test('uses transitional bundle for dart 3.0 to 3.4', () {
    final legacyBundle = FlutterInitDependencyResolver.resolve(
      const FlutterToolchainInfo(
        dartVersion: null,
      ),
    );

    expect(legacyBundle.name, equals('legacy'));

    final transitionalBundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        dartVersion: FlutterToolchainInfo.parseVersion('3.0.0'),
      ),
    );

    expect(transitionalBundle.name, equals('transitional'));
    expect(
      transitionalBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'drift')
          .constraint,
      equals('^2.10.0'),
    );
    expect(
      transitionalBundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .constraint,
      equals('^2.10.0'),
    );
    expect(
      transitionalBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'json_annotation')
          .constraint,
      equals('^4.8.0'),
    );
    expect(
      transitionalBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain')
          .constraint,
      equals('>=0.5.0 <0.6.0'),
    );
    expect(
      transitionalBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain_openai')
          .constraint,
      equals('>=0.5.0 <0.6.0'),
    );
    expect(
      transitionalBundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'json_serializable')
          .constraint,
      equals('^6.6.0'),
    );
    expect(
      transitionalBundle.devDependencies
          .firstWhere(
            (dependency) => dependency.package == 'retrofit_generator',
          )
          .constraint,
      equals('^7.0.0'),
    );
  });

  test('uses modern bundle for dart 3.5 and newer', () {
    final modernBundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        dartVersion: FlutterToolchainInfo.parseVersion('3.5.0'),
      ),
    );

    expect(modernBundle.name, equals('modern'));
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'drift')
          .constraint,
      equals('^2.20.0'),
    );
    expect(
      modernBundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .constraint,
      equals('^2.20.0'),
    );
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'json_annotation')
          .constraint,
      equals('^4.8.1'),
    );
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain')
          .constraint,
      equals('>=0.6.0 <0.7.0'),
    );
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain_openai')
          .constraint,
      equals('>=0.5.0 <0.6.0'),
    );
    expect(
      modernBundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'json_serializable')
          .constraint,
      equals('^6.7.0'),
    );
    expect(
      modernBundle.devDependencies
          .firstWhere(
            (dependency) => dependency.package == 'retrofit_generator',
          )
          .constraint,
      equals('^9.0.0'),
    );
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'retrofit')
          .constraint,
      equals('^4.5.0'),
    );
    expect(
      modernBundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'build_runner')
          .constraint,
      equals('^2.4.0'),
    );
  });

  test('uses latest bundle for dart 3.8 and newer', () {
    final bundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        dartVersion: FlutterToolchainInfo.parseVersion('3.8.0'),
      ),
    );

    expect(bundle.name, equals('latest'));
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'drift')
          .constraint,
      equals('^2.24.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .constraint,
      equals('^2.24.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain')
          .constraint,
      equals('>=0.7.0 <0.8.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain_openai')
          .constraint,
      equals('>=0.7.0 <0.8.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'retrofit')
          .constraint,
      equals('^4.9.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'build_runner')
          .constraint,
      equals('^2.6.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'json_serializable')
          .constraint,
      equals('^6.10.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere(
            (dependency) => dependency.package == 'retrofit_generator',
          )
          .constraint,
      equals('^10.0.0'),
    );
  });

  test('uses latest bundle for Flutter 3.32 and newer', () {
    final bundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        flutterVersion: FlutterToolchainInfo.parseVersion('3.32.0'),
      ),
    );

    expect(bundle.name, equals('latest'));
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .constraint,
      equals('^2.24.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain_openai')
          .constraint,
      equals('>=0.7.0 <0.8.0'),
    );
  });

  test('prefers the more conservative bundle when versions conflict', () {
    final bundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        flutterVersion: FlutterToolchainInfo.parseVersion('3.32.0'),
        dartVersion: FlutterToolchainInfo.parseVersion('3.4.4'),
      ),
    );

    expect(bundle.name, equals('transitional'));
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .constraint,
      equals('^2.10.0'),
    );
  });
}
