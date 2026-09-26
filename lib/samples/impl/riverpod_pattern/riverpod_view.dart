import '../../interface/sample_interface.dart';

/// Riverpod Pattern 架构的页面视图模板。
/// [ConsumerWidget] 通过 ref.watch 订阅 provider 状态，
/// 事件交由 Notifier 处理，实现状态与 UI 分离。
class RiverpodViewSample extends Sample {
  RiverpodViewSample()
      : super('lib/app/pages/home/home_view.dart', overwrite: true);

  @override
  String get content => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_controller.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(homeControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '\$count',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(homeControllerProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
}
