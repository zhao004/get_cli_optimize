import '../../interface/sample_interface.dart';

/// Signals Pattern 架构的 [lib/app/di/injector.dart] 模板。
/// 以 get_it 作为服务定位器；保持 `class Injector {` 纯声明形式，
/// 便于后续通过 appendClassContent 追加注册方法。
class SignalsInjectorSample extends Sample {
  SignalsInjectorSample() : super('lib/app/di/injector.dart', overwrite: true);

  @override
  String get content => '''
import 'package:get_it/get_it.dart';

import '../pages/home/home_controller.dart';

final GetIt getIt = GetIt.instance;

class Injector {
  Injector._();

  static void registerAll() {
    registerHomeController();
  }

  static void registerHomeController() {
    getIt.registerLazySingleton<HomeController>(HomeController.new);
  }
}
''';
}
