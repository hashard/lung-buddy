import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/cosmetic_loadout.dart';
import 'package:lung_buddy/theme/app_theme.dart';
import 'package:lung_buddy/ui/home/lung_painter.dart';

Future<void> _writeBuddyPng({
  required String path,
  required int px,
  required Color background,
  bool transparent = false,
  double smokeRatio = 0.08,
  CosmeticLoadout loadout = CosmeticLoadout.empty,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(px.toDouble(), px.toDouble());
  if (!transparent) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
  }
  LungPainter(
    smokeRatio: smokeRatio,
    coughPhase: 0,
    loadout: loadout,
  ).paint(canvas, size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(px, px);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  test('generate launcher + widget buddy art', () async {
    // Full-bleed launcher source (flutter_launcher_icons crops with inset).
    await _writeBuddyPng(
      path: 'assets/branding/app_icon.png',
      px: 1024,
      background: const Color(0xFFFFF0F6),
    );
    // Adaptive foreground with transparent margins for safe zone.
    await _writeBuddyPng(
      path: 'assets/branding/app_icon_foreground.png',
      px: 1024,
      background: Colors.transparent,
      transparent: true,
    );
    // Replace placeholder mascot moods with real buddy art.
    for (final entry in {
      'happy': 0.05,
      'chill': 0.25,
      'worried': 0.75,
      'celebrate': 0.0,
    }.entries) {
      await _writeBuddyPng(
        path: 'assets/mascot/${entry.key}.png',
        px: 512,
        background: BuddyColors.cream,
        smokeRatio: entry.value,
      );
    }
    // Static Android widget fallback (drawable).
    await _writeBuddyPng(
      path: 'android/app/src/main/res/drawable-xxhdpi/buddy_widget_mascot.png',
      px: 216,
      background: const Color(0xFFFFE8F2),
    );
    await _writeBuddyPng(
      path: 'android/app/src/main/res/drawable-xxxhdpi/buddy_widget_mascot.png',
      px: 288,
      background: const Color(0xFFFFE8F2),
    );

    expect(File('assets/branding/app_icon.png').existsSync(), isTrue);
    expect(File('assets/mascot/happy.png').lengthSync(), greaterThan(5000));
  });
}
