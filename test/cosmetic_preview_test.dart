import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/cosmetic_catalog.dart';
import 'package:lung_buddy/ui/home/lung_painter.dart';

void main() {
  test('render all cosmetics for visual QA', () async {
    final outDir = Directory('tool/cosmetic_previews');
    if (await outDir.exists()) {
      await outDir.delete(recursive: true);
    }
    await outDir.create(recursive: true);

    for (final item in CosmeticCatalog.items) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 400);
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFFFF0F6),
      );
      LungPainter(
        smokeRatio: 0.08,
        coughPhase: 0,
        cosmetic: item,
      ).paint(canvas, size);

      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 400);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('${outDir.path}/${item.id}.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    }

    expect(outDir.listSync().length, CosmeticCatalog.items.length);
  });
}
