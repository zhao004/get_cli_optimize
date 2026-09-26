import 'package:get_cli/common/menu/menu.dart';
import 'package:test/test.dart';

void main() {
  test('single choice lines align labels for both states', () {
    final menu = Menu(['Yes', 'No']);

    expect(menu.selectedPrefix, '❯');
    expect(menu.unselectedPrefix, ' ');

    final selected = formatMenuChoiceLine(
      'Yes',
      selected: true,
      selectedPrefix: menu.selectedPrefix,
      unselectedPrefix: menu.unselectedPrefix,
    );
    final unselected = formatMenuChoiceLine(
      'No',
      selected: false,
      selectedPrefix: menu.selectedPrefix,
      unselectedPrefix: menu.unselectedPrefix,
    );

    expect(selected, '  ❯ Yes');
    expect(unselected, '    No');
    expect(selected.indexOf('Yes'), unselected.indexOf('No'));
  });

  test('multi select lines align checkbox and label columns', () {
    final highlighted = formatMultiSelectChoiceLine(
      'Drift',
      highlighted: true,
      checked: true,
    );
    final plain = formatMultiSelectChoiceLine(
      'Retrofit',
      highlighted: false,
      checked: false,
    );

    expect(highlighted, '  ❯ [✓] Drift');
    expect(plain, '    [ ] Retrofit');
    expect(highlighted.indexOf('Drift'), plain.indexOf('Retrofit'));
  });
}
