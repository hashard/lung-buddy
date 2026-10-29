import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/cosmetic_catalog.dart';
import '../../domain/cosmetic_loadout.dart';
import '../../theme/app_theme.dart';

/// Goofy sticker-book lung. [smokeRatio] 0 = candy pink, 1+ = soot monster.
///
/// Draw order: back → body/rim/freckles → face → eyes → hat → face props → cough.
class LungPainter extends CustomPainter {
  LungPainter({
    required this.smokeRatio,
    required this.coughPhase,
    this.flowPhase = 0,
    this.loadout = CosmeticLoadout.empty,
  });

  final double smokeRatio;
  final double coughPhase;
  final double flowPhase;
  final CosmeticLoadout loadout;

  CosmeticDef get _hat => CosmeticCatalog.byId(loadout.hatId);
  CosmeticDef get _eyes => CosmeticCatalog.byId(loadout.eyesId);
  CosmeticDef get _back => CosmeticCatalog.byId(loadout.backId);
  CosmeticDef get _face => CosmeticCatalog.byId(loadout.faceId);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;
    final scale = size.width / 200;
    final t = smokeRatio.clamp(0.0, 1.35);

    final healthy = const Color(0xFFFF8FB8);
    final mid = const Color(0xFFB89AA8);
    final sick = const Color(0xFF2B2433);
    final Color bodyColor;
    if (t < 0.45) {
      bodyColor = Color.lerp(healthy, mid, t / 0.45)!;
    } else {
      bodyColor = Color.lerp(mid, sick, ((t - 0.45) / 0.8).clamp(0.0, 1.0))!;
    }

    final outline = BuddyColors.ink;
    final shake =
        math.sin(coughPhase * math.pi * 2) * 5 * scale * (t > 0.12 ? 1 : 0);
    final squash = coughPhase > 0.05 && coughPhase < 0.7
        ? 1.0 - 0.12 * math.sin(coughPhase * math.pi)
        : 1.0;

    canvas.save();
    canvas.translate(cx + shake, cy);
    canvas.scale(1 / squash, squash);
    canvas.translate(-cx, -cy);

