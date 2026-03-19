import 'dart:convert';

import 'package:pub_semver/pub_semver.dart';

class FlutterToolchainInfo {
  final Version? flutterVersion;
  final Version? dartVersion;
  final String? channel;

  const FlutterToolchainInfo({
    this.flutterVersion,
    this.dartVersion,
    this.channel,
  });

  factory FlutterToolchainInfo.fromMachineJson(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return FlutterToolchainInfo(
      flutterVersion: parseVersion(
        json['frameworkVersion'] as String? ??
            json['flutterVersion'] as String?,
      ),
      dartVersion: parseVersion(json['dartSdkVersion'] as String?),
      channel: json['channel'] as String?,
    );
  }

  static Version? parseVersion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final match =
        RegExp(r'\d+\.\d+\.\d+(?:[-+][0-9A-Za-z\.-]+)?').firstMatch(value);
    if (match == null) {
      return null;
    }

    try {
      return Version.parse(match.group(0)!);
    } on FormatException {
      return null;
    }
  }
}

class FlutterInitDependencySpec {
  final String package;
  final String version;
  final bool isDev;

  const FlutterInitDependencySpec(
    this.package, {
    required this.version,
    this.isDev = false,
  });
}

class FlutterInitDependencyBundle {
  final String name;
  final List<FlutterInitDependencySpec> dependencies;
  final List<FlutterInitDependencySpec> devDependencies;

  const FlutterInitDependencyBundle({
    required this.name,
    required this.dependencies,
    required this.devDependencies,
  });

  List<FlutterInitDependencySpec> get allDependencies => [
        ...dependencies,
        ...devDependencies,
      ];

  FlutterInitDependencySpec dependency(String package) {
    for (final dependency in allDependencies) {
      if (dependency.package == package) {
        return dependency;
      }
    }

    throw StateError('Dependency $package not found in bundle $name');
  }
}

class FlutterInitDependencyResolver {
  static const _legacyBundle = FlutterInitDependencyBundle(
    name: 'legacy',
    dependencies: [
      FlutterInitDependencySpec('dio', version: '5.9.2'),
      FlutterInitDependencySpec('drift', version: '2.20.3'),
      FlutterInitDependencySpec('json_annotation', version: '4.9.0'),
      FlutterInitDependencySpec('path_provider', version: '2.1.4'),
      FlutterInitDependencySpec('retrofit', version: '4.5.0'),
      FlutterInitDependencySpec('sqlite3_flutter_libs', version: '0.5.42'),
    ],
    devDependencies: [
      FlutterInitDependencySpec(
        'build_runner',
        version: '2.4.9',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'drift_dev',
        version: '2.20.3',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'json_serializable',
        version: '6.8.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'retrofit_generator',
        version: '9.3.0',
        isDev: true,
      ),
    ],
  );

  static const _modernBundle = FlutterInitDependencyBundle(
    name: 'modern',
    dependencies: [
      FlutterInitDependencySpec('dio', version: '5.9.2'),
      FlutterInitDependencySpec('drift', version: '2.22.1'),
      FlutterInitDependencySpec('json_annotation', version: '4.9.0'),
      FlutterInitDependencySpec('path_provider', version: '2.1.4'),
      FlutterInitDependencySpec('retrofit', version: '4.5.0'),
      FlutterInitDependencySpec('sqlite3_flutter_libs', version: '0.5.42'),
    ],
    devDependencies: [
      FlutterInitDependencySpec(
        'build_runner',
        version: '2.4.9',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'drift_dev',
        version: '2.22.1',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'json_serializable',
        version: '6.9.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'retrofit_generator',
        version: '9.3.0',
        isDev: true,
      ),
    ],
  );

  static FlutterInitDependencyBundle resolve(FlutterToolchainInfo? toolchain) {
    final dartVersion = toolchain?.dartVersion;
    if (dartVersion != null && dartVersion >= Version.parse('3.5.0')) {
      return _modernBundle;
    }

    return _legacyBundle;
  }
}
