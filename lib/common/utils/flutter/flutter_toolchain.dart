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
  final String constraint;
  final bool isDev;

  const FlutterInitDependencySpec(
    this.package, {
    required this.constraint,
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

  bool supportsPackage(String package) {
    return allDependencies.any((dependency) => dependency.package == package);
  }

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
      FlutterInitDependencySpec('dio', constraint: '^4.0.6'),
      FlutterInitDependencySpec('drift', constraint: '^2.0.0'),
      FlutterInitDependencySpec('json_annotation', constraint: '^4.7.0'),
      FlutterInitDependencySpec('path_provider', constraint: '^2.1.2'),
      FlutterInitDependencySpec('retrofit', constraint: '^3.3.1'),
      FlutterInitDependencySpec('sqlite3_flutter_libs', constraint: '^0.5.20'),
    ],
    devDependencies: [
      FlutterInitDependencySpec(
        'build_runner',
        constraint: '^2.3.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'drift_dev',
        constraint: '^2.0.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'json_serializable',
        constraint: '^6.5.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'retrofit_generator',
        constraint: '^4.2.0',
        isDev: true,
      ),
    ],
  );

  static const _transitionalBundle = FlutterInitDependencyBundle(
    name: 'transitional',
    dependencies: [
      FlutterInitDependencySpec('dio', constraint: '^5.1.0'),
      FlutterInitDependencySpec('drift', constraint: '^2.10.0'),
      FlutterInitDependencySpec('json_annotation', constraint: '^4.8.0'),
      FlutterInitDependencySpec('langchain', constraint: '>=0.5.0 <0.6.0'),
      FlutterInitDependencySpec(
        'langchain_openai',
        constraint: '>=0.5.0 <0.6.0',
      ),
      FlutterInitDependencySpec('path_provider', constraint: '^2.1.2'),
      FlutterInitDependencySpec('retrofit', constraint: '^4.0.0'),
      FlutterInitDependencySpec('sqlite3_flutter_libs', constraint: '^0.5.20'),
    ],
    devDependencies: [
      FlutterInitDependencySpec(
        'build_runner',
        constraint: '^2.4.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'drift_dev',
        constraint: '^2.10.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'json_serializable',
        constraint: '^6.6.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'retrofit_generator',
        constraint: '^7.0.0',
        isDev: true,
      ),
    ],
  );

  static const _modernBundle = FlutterInitDependencyBundle(
    name: 'modern',
    dependencies: [
      FlutterInitDependencySpec('dio', constraint: '^5.3.0'),
      FlutterInitDependencySpec('drift', constraint: '^2.20.0'),
      FlutterInitDependencySpec('json_annotation', constraint: '^4.8.1'),
      FlutterInitDependencySpec('langchain', constraint: '>=0.6.0 <0.7.0'),
      FlutterInitDependencySpec(
        'langchain_openai',
        constraint: '>=0.5.0 <0.6.0',
      ),
      FlutterInitDependencySpec('path_provider', constraint: '^2.1.2'),
      FlutterInitDependencySpec('retrofit', constraint: '^4.5.0'),
      FlutterInitDependencySpec('sqlite3_flutter_libs', constraint: '^0.5.20'),
    ],
    devDependencies: [
      FlutterInitDependencySpec(
        'build_runner',
        constraint: '^2.4.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'drift_dev',
        constraint: '^2.20.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'json_serializable',
        constraint: '^6.7.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'retrofit_generator',
        constraint: '^9.0.0',
        isDev: true,
      ),
    ],
  );

  static const _latestBundle = FlutterInitDependencyBundle(
    name: 'latest',
    dependencies: [
      FlutterInitDependencySpec('dio', constraint: '^5.4.0'),
      FlutterInitDependencySpec('drift', constraint: '^2.24.0'),
      FlutterInitDependencySpec('json_annotation', constraint: '^4.9.0'),
      FlutterInitDependencySpec('langchain', constraint: '>=0.7.0 <0.8.0'),
      FlutterInitDependencySpec(
        'langchain_openai',
        constraint: '>=0.7.0 <0.8.0',
      ),
      FlutterInitDependencySpec('path_provider', constraint: '^2.1.2'),
      FlutterInitDependencySpec('retrofit', constraint: '^4.9.0'),
      FlutterInitDependencySpec('sqlite3_flutter_libs', constraint: '^0.5.20'),
    ],
    devDependencies: [
      FlutterInitDependencySpec(
        'build_runner',
        constraint: '^2.6.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'drift_dev',
        constraint: '^2.24.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'json_serializable',
        constraint: '^6.10.0',
        isDev: true,
      ),
      FlutterInitDependencySpec(
        'retrofit_generator',
        constraint: '^10.0.0',
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
    if (flutterVersion >= Version.parse('3.22.0')) {
      return _transitionalBundle;
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
    if (dartVersion >= Version.parse('3.0.0')) {
      return _transitionalBundle;
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
        return 3;
      case 'modern':
        return 2;
      case 'transitional':
        return 1;
      case 'legacy':
      default:
        return 0;
    }
  }
}
