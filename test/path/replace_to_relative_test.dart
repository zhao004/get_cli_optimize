import 'package:get_cli/functions/path/replace_to_relative.dart';
import 'package:test/test.dart';

void main() {
  test('replace import to relative', () {
    var import = "import 'package:ponto_facil/app/pages/home/home_view.dart';";
    var otherFile = 'lib/app/models/file.dart';
    expect(replaceToRelativeImport(import, otherFile),
        equals("import '../pages/home/home_view.dart';"));
  });
}
