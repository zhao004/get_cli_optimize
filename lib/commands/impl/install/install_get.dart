import '../../../common/utils/pubspec/pubspec_utils.dart';

Future<void> installGet([bool runPubGet = false, String? version]) async {
  if (PubspecUtils.containsPackage('get')) {
    await PubspecUtils.removeDependencies('get', logger: false);
  }
  await PubspecUtils.addDependencies(
    'get',
    version: version,
    runPubGet: runPubGet,
  );
}
