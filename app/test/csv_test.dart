import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/csv.dart';

void main() {
  test('csv round-trip and parsing', () {
    final rows = [
      ['term', 'meaning'],
      ['勉強', 'study, learning'],
      ['say "hi"', 'line1\nline2'],
    ];
    expect(parseCsv(toCsv(rows)), rows);
    expect(parseCsv('a\tb\n1\t2\n'), [
      ['a', 'b'],
      ['1', '2'],
    ]);
    expect(parseCsv('﻿a;b\r\n\r\n1;2'), [
      ['a', 'b'],
      ['1', '2'],
    ]);
  });
}
