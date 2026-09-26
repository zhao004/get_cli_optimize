import '../../interface/sample_interface.dart';

/// Riverpod Pattern 架构的 [lib/app/di/injector.dart] 模板。
/// get_it 只注册服务/仓储等基础设施；UI 状态由 Riverpod 管理。
/// 保持 `class Injector {` 纯声明形式，便于后续通过 appendClassContent
/// 追加注册方法。
class RiverpodInjectorSample extends Sample {
  RiverpodInjectorSample() : super('lib/app/di/injector.dart', overwrite: true);

  @override
  String get content => '''
import 'package:get_it/get_it.dart';

import '../services/home_service.dart';

final GetIt getIt = GetIt.instance;

class Injector {
  Injector._();

  static void registerAll() {
    registerHomeService();
  }

  static void registerHomeService() {
    getIt.registerLazySingleton<HomeService>(HomeService.new);
  }
}
''';
}