    final bodyPaint = Paint()..color = bodyColor;
    final inkStroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final stickerRim = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11 * scale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 72 * scale),
        width: 110 * scale,
        height: 18 * scale,
      ),
      Paint()..color = BuddyColors.ink.withValues(alpha: 0.12),
    );

    // 1. Back slot behind body
    _drawBehindCosmetics(canvas, cx, cy, scale, _back);

    // Rounder bean lobes — bottom-heavy Grok silhouette
    final left = Path()
      ..moveTo(cx - 4 * scale, cy - 28 * scale)
      ..cubicTo(
        cx - 72 * scale,
        cy - 62 * scale,
        cx - 108 * scale,
        cy + 4 * scale,
        cx - 62 * scale,
        cy + 62 * scale,
      )
      ..cubicTo(
        cx - 30 * scale,
        cy + 88 * scale,
        cx - 6 * scale,
        cy + 48 * scale,
        cx - 2 * scale,
        cy - 2 * scale,
      )
      ..close();
    final right = Path()
      ..moveTo(cx + 4 * scale, cy - 28 * scale)
      ..cubicTo(
        cx + 72 * scale,
        cy - 62 * scale,
        cx + 108 * scale,
        cy + 4 * scale,
        cx + 62 * scale,
        cy + 62 * scale,
      )
      ..cubicTo(
        cx + 30 * scale,
        cy + 88 * scale,
        cx + 6 * scale,
        cy + 48 * scale,
        cx + 2 * scale,
        cy - 2 * scale,
      )
      ..close();

    final body = Path()
      ..addPath(left, Offset.zero)
      ..addPath(right, Offset.zero);

    // Sticker rim then ink outline, then fill
    canvas.drawPath(body, stickerRim);
    canvas.drawPath(left, bodyPaint);
    canvas.drawPath(right, bodyPaint);
    canvas.drawPath(left, inkStroke);
    canvas.drawPath(right, inkStroke);

    // Center cleft line
    canvas.drawLine(
      Offset(cx, cy - 18 * scale),
      Offset(cx, cy + 36 * scale),
      Paint()
        ..color = Color.lerp(const Color(0xFFE85A9A), outline, t.clamp(0, 1))!
            .withValues(alpha: 0.55)
        ..strokeWidth = 3 * scale
        ..strokeCap = StrokeCap.round,
    );

    // Freckle spots on outer mid-lobes (tint with soot)
    final freckleBase = Color.lerp(
      const Color(0xFFE85A9A),
      const Color(0xFF4A3F4E),
      t.clamp(0.0, 1.0),
    )!;
    final freckle = Paint()
      ..color = freckleBase.withValues(alpha: 0.55 + 0.2 * (1 - t.clamp(0, 1)));
    for (final spot in [
      Offset(cx - 58 * scale, cy + 6 * scale),
      Offset(cx - 48 * scale, cy + 22 * scale),
      Offset(cx - 68 * scale, cy + 28 * scale),
      Offset(cx + 58 * scale, cy + 6 * scale),
      Offset(cx + 48 * scale, cy + 22 * scale),
      Offset(cx + 68 * scale, cy + 28 * scale),
    ]) {
      final r = (2.2 + (spot.dx - cx).abs() * 0.01) * scale;
      canvas.drawCircle(spot, r, freckle);
    }

    // Belly highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 22 * scale, cy + 22 * scale),
        width: 30 * scale,
        height: 18 * scale,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22 * (1 - t.clamp(0, 1))),
    );

    // Neck scarf (back-slot non-cape) after body, before face
    if (_back.kind == CosmeticKind.scarf && !_isCape(_back)) {
      _drawScarf(canvas, cx, cy, scale, _back);
    }

    // 3. Base face
    final blushA = (0.5 * (1 - t.clamp(0.0, 1.0))).clamp(0.0, 0.5);
    final blush = Paint()..color = const Color(0xFFFF4D88).withValues(alpha: blushA);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 42 * scale, cy + 14 * scale),
        width: 28 * scale,
        height: 18 * scale,
      ),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 42 * scale, cy + 14 * scale),
        width: 28 * scale,
        height: 18 * scale,
      ),
      blush,
    );

    final eyeY = cy - 2 * scale;
    final eyeR = 16 * scale;
    final eyeFill = Paint()..color = Colors.white;
    final eyeStroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 * scale;
    canvas.drawCircle(Offset(cx - 28 * scale, eyeY), eyeR, eyeFill);
    canvas.drawCircle(Offset(cx + 28 * scale, eyeY), eyeR, eyeFill);
    canvas.drawCircle(Offset(cx - 28 * scale, eyeY), eyeR, eyeStroke);
    canvas.drawCircle(Offset(cx + 28 * scale, eyeY), eyeR, eyeStroke);

    if (t > 0.78 || (coughPhase > 0.15 && coughPhase < 0.55)) {
      final xPaint = Paint()
        ..color = outline
        ..strokeWidth = 4.5 * scale
        ..strokeCap = StrokeCap.round;
      for (final ox in [-28.0, 28.0]) {
        canvas.drawLine(
          Offset(cx + (ox - 8) * scale, eyeY - 8 * scale),
          Offset(cx + (ox + 8) * scale, eyeY + 8 * scale),
          xPaint,
        );
        canvas.drawLine(
          Offset(cx + (ox + 8) * scale, eyeY - 8 * scale),
          Offset(cx + (ox - 8) * scale, eyeY + 8 * scale),
          xPaint,
        );
      }
    } else {
      final pupil = Paint()..color = outline;
      final look = t > 0.5 ? 2.0 * scale : 0.0;
      final pupilR = 7.2 * scale;
      canvas.drawCircle(
        Offset(cx - 28 * scale + look, eyeY + 2 * scale),
        pupilR,
        pupil,
      );
      canvas.drawCircle(
        Offset(cx + 28 * scale + look, eyeY + 2 * scale),
        pupilR,
        pupil,
      );
      final shine = Paint()..color = Colors.white;
      // Big + small sparkle (top-left of each pupil)
      canvas.drawCircle(
        Offset(cx - 32 * scale + look, eyeY - 2 * scale),
        3.2 * scale,
        shine,
      );
      canvas.drawCircle(
        Offset(cx - 26 * scale + look, eyeY + 3 * scale),
        1.4 * scale,
        shine,
      );
      canvas.drawCircle(
        Offset(cx + 24 * scale + look, eyeY - 2 * scale),
        3.2 * scale,
        shine,
      );
      canvas.drawCircle(
        Offset(cx + 30 * scale + look, eyeY + 3 * scale),
        1.4 * scale,
        shine,
      );
    }

    // Mouth — tongue smile when healthy, flat/frown when sootier
    final mouthPaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 * scale
      ..strokeCap = StrokeCap.round;

    if (coughPhase > 0.12 && coughPhase < 0.6 && t > 0.08) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 30 * scale),
          width: 22 * scale,
          height: 20 * scale,
        ),
        Paint()..color = const Color(0xFF1A1028),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 32 * scale),
          width: 12 * scale,
          height: 8 * scale,
        ),
        Paint()..color = const Color(0xFFFF6BB5),
      );
    } else if (t < 0.55) {
      // U-smile with tongue
      final smile = Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(cx, cy + 22 * scale),
            width: 36 * scale,
            height: 28 * scale,
          ),
          0.15 * math.pi,
          0.7 * math.pi,
        );
      canvas.drawPath(smile, mouthPaint);
      // Tiny tongue inside the smile
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 34 * scale),
          width: 10 * scale,
          height: 7 * scale,
        ),
        Paint()..color = const Color(0xFFFF6BB5),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 34 * scale),
          width: 10 * scale,
          height: 7 * scale,
        ),
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * scale,
      );
    } else if (t < 0.78) {
      canvas.drawLine(
        Offset(cx - 14 * scale, cy + 30 * scale),
        Offset(cx + 14 * scale, cy + 30 * scale),
        mouthPaint,
      );
    } else {
      final frown = Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(cx, cy + 38 * scale),
            width: 34 * scale,
            height: 22 * scale,
          ),
          1.1 * math.pi,
          0.8 * math.pi,
        );
      canvas.drawPath(frown, mouthPaint);
    }

    // 4. Eyes slot glasses
    if (_eyes.kind == CosmeticKind.glasses) {
      _drawGlasses(canvas, cx, eyeY, scale, _eyes);
    }

    // 5. Hat slot
    if (_hat.kind == CosmeticKind.hat) {
      _drawHat(canvas, cx, cy, scale, _hat);
    }

    // 6. Face slot (halo above hat; mustache / bandage / flower / etc.)
    if (_face.id == 'mustache') {
      _drawMustache(canvas, cx, cy, scale, _face);
    } else if (_face.kind == CosmeticKind.prop && _face.id != 'angel_wings') {
      _drawProp(canvas, cx, cy, scale, _face, hasHat: _hat.kind == CosmeticKind.hat);
    }

    // 7. Comic cough clouds
    if (coughPhase > 0.05 && coughPhase < 0.75 && t > 0.1) {
      _drawComicPuff(
        canvas,
        Offset(cx + 36 * scale, cy - 48 * scale - coughPhase * 36 * scale),
        10 * scale,
        1 - coughPhase,
      );
      _drawComicPuff(
        canvas,
        Offset(cx + 52 * scale, cy - 62 * scale - coughPhase * 28 * scale),
        7 * scale,
        1 - coughPhase,
      );
    }

    // Over-budget comic smoke
    if (smokeRatio > 1.0) {
      final intensity = ((smokeRatio - 1.0) / 0.45).clamp(0.4, 1.0);
      for (var i = 0; i < 6; i++) {
        final local = (flowPhase + i * 0.15) % 1.0;
        final rise = local * 100 * scale;
        final wobble = math.sin((flowPhase * 2 + i) * math.pi * 2) * 12 * scale;
        final side = (i.isEven ? -1.0 : 1.0) * (14 + i * 5) * scale;
        _drawComicPuff(
          canvas,
          Offset(cx + side + wobble, cy - 60 * scale - rise),
          (11 + i * 2) * scale * (0.7 + local * 0.6),
          (0.7 * intensity * (1 - local)).clamp(0.0, 0.7),
          sooty: true,
        );
      }
    }

    if (t > 0.4) {
      final soot = Paint()..color = outline.withValues(alpha: 0.2 + 0.35 * (t - 0.4));
      final rng = math.Random(3);
      for (var i = 0; i < (10 + t * 14).toInt(); i++) {
        canvas.drawCircle(
          Offset(
            cx + (rng.nextDouble() - 0.5) * 110 * scale,
            cy + (rng.nextDouble() - 0.35) * 90 * scale,
          ),
          (1.2 + rng.nextDouble() * 2.5) * scale,
          soot,
        );
      }
    }

    canvas.restore();
  }

  void _drawComicPuff(
    Canvas canvas,
    Offset c,
    double r,
    double alpha, {
    bool sooty = false,
  }) {
    final fill = Paint()
      ..color = (sooty ? const Color(0xFF6B6575) : Colors.white)
          .withValues(alpha: alpha);
    final stroke = Paint()
      ..color = BuddyColors.ink.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(c, r, fill);
    canvas.drawCircle(c, r, stroke);
    canvas.drawCircle(c.translate(r * 0.55, -r * 0.2), r * 0.55, fill);
    canvas.drawCircle(c.translate(r * 0.55, -r * 0.2), r * 0.55, stroke);
  }

  void _drawHat(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    CosmeticDef item,
  ) {
    final fill = Paint()..color = item.accent;
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    switch (item.id) {
      case 'beanie_mint':
        // Grok-style: ribbed cuff + dome (sits on lobes, no trachea stub)
        final cuffFill = Paint()..color = const Color(0xFFFF8FB8);
        final dome = Path()
          ..moveTo(cx - 34 * scale, cy - 52 * scale)
          ..quadraticBezierTo(cx, cy - 98 * scale, cx + 34 * scale, cy - 52 * scale)
          ..lineTo(cx + 34 * scale, cy - 44 * scale)
          ..quadraticBezierTo(cx, cy - 48 * scale, cx - 34 * scale, cy - 44 * scale)
          ..close();
        canvas.drawPath(dome, fill);
        canvas.drawPath(dome, stroke);
        final cuff = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 42 * scale),
            width: 72 * scale,
            height: 16 * scale,
          ),
          Radius.circular(6 * scale),
        );
        canvas.drawRRect(cuff, cuffFill);
        canvas.drawRRect(cuff, stroke);
        // Rib lines on cuff
        for (var i = -3; i <= 3; i++) {
          canvas.drawLine(
            Offset(cx + i * 8 * scale, cy - 48 * scale),
            Offset(cx + i * 8 * scale, cy - 36 * scale),
            Paint()
              ..color = BuddyColors.ink.withValues(alpha: 0.35)
              ..strokeWidth = 1.5 * scale,
          );
        }
      case 'bow_coral':
        for (final dx in [-14.0, 14.0]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(cx + dx * scale, cy - 58 * scale),
              width: 22 * scale,
              height: 18 * scale,
            ),
            fill,
          );
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(cx + dx * scale, cy - 58 * scale),
              width: 22 * scale,
              height: 18 * scale,
            ),
            stroke,
          );
        }
        canvas.drawCircle(Offset(cx, cy - 58 * scale), 6 * scale, fill);
        canvas.drawCircle(Offset(cx, cy - 58 * scale), 6 * scale, stroke);
      case 'top_hat':
        final hat = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 78 * scale),
            width: 34 * scale,
            height: 34 * scale,
          ),
          Radius.circular(4 * scale),
        );
        final brim = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 56 * scale),
            width: 54 * scale,
            height: 10 * scale,
          ),
          Radius.circular(3 * scale),
        );
        canvas.drawRRect(hat, fill);
        canvas.drawRRect(hat, stroke);
        canvas.drawRRect(brim, fill);
        canvas.drawRRect(brim, stroke);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(cx, cy - 68 * scale),
            width: 34 * scale,
            height: 7 * scale,
          ),
          Paint()..color = BuddyColors.bubblegum,
        );
      case 'party_crown':
      case 'golden_crown':
        final crown = Path()
          ..moveTo(cx - 30 * scale, cy - 48 * scale)
          ..lineTo(cx - 20 * scale, cy - 84 * scale)
          ..lineTo(cx - 8 * scale, cy - 56 * scale)
          ..lineTo(cx, cy - 90 * scale)
          ..lineTo(cx + 8 * scale, cy - 56 * scale)
          ..lineTo(cx + 20 * scale, cy - 84 * scale)
          ..lineTo(cx + 30 * scale, cy - 48 * scale)
          ..close();
        canvas.drawPath(crown, fill);
        canvas.drawPath(crown, stroke);
        for (final ox in [-16.0, 0.0, 16.0]) {
          canvas.drawCircle(
            Offset(cx + ox * scale, cy - 54 * scale),
            3.5 * scale,
            Paint()..color = BuddyColors.bubblegum,
          );
        }
      case 'couch_hat':
        final seat = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 50 * scale),
            width: 58 * scale,
            height: 16 * scale,
          ),
          Radius.circular(6 * scale),
        );
        final back = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 66 * scale),
            width: 50 * scale,
            height: 18 * scale,
          ),
          Radius.circular(6 * scale),
        );
        canvas.drawRRect(back, fill);
        canvas.drawRRect(back, stroke);
        canvas.drawRRect(seat, fill);
        canvas.drawRRect(seat, stroke);
        for (final dir in [-1.0, 1.0]) {
          final arm = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx + dir * 28 * scale, cy - 56 * scale),
              width: 12 * scale,
              height: 22 * scale,
            ),
            Radius.circular(4 * scale),
          );
          canvas.drawRRect(arm, fill);
          canvas.drawRRect(arm, stroke);
        }
      case 'pirate_bandana':
        final band = Path()
          ..moveTo(cx - 28 * scale, cy - 50 * scale)
          ..lineTo(cx + 28 * scale, cy - 54 * scale)
          ..lineTo(cx + 30 * scale, cy - 40 * scale)
          ..lineTo(cx - 26 * scale, cy - 36 * scale)
          ..close();
        canvas.drawPath(band, fill);
        canvas.drawPath(band, stroke);
        canvas.drawCircle(Offset(cx + 32 * scale, cy - 44 * scale), 6 * scale, fill);
        canvas.drawCircle(Offset(cx + 32 * scale, cy - 44 * scale), 6 * scale, stroke);
        final tails = Path()
          ..moveTo(cx + 34 * scale, cy - 42 * scale)
          ..lineTo(cx + 52 * scale, cy - 30 * scale)
          ..lineTo(cx + 46 * scale, cy - 24 * scale)
          ..lineTo(cx + 36 * scale, cy - 38 * scale)
          ..close();
        canvas.drawPath(tails, fill);
        canvas.drawPath(tails, stroke);
      case 'frog_hat':
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, cy - 64 * scale),
            width: 52 * scale,
            height: 32 * scale,
          ),
          fill,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, cy - 64 * scale),
            width: 52 * scale,
            height: 32 * scale,
          ),
          stroke,
        );
        for (final dir in [-1.0, 1.0]) {
          canvas.drawCircle(Offset(cx + dir * 16 * scale, cy - 80 * scale), 9 * scale, fill);
          canvas.drawCircle(Offset(cx + dir * 16 * scale, cy - 80 * scale), 9 * scale, stroke);
          canvas.drawCircle(
            Offset(cx + dir * 16 * scale, cy - 80 * scale),
            3.5 * scale,
            Paint()..color = BuddyColors.ink,
          );
        }
      case 'sleepy_cap':
        final cap = Path()
          ..moveTo(cx - 32 * scale, cy - 44 * scale)
          ..quadraticBezierTo(cx - 4 * scale, cy - 90 * scale, cx + 24 * scale, cy - 58 * scale)
          ..quadraticBezierTo(cx + 48 * scale, cy - 42 * scale, cx + 54 * scale, cy - 20 * scale)
          ..quadraticBezierTo(cx + 40 * scale, cy - 24 * scale, cx + 28 * scale, cy - 36 * scale)
          ..lineTo(cx - 30 * scale, cy - 34 * scale)
          ..close();
        canvas.drawPath(cap, fill);
        canvas.drawPath(cap, stroke);
        canvas.drawCircle(Offset(cx + 56 * scale, cy - 18 * scale), 7 * scale, fill);
        canvas.drawCircle(Offset(cx + 56 * scale, cy - 18 * scale), 7 * scale, stroke);
      default:
        break;
    }
  }

  bool _isCape(CosmeticDef item) =>
      item.id == 'streak_cape' || item.id == 'rainbow_scarf';

  void _drawBehindCosmetics(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    CosmeticDef item,
  ) {
    if (_isCape(item)) {
      _drawCape(canvas, cx, cy, scale, item);
    }
    if (item.id == 'angel_wings') {
      _drawWings(canvas, cx, cy, scale);
    }
  }

  /// Side cape panels — scalloped bottom for Grok vibe.
  void _drawCape(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    CosmeticDef item,
  ) {
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;

    final colors = item.id == 'rainbow_scarf'
        ? const [
            Color(0xFFFF4D6D),
            Color(0xFFFFE566),
            Color(0xFF7DFFB3),
            Color(0xFF7B5CFF),
          ]
        : [item.accent];

    // Connected cape body behind lobes with scalloped hem
    final capeFill = Paint()
      ..color = item.id == 'streak_cape'
          ? const Color(0xFF2B2433)
          : colors.first;
    final cape = Path()
      ..moveTo(cx - 48 * scale, cy - 20 * scale)
      ..quadraticBezierTo(cx - 88 * scale, cy + 10 * scale, cx - 82 * scale, cy + 58 * scale)
      ..quadraticBezierTo(cx - 70 * scale, cy + 70 * scale, cx - 56 * scale, cy + 58 * scale)
      ..quadraticBezierTo(cx - 42 * scale, cy + 70 * scale, cx - 28 * scale, cy + 58 * scale)
      ..quadraticBezierTo(cx - 14 * scale, cy + 70 * scale, cx, cy + 56 * scale)
      ..quadraticBezierTo(cx + 14 * scale, cy + 70 * scale, cx + 28 * scale, cy + 58 * scale)
      ..quadraticBezierTo(cx + 42 * scale, cy + 70 * scale, cx + 56 * scale, cy + 58 * scale)
      ..quadraticBezierTo(cx + 70 * scale, cy + 70 * scale, cx + 82 * scale, cy + 58 * scale)
      ..quadraticBezierTo(cx + 88 * scale, cy + 10 * scale, cx + 48 * scale, cy - 20 * scale)
      ..quadraticBezierTo(cx, cy - 8 * scale, cx - 48 * scale, cy - 20 * scale)
      ..close();
    canvas.drawPath(cape, capeFill);
    canvas.drawPath(cape, stroke);

    if (item.id == 'rainbow_scarf') {
      for (final dir in [-1.0, 1.0]) {
        for (var i = 0; i < colors.length; i++) {
          canvas.drawLine(
            Offset(cx + dir * (44 + i * 8) * scale, cy - 10 * scale),
            Offset(cx + dir * (58 + i * 10) * scale, cy + 44 * scale),
            Paint()
              ..color = colors[i]
              ..strokeWidth = 4 * scale
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    }
  }

  void _drawWings(Canvas canvas, double cx, double cy, double scale) {
    final fill = Paint()..color = const Color(0xFFFFFBFF);
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;

    for (final dir in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(cx + dir * 58 * scale, cy - 2 * scale)
        ..quadraticBezierTo(
          cx + dir * 92 * scale,
          cy - 48 * scale,
          cx + dir * 98 * scale,
          cy + 4 * scale,
        )
        ..quadraticBezierTo(
          cx + dir * 94 * scale,
          cy + 34 * scale,
          cx + dir * 74 * scale,
          cy + 32 * scale,
        )
        ..quadraticBezierTo(
          cx + dir * 84 * scale,
          cy + 10 * scale,
          cx + dir * 64 * scale,
          cy + 12 * scale,
        )
        ..quadraticBezierTo(
          cx + dir * 68 * scale,
          cy + 2 * scale,
          cx + dir * 58 * scale,
          cy - 2 * scale,
        );
      canvas.drawPath(wing, fill);
      canvas.drawPath(wing, stroke);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + dir * 86 * scale, cy - 14 * scale),
          width: 14 * scale,
          height: 18 * scale,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  void _drawMustache(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    CosmeticDef item,
  ) {
    final fill = Paint()..color = item.accent;
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale;
    final stache = Path()
      ..moveTo(cx - 26 * scale, cy + 14 * scale)
      ..quadraticBezierTo(cx - 14 * scale, cy + 28 * scale, cx, cy + 16 * scale)
      ..quadraticBezierTo(cx + 14 * scale, cy + 28 * scale, cx + 26 * scale, cy + 14 * scale)
      ..quadraticBezierTo(cx + 10 * scale, cy + 20 * scale, cx, cy + 14 * scale)
      ..quadraticBezierTo(cx - 10 * scale, cy + 20 * scale, cx - 26 * scale, cy + 14 * scale)
      ..close();
    canvas.drawPath(stache, fill);
    canvas.drawPath(stache, stroke);
  }

  void _drawProp(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    CosmeticDef item, {
    required bool hasHat,
  }) {
    final fill = Paint()..color = item.accent;
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    // Float halo / antenna / horns above hat when one is equipped
    final topLift = hasHat ? 28.0 : 0.0;

    switch (item.id) {
      case 'bandage':
        final b = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + 52 * scale, cy + 8 * scale),
            width: 30 * scale,
            height: 16 * scale,
          ),
          Radius.circular(4 * scale),
        );
        canvas.drawRRect(b, fill);
        canvas.drawRRect(b, stroke);
        canvas.drawLine(
          Offset(cx + 42 * scale, cy + 8 * scale),
          Offset(cx + 62 * scale, cy + 8 * scale),
          stroke,
        );
        canvas.drawLine(
          Offset(cx + 52 * scale, cy + 2 * scale),
          Offset(cx + 52 * scale, cy + 14 * scale),
          stroke,
        );
      case 'flower':
        final fx = cx + 28 * scale;
        final fy = cy - (50 + topLift) * scale;
        for (var i = 0; i < 5; i++) {
          final a = i * 1.256;
          canvas.drawCircle(
            Offset(fx + math.cos(a) * 9 * scale, fy + math.sin(a) * 9 * scale),
            6.5 * scale,
            fill,
          );
        }
        canvas.drawCircle(Offset(fx, fy), 5 * scale, Paint()..color = BuddyColors.lemon);
        canvas.drawCircle(Offset(fx, fy), 5 * scale, stroke);
      case 'halo':
        final hy = cy - (78 + topLift) * scale;
        final haloFill = Paint()
          ..color = item.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * scale;
        final haloRect = Rect.fromCenter(
          center: Offset(cx, hy),
          width: 56 * scale,
          height: 18 * scale,
        );
        canvas.drawOval(haloRect, haloFill);
        canvas.drawOval(haloRect, stroke);
        // Soft highlight on left
        canvas.drawArc(
          haloRect.deflate(2 * scale),
          math.pi * 0.85,
          math.pi * 0.35,
          false,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.75)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 * scale
            ..strokeCap = StrokeCap.round,
        );
      case 'antenna':
        final ay = cy - (48 + topLift) * scale;
        canvas.drawLine(
          Offset(cx - 8 * scale, ay),
          Offset(cx - 22 * scale, ay - 36 * scale),
          stroke,
        );
        canvas.drawLine(
          Offset(cx + 8 * scale, ay),
          Offset(cx + 22 * scale, ay - 36 * scale),
          stroke,
        );
        canvas.drawCircle(Offset(cx - 22 * scale, ay - 38 * scale), 7 * scale, fill);
        canvas.drawCircle(Offset(cx + 22 * scale, ay - 38 * scale), 7 * scale, fill);
        canvas.drawCircle(Offset(cx - 22 * scale, ay - 38 * scale), 7 * scale, stroke);
        canvas.drawCircle(Offset(cx + 22 * scale, ay - 38 * scale), 7 * scale, stroke);
      case 'legend_horns':
      case 'devil_horns':
        final hy = cy - (44 + topLift) * scale;
        for (final dir in [-1.0, 1.0]) {
          final horn = Path()
            ..moveTo(cx + dir * 14 * scale, hy)
            ..lineTo(cx + dir * 28 * scale, hy - 40 * scale)
            ..lineTo(cx + dir * 4 * scale, hy - 8 * scale)
            ..close();
          canvas.drawPath(horn, fill);
          canvas.drawPath(horn, stroke);
        }
      case 'leaf_pin':
        final leaf = Path()
          ..moveTo(cx + 48 * scale, cy - 8 * scale)
          ..quadraticBezierTo(
            cx + 72 * scale,
            cy - 28 * scale,
            cx + 68 * scale,
            cy + 6 * scale,
          )
          ..quadraticBezierTo(
            cx + 58 * scale,
            cy + 4 * scale,
            cx + 48 * scale,
            cy - 8 * scale,
          );
        canvas.drawPath(leaf, fill);
        canvas.drawPath(leaf, stroke);
        canvas.drawLine(
          Offset(cx + 50 * scale, cy - 6 * scale),
          Offset(cx + 64 * scale, cy - 10 * scale),
          stroke,
        );
      case 'star_stud':
        final star = Path();
        for (var i = 0; i < 5; i++) {
          final a = -math.pi / 2 + i * 4 * math.pi / 5;
          final p = Offset(
            cx - 55 * scale + math.cos(a) * 12 * scale,
            cy - 20 * scale + math.sin(a) * 12 * scale,
          );
          if (i == 0) {
            star.moveTo(p.dx, p.dy);
          } else {
            star.lineTo(p.dx, p.dy);
          }
        }
        star.close();
        canvas.drawPath(star, fill);
        canvas.drawPath(star, stroke);
      case 'sparkle_aura':
        for (final o in [
          Offset(cx - 70 * scale, cy - 30 * scale),
          Offset(cx + 70 * scale, cy - 24 * scale),
          Offset(cx - 60 * scale, cy + 40 * scale),
          Offset(cx + 62 * scale, cy + 36 * scale),
          Offset(cx, cy - (68 + topLift) * scale),
        ]) {
          canvas.drawCircle(o, 3.5 * scale, fill);
          canvas.drawCircle(o, 3.5 * scale, stroke);
        }
      default:
        break;
    }
  }

  void _drawScarf(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    CosmeticDef item,
  ) {
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    final fill = Paint()..color = item.accent;

    final band = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy - 36 * scale),
        width: 44 * scale,
        height: 16 * scale,
      ),
      Radius.circular(8 * scale),
    );
    final tail = Path()
      ..moveTo(cx + 18 * scale, cy - 34 * scale)
      ..quadraticBezierTo(
        cx + 58 * scale,
        cy - 10 * scale,
        cx + 54 * scale,
        cy + 28 * scale,
      )
      ..quadraticBezierTo(
        cx + 44 * scale,
        cy + 2 * scale,
        cx + 20 * scale,
        cy - 28 * scale,
      )
      ..close();
    canvas.drawRRect(band, fill);
    canvas.drawRRect(band, stroke);
    canvas.drawPath(tail, fill);
    canvas.drawPath(tail, stroke);
  }

  void _drawGlasses(
    Canvas canvas,
    double cx,
    double eyeY,
    double scale,
    CosmeticDef item,
  ) {
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    final lens = Paint()..color = item.accent.withValues(alpha: 0.45);

    if (item.id == 'monocle') {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + 28 * scale, eyeY),
          width: 30 * scale,
          height: 30 * scale,
        ),
        Radius.circular(15 * scale),
      );
      canvas.drawRRect(r, lens);
      canvas.drawRRect(r, stroke);
      canvas.drawLine(
        Offset(cx + 43 * scale, eyeY + 10 * scale),
        Offset(cx + 43 * scale, eyeY + 34 * scale),
        stroke,
      );
      return;
    }

    if (item.id == 'heart_specs') {
      for (final ox in [-28.0, 28.0]) {
        final heart = Path()
          ..moveTo(cx + ox * scale, eyeY + 12 * scale)
          ..cubicTo(
            cx + (ox - 16) * scale,
            eyeY + 2 * scale,
            cx + (ox - 14) * scale,
            eyeY - 12 * scale,
            cx + ox * scale,
            eyeY - 4 * scale,
          )
          ..cubicTo(
            cx + (ox + 14) * scale,
            eyeY - 12 * scale,
            cx + (ox + 16) * scale,
            eyeY + 2 * scale,
            cx + ox * scale,
            eyeY + 12 * scale,
          );
        canvas.drawPath(heart, lens);
        canvas.drawPath(heart, stroke);
      }
      canvas.drawLine(Offset(cx - 14 * scale, eyeY), Offset(cx + 14 * scale, eyeY), stroke);
      return;
    }

    if (item.id == 'sun_visors') {
      final wrap = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, eyeY - 2 * scale),
          width: 92 * scale,
          height: 16 * scale,
        ),
        Radius.circular(8 * scale),
      );
      canvas.drawRRect(wrap, lens);
      canvas.drawRRect(wrap, stroke);
      return;
    }

    for (final ox in [-28.0, 28.0]) {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + ox * scale, eyeY),
          width: 30 * scale,
          height: 22 * scale,
        ),
        Radius.circular(item.id == 'diamond_shades' ? 4 * scale : 6 * scale),
      );
      canvas.drawRRect(r, lens);
      canvas.drawRRect(r, stroke);
      if (item.id == 'diamond_shades') {
        canvas.drawCircle(
          Offset(cx + (ox - 6) * scale, eyeY - 4 * scale),
          2.5 * scale,
          Paint()..color = Colors.white.withValues(alpha: 0.7),
        );
      }
    }
    canvas.drawLine(
      Offset(cx - 14 * scale, eyeY),
      Offset(cx + 14 * scale, eyeY),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant LungPainter oldDelegate) {
    return oldDelegate.smokeRatio != smokeRatio ||
        oldDelegate.coughPhase != coughPhase ||
        oldDelegate.flowPhase != flowPhase ||
        oldDelegate.loadout.hatId != loadout.hatId ||
        oldDelegate.loadout.eyesId != loadout.eyesId ||
        oldDelegate.loadout.backId != loadout.backId ||
        oldDelegate.loadout.faceId != loadout.faceId;
  }
}
