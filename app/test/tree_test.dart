import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/tree.dart';

void main() {
  test('tree height: 1 cm a card early on, the Moon after about three years at 150 a day', () {
    expect(treeHeight(0), 0);
    expect(treeHeight(150), closeTo(1.51, 0.01));
    expect(treeHeight(150 * 1000), lessThan(384400e3));
    expect(treeHeight(150 * 1100), greaterThan(384400e3));
    expect([fmtHeight(0.03), fmtHeight(1.5), fmtHeight(30), fmtHeight(5700), fmtHeight(131000), fmtHeight(1078000)],
        ['3 cm', '1.5 m', '30 m', '5.7 km', '131 km', '1,078 km']);
  });

  testWidgets('scene paints from seedling to the Moon', (tester) async {
    for (final h in [0.03, 1.5, 6.0, 300.0, 24e3, 131e3, 1.1e6, 1e8, 3.82e8]) {
      await tester.pumpWidget(Center(child: SizedBox(width: 390, height: 760, child: treeSceneAt(h))));
      expect(tester.takeException(), isNull, reason: 'height $h');
    }
  });
}
