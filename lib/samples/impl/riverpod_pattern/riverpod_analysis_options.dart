import '../../interface/sample_interface.dart';
import '../../../common/utils/flutter/riverpod_lint_setup.dart';

/// Riverpod Pattern 架构的 [analysis_options.yaml] 模板。
/// 内容由 [RiverpodLintSetup] 按已安装的 riverpod_lint 主版本决定：
/// 3.x 使用 analysis_server_plugin，早期版本使用 custom_lint。
class RiverpodAnalysisOptionsSample extends Sample {
  final String riverpodLintConstraint;

  RiverpodAnalysisOptionsSample({required this.riverpodLintConstraint})
      : super('analysis_options.yaml');

  @override
  String get content =>
      RiverpodLintSetup.analysisOptionsContent(riverpodLintConstraint);
}
