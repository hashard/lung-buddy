import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/cosmetic_loadout.dart';
import 'package:lung_buddy/ui/home/lung_painter.dart';

void main() {
  test('paints mixed loadout without throwing', () async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    LungPainter(
      smokeRatio: 0.08,
      coughPhase: 0,
      loadout: const CosmeticLoadout(
        hatId: 'beanie_mint',
        backId: 'streak_cape',
        faceId: 'halo',
      ),
    ).paint(canvas, const Size(400, 400));
    final img = await recorder.endRecording().toImage(400, 400);
    expect(img.width, 400);
    expect(img.height, 400);
  });
}
