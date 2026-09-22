import '../../menu/menu.dart';
import 'flutter_toolchain.dart';

/// 各架构初始化流程可复用的可选集成特性。
enum FlutterInitFeature {
  drift,
  jsonSerializable,
  langChain,
  retrofit,
}

/// 单个可选集成在菜单中的展示项。
class FlutterInitFeatureOption {
  final FlutterInitFeature feature;
  final String label;

  const FlutterInitFeatureOption(this.feature, this.label);
}

const List<FlutterInitFeatureOption> flutterInitFeatureOptions = [
  FlutterInitFeatureOption(
    FlutterInitFeature.drift,
    'Drift database (drift, drift_dev, sqlite3_flutter_libs, path_provider)',
  ),
  FlutterInitFeatureOption(
    FlutterInitFeature.jsonSerializable,
    'JSON serialization (json_annotation, json_serializable)',
  ),
  FlutterInitFeatureOption(
    FlutterInitFeature.langChain,
    'LangChain AI agent (langchain, langchain_openai)',
  ),
  FlutterInitFeatureOption(
    FlutterInitFeature.retrofit,
    'Retrofit HTTP (dio, retrofit, retrofit_generator)',
  ),
];

/// 可选集成的公共选择与安装辅助逻辑。
/// 从 GetX Pattern 初始化流程提取，供 Signals Pattern 等其他架构复用。
class FlutterInitFeatures {
  FlutterInitFeatures._();

  /// 弹出多选菜单；仅展示当前工具链依赖约束支持的选项，
  /// [initiallySelectAll] 控制各架构默认预选策略。
  static Set<FlutterInitFeature> ask(
    FlutterInitDependencyBundle dependencyBundle, {
    required bool initiallySelectAll,
  }) {
    final availableOptions = flutterInitFeatureOptions
        .where(
          (option) => supportsFeature(dependencyBundle, option.feature),
        )
        .toList();

    final answer = MultiSelectMenu(
      availableOptions.map((option) => option.label).toList(),
      title: 'Select optional integrations',
      description: 'Use ↑/↓ to move, Space to toggle, Enter to confirm.',
      initiallySelectedIndexes: initiallySelectAll
          ? List<int>.generate(
              availableOptions.length,
              (index) => index,
            )
          : const <int>[],
    ).choose();

    return answer.indexes.map((index) => availableOptions[index].feature).toSet();
  }

  /// 判断依赖约束包是否覆盖该特性所需的全部包。
  static bool supportsFeature(
    FlutterInitDependencyBundle dependencyBundle,
    FlutterInitFeature feature,
  ) {
    for (final package in packagesForFeature(feature)) {
      if (!dependencyBundle.supportsPackage(package)) {
        return false;
      }
    }

    return true;
  }

  /// 按选中的特性解析待安装依赖；跨特性共享的包只保留一份。
  static List<FlutterInitDependencySpec> resolveSelectedDependencies(
    FlutterInitDependencyBundle dependencyBundle,
    Set<FlutterInitFeature> selectedFeatures,
  ) {
    final dependenciesByPackage = <String, FlutterInitDependencySpec>{};

    for (final feature in selectedFeatures) {
      for (final package in packagesForFeature(feature)) {
        dependenciesByPackage[package] = dependencyBundle.dependency(package);
      }
    }

    return dependenciesByPackage.values.toList();
  }

  static bool shouldRunBuildRunner(Set<FlutterInitFeature> selectedFeatures) {
    for (final feature in selectedFeatures) {
      if (usesBuildRunner(feature)) {
        return true;
      }
    }

    return false;
  }

  static bool usesBuildRunner(FlutterInitFeature feature) {
    switch (feature) {
      case FlutterInitFeature.drift:
      case FlutterInitFeature.jsonSerializable:
      case FlutterInitFeature.retrofit:
        return true;
      case FlutterInitFeature.langChain:
        return false;
    }
  }

  static Iterable<String> packagesForFeature(FlutterInitFeature feature) sync* {
    if (feature == FlutterInitFeature.drift) {
      yield 'build_runner';
      yield 'drift';
      yield 'drift_dev';
      yield 'path_provider';
      yield 'sqlite3_flutter_libs';
    }

    if (feature == FlutterInitFeature.retrofit) {
      yield 'build_runner';
      yield 'dio';
      yield 'retrofit';
      yield 'retrofit_generator';
    }

    if (feature == FlutterInitFeature.jsonSerializable) {
      yield 'build_runner';
      yield 'json_annotation';
      yield 'json_serializable';
    }

    if (feature == FlutterInitFeature.langChain) {
      yield 'langchain';
      yield 'langchain_openai';
    }
  }
}
