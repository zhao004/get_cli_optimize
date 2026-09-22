import '../../interface/sample_interface.dart';

/// Signals Pattern 架构的页面视图模板。
/// 通过 get_it 获取控制器，并以 signals_flutter 的 [Watch] 组件
/// 订阅信号变化实现局部重绘。
class SignalsViewSample extends Sample {
  SignalsViewSample() : super('lib/app/pages/home/home_view.dart', overwrite: true);

  @override
  String get content => '''
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../di/injector.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = getIt<HomeController>();
    return Watch(
      (context) => Scaffold(
        appBar: AppBar(
          title: const Text('HomeView'),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            '\${controller.count.value}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.increment,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
''';
}
