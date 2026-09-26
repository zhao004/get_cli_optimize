import '../../interface/sample_interface.dart';

/// Riverpod Pattern 架构的 [lib/app/services/home_service.dart] 模板。
/// 纯业务逻辑载体，由 get_it 注册后供 Riverpod Notifier 调用。
class RiverpodServiceSample extends Sample {
  RiverpodServiceSample()
      : super('lib/app/services/home_service.dart', overwrite: true);

  @override
  String get content => '''
class HomeService {
  //TODO: Implement HomeService

  int increment(int value) => value + 1;
}
''';
}
