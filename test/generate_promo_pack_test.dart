import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/cosmetic_catalog.dart';
import 'package:lung_buddy/domain/cosmetic_loadout.dart';
import 'package:lung_buddy/domain/cosmetic_slot.dart';
import 'package:lung_buddy/theme/app_theme.dart';
import 'package:lung_buddy/ui/home/lung_painter.dart';

CosmeticLoadout _loadoutFor(CosmeticDef item) {
  if (item.slot == null) return CosmeticLoadout.empty;
  return switch (item.slot!) {
    CosmeticSlot.hat => CosmeticLoadout(hatId: item.id),
    CosmeticSlot.eyes => CosmeticLoadout(eyesId: item.id),
    CosmeticSlot.back => CosmeticLoadout(backId: item.id),
    CosmeticSlot.face => CosmeticLoadout(faceId: item.id),
  };
}

Future<void> _png({
  required String path,
  required int px,
  required double smokeRatio,
  CosmeticLoadout loadout = CosmeticLoadout.empty,
  Color? background,
  bool transparent = false,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(px.toDouble(), px.toDouble());
  if (!transparent && background != null) {
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
  test('build Grok promo reference pack', () async {
    const out = 'promo-for-grok';
    final dir = Directory(out);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    await Directory('$out/mascot').create();
    await Directory('$out/cosmetics').create();
    await Directory('$out/brand').create();

    // Mood ladder for the smoke story
    final moods = <String, double>{
      '01_fresh_pink': 0.0,
      '02_happy': 0.08,
      '03_mid_budget': 0.45,
      '04_worried': 0.75,
      '05_soot_monster': 1.15,
    };
    for (final e in moods.entries) {
      await _png(
        path: '$out/mascot/${e.key}.png',
        px: 1024,
        smokeRatio: e.value,
        background: BuddyColors.cream,
      );
      await _png(
        path: '$out/mascot/${e.key}_transparent.png',
        px: 1024,
        smokeRatio: e.value,
        transparent: true,
      );
    }

    // A few signature cosmetics on a healthy buddy
    final looks = [
      'beanie_mint',
      'bow_coral',
      'halo',
      'streak_cape',
      'angel_wings',
      'mustache',
      'sun_visors',
    ];
    for (final id in looks) {
      final item = CosmeticCatalog.byId(id);
      await _png(
        path: '$out/cosmetics/$id.png',
        px: 768,
        smokeRatio: 0.08,
        loadout: _loadoutFor(item),
        background: const Color(0xFFFFF0F6),
      );
    }

    // Gradient backdrop swatch for motion graphics
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(1080, 1920);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          BuddyColors.skyTop,
          BuddyColors.skyBottom,
          Color(0xFFB8F0FF),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(1080, 1920);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$out/brand/app_gradient_9x16.png')
        .writeAsBytes(bytes!.buffer.asUint8List());

    // Color chips strip
    final chipRec = ui.PictureRecorder();
    final chipCanvas = Canvas(chipRec);
    const chipSize = Size(1200, 200);
    chipCanvas.drawRect(Offset.zero & chipSize, Paint()..color = Colors.white);
    final colors = <Color>[
      BuddyColors.skyTop,
      BuddyColors.skyBottom,
      BuddyColors.mint,
      BuddyColors.bubblegum,
      BuddyColors.grape,
      BuddyColors.lemon,
      BuddyColors.ink,
      BuddyColors.cream,
    ];
    final names = [
      'skyTop',
      'skyBottom',
      'mint',
      'bubblegum',
      'grape',
      'lemon',
      'ink',
      'cream',
    ];
    for (var i = 0; i < colors.length; i++) {
      final x = 20.0 + i * 145;
      chipCanvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 30, 120, 120),
          const Radius.circular(24),
        ),
        Paint()..color = colors[i],
      );
      chipCanvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 30, 120, 120),
          const Radius.circular(24),
        ),
        Paint()
          ..color = BuddyColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
    final chipPic = chipRec.endRecording();
    final chipImg = await chipPic.toImage(1200, 200);
    final chipBytes = await chipImg.toByteData(format: ui.ImageByteFormat.png);
    await File('$out/brand/color_chips.png')
        .writeAsBytes(chipBytes!.buffer.asUint8List());
    expect(names.length, 8);

    // Copy launcher sources if present
    for (final src in [
      'assets/branding/app_icon.png',
      'assets/branding/app_icon_foreground.png',
    ]) {
      final f = File(src);
      if (f.existsSync()) {
        await f.copy('$out/brand/${f.uri.pathSegments.last}');
      }
    }

    expect(Directory('$out/mascot').listSync().length, greaterThan(8));
  });
}
