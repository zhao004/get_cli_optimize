import 'package:pub_semver/pub_semver.dart';

/// riverpod_lint 配置生成辅助。
/// riverpod_lint 3.x 起改用 analysis_server_plugin 机制，只需在
/// analysis_options.yaml 顶层声明 `plugins`，不再依赖 custom_lint；
/// 更早版本通过 custom_lint 的 analyzer 插件入口加载。
/// 这里按已安装版本的主版本号选择对应配置。
class RiverpodLintSetup {
  RiverpodLintSetup._();

  /// 是否为 riverpod_lint 3.x 及以上的 analysis_server_plugin 配置方式。
  static bool usesAnalysisServerPlugin(String constraint) {
    final major = resolveMajorVersion(constraint);
    return major != null && major >= 3;
  }

  /// 生成 analysis_options.yaml 内容。
  static String analysisOptionsContent(String constraint) {
    if (usesAnalysisServerPlugin(constraint)) {
      return '''
plugins:
  riverpod_lint: ${constraint.trim()}
''';
    }

    return '''
analyzer:
  plugins:
    - custom_lint
''';
  }

  /// 将 riverpod_lint 配置合并进已有的 analysis_options.yaml。
  /// 返回 null 表示已有相关配置或存在无法安全合并的顶层键，
  /// 需要用户手动处理。
  static String? mergeIntoExisting(String content, String constraint) {
    if (content.contains('riverpod_lint') || content.contains('custom_lint')) {
      return null;
    }

    final trimmed = content.trimRight();
    if (usesAnalysisServerPlugin(constraint)) {
      if (RegExp(r'^plugins:', multiLine: true).hasMatch(content)) {
        return null;
      }
      return '$trimmed\n\nplugins:\n'
          '  riverpod_lint: ${constraint.trim()}\n';
    }

    if (RegExp(r'^analyzer:', multiLine: true).hasMatch(content)) {
      return null;
    }
    return '$trimmed\n\nanalyzer:\n'
        '  plugins:\n'
        '    - custom_lint\n';
  }

  /// 从 pub 写入的约束（如 `^3.1.9`、`>=3.0.0 <4.0.0`、`3.1.9`）解析主版本。
  static int? resolveMajorVersion(String constraint) {
    final trimmed = constraint.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final parsed = VersionConstraint.parse(trimmed);
      if (parsed is VersionRange && parsed.min != null) {
        return parsed.min!.major;
      }
      if (parsed is Version) {
        return parsed.major;
      }
    } on FormatException {
      // 回退到字符串解析
    }

    final match = RegExp(r'\d+').firstMatch(trimmed);
    return match == null ? null : int.tryParse(match.group(0)!);
  }
}
