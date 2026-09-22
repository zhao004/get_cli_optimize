import 'dart:io';

import 'package:get_cli/samples/impl/signals_pattern/signals_app_router.dart';
import 'package:get_cli/samples/impl/signals_pattern/signals_app_routes.dart';
import 'package:get_cli/samples/impl/signals_pattern/signals_controller.dart';
import 'package:get_cli/samples/impl/signals_pattern/signals_injector.dart';
import 'package:get_cli/samples/impl/signals_pattern/signals_main.dart';
import 'package:get_cli/samples/impl/signals_pattern/signals_view.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('get_cli_signals_samples');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// 逐个 Sample 写入临时目录，走完整的 sortImports + DartFormatter 流水线，
  /// 模板内容无法通过解析时会在此抛出异常。
  test('signals pattern samples write valid dart files', () {
    final samples = [
      SignalsMainSample(),
      SignalsInjectorSample(),
      SignalsRoutesSample(),
      SignalsRouterSample(),
      SignalsControllerSample(),
      SignalsViewSample(),
    ];

    for (final sample in samples) {
      sample.path = p.join(tempDir.path, sample.path);
      final file = sample.create();

      expect(file.existsSync(), isTrue, reason: 'missing file: ${sample.path}');
      expect(file.readAsStringSync(), isNotEmpty,
          reason: 'empty file: ${sample.path}');
    }
  });

  test('signals pattern samples contain expected integration markers', () {
    expect(SignalsMainSample().content, contains('MaterialApp.router'));
    expect(SignalsMainSample().content, contains('Injector.registerAll()'));

    expect(
      SignalsInjectorSample().content,
      contains('getIt.registerLazySingleton<HomeController>'),
    );

    expect(SignalsRoutesSample().content, contains("home = '/';"));

    expect(SignalsRouterSample().content, contains('GoRouter('));
    expect(SignalsRouterSample().content, contains('initialLocation: Routes.home'));

    expect(SignalsControllerSample().content, contains('signal(0)'));

    expect(SignalsViewSample().content, contains('Watch('));
    expect(SignalsViewSample().content, contains('getIt<HomeController>()'));
  });
}
