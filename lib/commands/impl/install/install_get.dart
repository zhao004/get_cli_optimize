import '../../../common/utils/pubspec/pubspec_utils.dart';

Future<void> installGet([bool runPubGet = false, String? constraint]) async {
  if (PubspecUtils.containsPackage('get')) {
    await PubspecUtils.removeDependencies('get', logger: false);
  }
  await PubspecUtils.addDependencies(
    'get',
    constraint: constraint,
    runPubGet: runPubGet,
  );
}
