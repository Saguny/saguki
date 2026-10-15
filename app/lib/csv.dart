/// Minimal RFC 4180 CSV: quoted fields, "" escapes, newlines inside quotes.
library;

/// Picks tab, semicolon or comma by which appears most in the first line.
String detectDelimiter(String text) {
  final first = text.split('\n').first;
  final counts = {for (final d in ['\t', ';', ',']) d: d.allMatches(first).length};
  return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}

List<List<String>> parseCsv(String text, {String? delimiter}) {
  final d = delimiter ?? detectDelimiter(text);
  if (text.startsWith('﻿')) text = text.substring(1);
  final rows = <List<String>>[];
  var row = <String>[], field = StringBuffer(), quoted = false;
  void endField() {
    row.add(field.toString());
    field = StringBuffer();
  }

  void endRow() {
    endField();
    if (row.any((f) => f.isNotEmpty)) rows.add(row);
    row = [];
  }

  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '"' && i + 1 < text.length && text[i + 1] == '"') {
        field.write('"');
        i++;
      } else if (c == '"') {
        quoted = false;
      } else {
        field.write(c);
      }
    } else if (c == '"' && field.isEmpty) {
      quoted = true;
    } else if (c == d) {
      endField();
    } else if (c == '\n') {
      endRow();
    } else if (c != '\r') {
      field.write(c);
    }
  }
  endRow();
  return rows;
}

String toCsv(List<List<String>> rows) => rows
    .map((r) => r.map((f) => RegExp(r'[",\n\r]').hasMatch(f) ? '"${f.replaceAll('"', '""')}"' : f).join(','))
    .join('\r\n');
