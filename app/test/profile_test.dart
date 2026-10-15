import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/profile.dart';

void main() {
  testWidgets('avatar is center-cropped to a small square PNG', (tester) async {
    await tester.runAsync(() async {
      final rec = ui.PictureRecorder();
      Canvas(rec).drawRect(const Rect.fromLTWH(0, 0, 40, 20), Paint()..color = const Color(0xFFB9A7FF));
      final wide = await (await rec.endRecording().toImage(40, 20)).toByteData(format: ui.ImageByteFormat.png);

      final out = await squarePng(wide!.buffer.asUint8List(), size: 16);
      expect(out.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      final img = (await (await ui.instantiateImageCodec(Uint8List.fromList(out))).getNextFrame()).image;
      expect((img.width, img.height), (16, 16));
    });
  });
}
