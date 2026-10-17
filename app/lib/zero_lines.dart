/// Zero's lines (assets/zero/lines.js) for the places she shows up outside her tab: reminders,
/// the end of a review session.
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'db.dart';

Future<Map<String, dynamic>>? _lines;

/// A random line from [pool] as (Chinese, English), with {due张}-style holes filled from [n].
Future<(String, String)?> zeroLine(String pool, [Map<String, int> n = const {}]) async {
  final all = await (_lines ??= rootBundle.loadString('assets/zero/lines.js').then((s) =>
      jsonDecode(s.substring(s.indexOf('\nconst LINES =') + 14, s.lastIndexOf(';'))) as Map<String, dynamic>));
  final ls = all[pool] as List?;
  if (ls == null || ls.isEmpty) return null;
  final l = ls[Random().nextInt(ls.length)] as List;
  String fill(String s) => s.replaceAllMapped(RegExp(r'\{(\w+)([张天点]?)\}'), (m) => '${n[m[1]] ?? ''}${m[2]}');
  return (fill(l[0] as String), fill(l[1] as String));
}

/// Her temperament on [day]: the same hash as temper() in index.html, so a reminder matches her mood that day.
String zeroTemper(DateTime day) {
  var h = 7;
  for (final c in dayStart(day).toIso8601String().substring(0, 10).codeUnits) {
    h = (h * 31 + c) & 0xFFFFFFFF;
  }
  return const ['sweet', 'clingy', 'bratty', 'spacey'][h % 4];
}
