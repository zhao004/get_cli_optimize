import '../../interface/sample_interface.dart';

/// Signals Pattern 架构的页面控制器模板。
/// 控制器为普通类，状态以 signal 表达，不做生命周期管理，
/// 由 get_it 注册为单例后供视图读取。
class SignalsControllerSample extends Sample {
  SignalsControllerSample()
      : super('lib/app/pages/home/home_controller.dart', overwrite: true);

  @override
  String get content => '''
import 'package:signals/signals_flutter.dart';

class HomeController {
  //TODO: Implement HomeController

  final count = signal(0);

  void increment() => count.value++;
}
''';
}
