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
      FlutterInitDependencySpec('langchain', version: '0.7.4'),
      FlutterInitDependencySpec('langchain_openai', version: '0.7.0'),
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
        version: '8.1.2',
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
      FlutterInitDependencySpec('langchain', version: '0.7.7+2'),
      FlutterInitDependencySpec('langchain_openai', version: '0.7.3'),
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
        version: '8.1.2',
        isDev: true,
      ),
    ],
  );

  static const _latestBundle = FlutterInitDependencyBundle(
    name: 'latest',
    dependencies: [
      FlutterInitDependencySpec('dio', version: '5.9.2'),
      FlutterInitDependencySpec('drift', version: '2.32.0'),
      FlutterInitDependencySpec('json_annotation', version: '4.9.0'),
      FlutterInitDependencySpec('langchain', version: '0.8.1'),
      FlutterInitDependencySpec('langchain_openai', version: '0.8.1+1'),
      FlutterInitDependencySpec('path_provider', version: '2.1.4'),
      FlutterInitDependencySpec('retrofit', version: '4.9.2'),
      FlutterInitDependencySpec('sqlite3_flutter_libs', version: '0.5.42'),
    ],
    devDependencies: [
      FlutterInitDependencySpec(
        'build_runner',
        version: '2.13.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'drift_dev',
        version: '2.32.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'json_serializable',
        version: '6.9.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'retrofit_generator',
        version: '10.2.3',
        isDev: true,
      ),
    ],
  );

  static FlutterInitDependencyBundle resolve(FlutterToolchainInfo? toolchain) {
    final flutterBundle = _resolveFromFlutterVersion(toolchain?.flutterVersion);
    final dartBundle = _resolveFromDartVersion(toolchain?.dartVersion);

    if (flutterBundle != null && dartBundle != null) {
      return _minBundle(flutterBundle, dartBundle);
    }

    return flutterBundle ?? dartBundle ?? _legacyBundle;
  }

  static FlutterInitDependencyBundle? _resolveFromFlutterVersion(
    Version? flutterVersion,
  ) {
    if (flutterVersion == null) {
      return null;
    }

    if (flutterVersion >= Version.parse('3.32.0')) {
      return _latestBundle;
    }
    if (flutterVersion >= Version.parse('3.24.0')) {
      return _modernBundle;
    }

    return _legacyBundle;
  }

  static FlutterInitDependencyBundle? _resolveFromDartVersion(
    Version? dartVersion,
  ) {
    if (dartVersion == null) {
      return null;
    }

    if (dartVersion >= Version.parse('3.8.0')) {
      return _latestBundle;
    }
    if (dartVersion >= Version.parse('3.5.0')) {
      return _modernBundle;
    }

    return _legacyBundle;
  }

  static FlutterInitDependencyBundle _minBundle(
    FlutterInitDependencyBundle left,
    FlutterInitDependencyBundle right,
  ) {
    final leftRank = _bundleRank(left);
    final rightRank = _bundleRank(right);
    return leftRank <= rightRank ? left : right;
  }

  static int _bundleRank(FlutterInitDependencyBundle bundle) {
    switch (bundle.name) {
      case 'latest':
        return 2;
      case 'modern':
        return 1;
      case 'legacy':
      default:
        return 0;
    }
  }
}
