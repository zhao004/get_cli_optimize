import 'package:get_cli/core/structure.dart';
import 'package:test/test.dart';

void main() {
  test('getx defaults use pages layout and new app folders', () {
    expect(Structure.useFlatPageLayout(), isTrue);
    expect(
      Structure.model('home', 'page', false, folderName: '').path,
      equals(Structure.replaceAsExpected(path: 'lib/app/pages/home')),
    );
    expect(
      Structure.model('user', 'model', false, folderName: '').path,
      equals(Structure.replaceAsExpected(path: 'lib/app/models/user')),
    );
    expect(
      Structure.model('user', 'provider', false, folderName: '').path,
      equals(Structure.replaceAsExpected(path: 'lib/app/http/user')),
    );
    expect(
      Structure.model('card', 'view', false, folderName: '').path,
      equals(Structure.replaceAsExpected(path: 'lib/app/widgets/card')),
    );
  });

  test('route helpers strip app page root segments', () {
    final segments = ['app', 'pages', 'home', 'detail'];

    Structure.trimPageRootSegments(segments);

    expect(segments, equals(['home', 'detail']));
  });
}
