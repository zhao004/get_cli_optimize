import 'dart:io';

import 'package:get_cli/samples/impl/riverpod_pattern/riverpod_app_router.dart';
import 'package:get_cli/samples/impl/riverpod_pattern/riverpod_app_routes.dart';
import 'package:get_cli/samples/impl/riverpod_pattern/riverpod_controller.dart';
import 'package:get_cli/samples/impl/riverpod_pattern/riverpod_injector.dart';
import 'package:get_cli/samples/impl/riverpod_pattern/riverpod_main.dart';
import 'package:get_cli/samples/impl/riverpod_pattern/riverpod_service.dart';
import 'package:get_cli/samples/impl/riverpod_pattern/riverpod_view.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('get_cli_riverpod_samples');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// 逐个 Sample 写入临时目录，走完整的 sortImports + DartFormatter 流水线，
  /// 模板内容无法通过解析时会在此抛出异常。
  test('riverpod pattern samples write valid dart files', () {
    final samples = [
      RiverpodMainSample(),
      RiverpodInjectorSample(),
      RiverpodServiceSample(),
      RiverpodRoutesSample(),
      RiverpodRouterSample(),
      RiverpodControllerSample(),
      RiverpodViewSample(),
    ];

    for (final sample in samples) {
      sample.path = p.join(tempDir.path, sample.path);
      final file = sample.create();

      expect(file.existsSync(), isTrue, reason: 'missing file: ${sample.path}');
      expect(file.readAsStringSync(), isNotEmpty,
          reason: 'empty file: ${sample.path}');
    }
  });

  test('riverpod pattern samples contain expected integration markers', () {
    expect(RiverpodMainSample().content, contains('ProviderScope'));
    expect(RiverpodMainSample().content, contains('MaterialApp.router'));
    expect(RiverpodMainSample().content, contains('Injector.registerAll()'));

    expect(
      RiverpodInjectorSample().content,
      contains('getIt.registerLazySingleton<HomeService>'),
    );

    expect(
      RiverpodServiceSample().path,
      equals('lib/app/services/home_service.dart'),
    );

    expect(RiverpodRoutesSample().content, contains("home = '/';"));

    expect(RiverpodRouterSample().content, contains('GoRouter('));
    expect(
      RiverpodRouterSample().content,
      contains('initialLocation: Routes.home'),
    );

    expect(
      RiverpodControllerSample().content,
      contains("part 'home_controller.g.dart';"),
    );
    expect(RiverpodControllerSample().content, contains('@riverpod'));
    expect(
      RiverpodControllerSample().content,
      contains('extends _\$HomeController'),
    );
    expect(
      RiverpodControllerSample().content,
      contains('getIt<HomeService>()'),
    );

    expect(RiverpodViewSample().content, contains('ConsumerWidget'));
    expect(
      RiverpodViewSample().content,
      contains('ref.watch(homeControllerProvider)'),
    );
    expect(
      RiverpodViewSample().content,
      contains('homeControllerProvider.notifier'),
    );
  });
}
