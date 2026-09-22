import 'package:get_cli/common/utils/flutter/flutter_init_features.dart';
import 'package:get_cli/common/utils/flutter/flutter_toolchain.dart';
import 'package:test/test.dart';

void main() {
  /// 工具链不可解析时的回退包，与初始化流程实际使用的回退逻辑一致。
  final bundle = FlutterInitDependencyResolver.resolve(null);

  test('unresolvable toolchain falls back to legacy bundle', () {
    expect(bundle.name, 'legacy');
  });

  test('legacy bundle covers drift, json and retrofit but not langchain', () {
    expect(
      FlutterInitFeatures.supportsFeature(bundle, FlutterInitFeature.drift),
      isTrue,
    );
    expect(
      FlutterInitFeatures.supportsFeature(
        bundle,
        FlutterInitFeature.jsonSerializable,
      ),
      isTrue,
    );
    expect(
      FlutterInitFeatures.supportsFeature(bundle, FlutterInitFeature.retrofit),
      isTrue,
    );
    expect(
      FlutterInitFeatures.supportsFeature(bundle, FlutterInitFeature.langChain),
      isFalse,
    );
  });

  test('selected dependencies deduplicate packages shared across features',
      () {
    final dependencies = FlutterInitFeatures.resolveSelectedDependencies(
      bundle,
      {FlutterInitFeature.drift, FlutterInitFeature.retrofit},
    );
    final packages = dependencies.map((d) => d.package).toList();

    expect(packages.where((package) => package == 'build_runner'), hasLength(1));
    expect(packages, containsAll(['drift', 'drift_dev', 'dio', 'retrofit']));
  });

  test('build runner only required for code generation features', () {
    expect(
      FlutterInitFeatures.shouldRunBuildRunner({FlutterInitFeature.drift}),
      isTrue,
    );
    expect(
      FlutterInitFeatures.shouldRunBuildRunner({FlutterInitFeature.langChain}),
      isFalse,
    );
    expect(
      FlutterInitFeatures.shouldRunBuildRunner(<FlutterInitFeature>{}),
      isFalse,
    );
  });
}
