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

  test('uses legacy bundle for older dart sdk versions', () {
    const toolchain = FlutterToolchainInfo(
      dartVersion: null,
    );
    final bundle = FlutterInitDependencyResolver.resolve(toolchain);

    expect(bundle.name, equals('legacy'));
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'drift')
          .version,
      equals('2.20.3'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .version,
      equals('2.20.3'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'json_annotation')
          .version,
      equals('4.9.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain')
          .version,
      equals('0.7.4'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain_openai')
          .version,
      equals('0.7.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'json_serializable')
          .version,
      equals('6.8.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere(
            (dependency) => dependency.package == 'retrofit_generator',
          )
          .version,
      equals('8.1.2'),
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
          .version,
      equals('0.7.7+2'),
    );
  });

  test('uses modern bundle for dart 3.5 and newer', () {
    final bundle = FlutterInitDependencyResolver.resolve(
      const FlutterToolchainInfo(
        dartVersion: null,
      ),
    );

    expect(bundle.name, equals('legacy'));

    final modernBundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        dartVersion: FlutterToolchainInfo.parseVersion('3.5.0'),
      ),
    );

    expect(modernBundle.name, equals('modern'));
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'drift')
          .version,
      equals('2.22.1'),
    );
    expect(
      modernBundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .version,
      equals('2.22.1'),
    );
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'json_annotation')
          .version,
      equals('4.9.0'),
    );
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain')
          .version,
      equals('0.7.7+2'),
    );
    expect(
      modernBundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain_openai')
          .version,
      equals('0.7.3'),
    );
    expect(
      modernBundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'json_serializable')
          .version,
      equals('6.9.0'),
    );
    expect(
      modernBundle.devDependencies
          .firstWhere(
            (dependency) => dependency.package == 'retrofit_generator',
          )
          .version,
      equals('8.1.2'),
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
          .version,
      equals('2.32.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .version,
      equals('2.32.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain')
          .version,
      equals('0.8.1'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain_openai')
          .version,
      equals('0.8.1+1'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'retrofit')
          .version,
      equals('4.9.2'),
    );
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'build_runner')
          .version,
      equals('2.13.0'),
    );
    expect(
      bundle.devDependencies
          .firstWhere(
            (dependency) => dependency.package == 'retrofit_generator',
          )
          .version,
      equals('10.2.3'),
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
          .version,
      equals('2.32.0'),
    );
    expect(
      bundle.dependencies
          .firstWhere((dependency) => dependency.package == 'langchain_openai')
          .version,
      equals('0.8.1+1'),
    );
  });

  test('prefers the more conservative bundle when versions conflict', () {
    final bundle = FlutterInitDependencyResolver.resolve(
      FlutterToolchainInfo(
        flutterVersion: FlutterToolchainInfo.parseVersion('3.32.0'),
        dartVersion: FlutterToolchainInfo.parseVersion('3.4.4'),
      ),
    );

    expect(bundle.name, equals('legacy'));
    expect(
      bundle.devDependencies
          .firstWhere((dependency) => dependency.package == 'drift_dev')
          .version,
      equals('2.20.3'),
    );
  });
}
