import '../../interface/sample_interface.dart';

/// Riverpod Pattern 架构的页面状态模板。
/// 使用 riverpod_generator 的 @riverpod 类式 Notifier，
/// 服务依赖通过 get_it 获取，生成文件为 home_controller.g.dart。
class RiverpodControllerSample extends Sample {
  RiverpodControllerSample()
      : super('lib/app/pages/home/home_controller.dart', overwrite: true);

  @override
  String get content => '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di/injector.dart';
import '../../services/home_service.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _\$HomeController {
  @override
  int build() => 0;

  void increment() {
    state = getIt<HomeService>().increment(state);
  }
}
''';
}
