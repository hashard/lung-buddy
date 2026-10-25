import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/cosmetic_catalog.dart';
import '../../theme/app_theme.dart';

/// Goofy sticker-book lung. [smokeRatio] 0 = candy pink, 1+ = soot monster.
class LungPainter extends CustomPainter {
  LungPainter({
    required this.smokeRatio,
    required this.coughPhase,
    this.flowPhase = 0,
    this.cosmetic = CosmeticCatalog.none,
  });

  final double smokeRatio;
  final double coughPhase;
  final double flowPhase;
  final CosmeticDef cosmetic;

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
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * scale
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

    // Trachea (chunky)
    final trach = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy - 58 * scale),
        width: 28 * scale,
        height: 34 * scale,
      ),
      Radius.circular(12 * scale),
    );
    canvas.drawRRect(trach, bodyPaint);
    canvas.drawRRect(trach, stroke);

    // Lobes — rounder, beanier
    final left = Path()
      ..moveTo(cx - 6 * scale, cy - 36 * scale)
      ..cubicTo(
        cx - 78 * scale,
        cy - 55 * scale,
        cx - 105 * scale,
        cy + 8 * scale,
        cx - 58 * scale,
        cy + 58 * scale,
      )
      ..cubicTo(
        cx - 28 * scale,
        cy + 78 * scale,
        cx - 8 * scale,
        cy + 42 * scale,
        cx - 4 * scale,
        cy - 6 * scale,
      )
      ..close();
    final right = Path()
      ..moveTo(cx + 6 * scale, cy - 36 * scale)
      ..cubicTo(
        cx + 78 * scale,
        cy - 55 * scale,
        cx + 105 * scale,
        cy + 8 * scale,
        cx + 58 * scale,
        cy + 58 * scale,
      )
      ..cubicTo(
        cx + 28 * scale,
        cy + 78 * scale,
        cx + 8 * scale,
        cy + 42 * scale,
        cx + 4 * scale,
        cy - 6 * scale,
      )
      ..close();

    canvas.drawPath(left, bodyPaint);
    canvas.drawPath(right, bodyPaint);
    canvas.drawPath(left, stroke);
    canvas.drawPath(right, stroke);

    // Belly highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 22 * scale, cy + 18 * scale),
        width: 28 * scale,
        height: 18 * scale,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22 * (1 - t.clamp(0, 1))),
    );

    if (cosmetic.kind == CosmeticKind.scarf) {
      _drawScarf(canvas, cx, cy, scale);
    }
    if (cosmetic.kind == CosmeticKind.hat) {
      _drawHat(canvas, cx, cy, scale);
    }
    if (cosmetic.kind == CosmeticKind.prop) {
      _drawProp(canvas, cx, cy, scale);
    }

    // Blush
    final blushA = (0.45 * (1 - t.clamp(0.0, 1.0))).clamp(0.0, 0.45);
    final blush = Paint()..color = const Color(0xFFFF4D88).withValues(alpha: blushA);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 48 * scale, cy + 10 * scale),
        width: 22 * scale,
        height: 14 * scale,
      ),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 48 * scale, cy + 10 * scale),
        width: 22 * scale,
        height: 14 * scale,
      ),
      blush,
    );

    // Giant cartoon eyes
    final eyeY = cy - 6 * scale;
    final eyeR = 14 * scale;
    final eyeFill = Paint()..color = Colors.white;
    final eyeStroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    canvas.drawCircle(Offset(cx - 30 * scale, eyeY), eyeR, eyeFill);
    canvas.drawCircle(Offset(cx + 30 * scale, eyeY), eyeR, eyeFill);
    canvas.drawCircle(Offset(cx - 30 * scale, eyeY), eyeR, eyeStroke);
    canvas.drawCircle(Offset(cx + 30 * scale, eyeY), eyeR, eyeStroke);

    if (t > 0.78 || (coughPhase > 0.15 && coughPhase < 0.55)) {
      // X / dizzy eyes when rough
      final xPaint = Paint()
        ..color = outline
        ..strokeWidth = 4 * scale
        ..strokeCap = StrokeCap.round;
      for (final ox in [-30.0, 30.0]) {
        canvas.drawLine(
          Offset(cx + (ox - 7) * scale, eyeY - 7 * scale),
          Offset(cx + (ox + 7) * scale, eyeY + 7 * scale),
          xPaint,
        );
        canvas.drawLine(
          Offset(cx + (ox + 7) * scale, eyeY - 7 * scale),
          Offset(cx + (ox - 7) * scale, eyeY + 7 * scale),
          xPaint,
        );
      }
    } else {
      final pupil = Paint()..color = outline;
      final look = t > 0.5 ? 2.0 * scale : 0.0;
      canvas.drawCircle(Offset(cx - 30 * scale + look, eyeY + 2 * scale), 6 * scale, pupil);
      canvas.drawCircle(Offset(cx + 30 * scale + look, eyeY + 2 * scale), 6 * scale, pupil);
      final shine = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(cx - 33 * scale + look, eyeY - 2 * scale), 2.4 * scale, shine);
      canvas.drawCircle(Offset(cx + 27 * scale + look, eyeY - 2 * scale), 2.4 * scale, shine);
    }

    if (cosmetic.kind == CosmeticKind.glasses) {
      _drawGlasses(canvas, cx, eyeY, scale);
    }

    // Mouth
    final mouthPaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 * scale
      ..strokeCap = StrokeCap.round;

    if (coughPhase > 0.12 && coughPhase < 0.6 && t > 0.08) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 28 * scale),
          width: 22 * scale,
          height: 20 * scale,
        ),
        Paint()..color = const Color(0xFF1A1028),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 30 * scale),
          width: 12 * scale,
          height: 8 * scale,
        ),
        Paint()..color = const Color(0xFFFF6BB5),
      );
    } else if (t < 0.28) {
      final smile = Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(cx, cy + 24 * scale),
            width: 44 * scale,
            height: 34 * scale,
          ),
          0.12 * math.pi,
          0.76 * math.pi,
        );
      canvas.drawPath(smile, mouthPaint);
    } else if (t < 0.6) {
      canvas.drawLine(
        Offset(cx - 14 * scale, cy + 28 * scale),
        Offset(cx + 14 * scale, cy + 28 * scale),
        mouthPaint,
      );
    } else {
      final frown = Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(cx, cy + 36 * scale),
            width: 34 * scale,
            height: 22 * scale,
          ),
          1.1 * math.pi,
          0.8 * math.pi,
        );
      canvas.drawPath(frown, mouthPaint);
    }

    // Comic cough clouds
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

  void _drawHat(Canvas canvas, double cx, double cy, double scale) {
    final fill = Paint()..color = cosmetic.accent;
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    switch (cosmetic.id) {
      case 'beanie_mint':
        final path = Path()
          ..moveTo(cx - 34 * scale, cy - 68 * scale)
          ..quadraticBezierTo(cx, cy - 108 * scale, cx + 34 * scale, cy - 68 * scale)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
        canvas.drawCircle(Offset(cx, cy - 106 * scale), 7 * scale, fill);
        canvas.drawCircle(Offset(cx, cy - 106 * scale), 7 * scale, stroke);
      case 'bow_coral':
        for (final dx in [-12.0, 12.0]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(cx + dx * scale, cy - 80 * scale),
              width: 20 * scale,
              height: 16 * scale,
            ),
            fill,
          );
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(cx + dx * scale, cy - 80 * scale),
              width: 20 * scale,
              height: 16 * scale,
            ),
            stroke,
          );
        }
        canvas.drawCircle(Offset(cx, cy - 80 * scale), 5.5 * scale, fill);
        canvas.drawCircle(Offset(cx, cy - 80 * scale), 5.5 * scale, stroke);
      case 'top_hat':
        final hat = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 98 * scale),
            width: 32 * scale,
            height: 30 * scale,
          ),
          Radius.circular(4 * scale),
        );
        final brim = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 78 * scale),
            width: 52 * scale,
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
            center: Offset(cx, cy - 88 * scale),
            width: 32 * scale,
            height: 6 * scale,
          ),
          Paint()..color = BuddyColors.bubblegum,
        );
      case 'party_crown':
      case 'golden_crown':
        final crown = Path()
          ..moveTo(cx - 28 * scale, cy - 72 * scale)
          ..lineTo(cx - 18 * scale, cy - 104 * scale)
          ..lineTo(cx - 8 * scale, cy - 80 * scale)
          ..lineTo(cx, cy - 110 * scale)
          ..lineTo(cx + 8 * scale, cy - 80 * scale)
          ..lineTo(cx + 18 * scale, cy - 104 * scale)
          ..lineTo(cx + 28 * scale, cy - 72 * scale)
          ..close();
        canvas.drawPath(crown, fill);
        canvas.drawPath(crown, stroke);
      case 'couch_hat':
        final couch = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 86 * scale),
            width: 56 * scale,
            height: 22 * scale,
          ),
          Radius.circular(8 * scale),
        );
        canvas.drawRRect(couch, fill);
        canvas.drawRRect(couch, stroke);
      case 'pirate_bandana':
        final band = Path()
          ..moveTo(cx - 40 * scale, cy - 70 * scale)
          ..lineTo(cx + 36 * scale, cy - 78 * scale)
          ..lineTo(cx + 40 * scale, cy - 62 * scale)
          ..lineTo(cx - 36 * scale, cy - 54 * scale)
          ..close();
        canvas.drawPath(band, fill);
        canvas.drawPath(band, stroke);
      case 'frog_hat':
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, cy - 88 * scale),
            width: 54 * scale,
            height: 34 * scale,
          ),
          fill,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, cy - 88 * scale),
            width: 54 * scale,
            height: 34 * scale,
          ),
          stroke,
        );
        canvas.drawCircle(Offset(cx - 18 * scale, cy - 102 * scale), 8 * scale, fill);
        canvas.drawCircle(Offset(cx + 18 * scale, cy - 102 * scale), 8 * scale, fill);
        canvas.drawCircle(Offset(cx - 18 * scale, cy - 102 * scale), 8 * scale, stroke);
        canvas.drawCircle(Offset(cx + 18 * scale, cy - 102 * scale), 8 * scale, stroke);
      case 'sleepy_cap':
        final cap = Path()
          ..moveTo(cx - 36 * scale, cy - 68 * scale)
          ..quadraticBezierTo(cx, cy - 112 * scale, cx + 30 * scale, cy - 74 * scale)
          ..quadraticBezierTo(cx + 48 * scale, cy - 70 * scale, cx + 44 * scale, cy - 58 * scale)
          ..lineTo(cx - 34 * scale, cy - 56 * scale)
          ..close();
        canvas.drawPath(cap, fill);
        canvas.drawPath(cap, stroke);
      default:
        break;
    }
  }

  void _drawProp(Canvas canvas, double cx, double cy, double scale) {
    final fill = Paint()..color = cosmetic.accent;
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    switch (cosmetic.id) {
      case 'bandage':
        final b = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + 36 * scale, cy - 18 * scale),
            width: 28 * scale,
            height: 14 * scale,
          ),
          Radius.circular(4 * scale),
        );
        canvas.drawRRect(b, fill);
        canvas.drawRRect(b, stroke);
        canvas.drawLine(
          Offset(cx + 28 * scale, cy - 18 * scale),
          Offset(cx + 44 * scale, cy - 18 * scale),
          stroke,
        );
      case 'flower':
        for (var i = 0; i < 5; i++) {
          final a = i * 1.256;
          canvas.drawCircle(
            Offset(cx + math.cos(a) * 10 * scale, cy - 90 * scale + math.sin(a) * 10 * scale),
            7 * scale,
            fill,
          );
        }
        canvas.drawCircle(Offset(cx, cy - 90 * scale), 5 * scale, Paint()..color = BuddyColors.lemon);
        canvas.drawCircle(Offset(cx, cy - 90 * scale), 5 * scale, stroke);
      case 'halo':
        final halo = Paint()
          ..color = cosmetic.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * scale;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, cy - 100 * scale),
            width: 48 * scale,
            height: 16 * scale,
          ),
          halo,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, cy - 100 * scale),
            width: 48 * scale,
            height: 16 * scale,
          ),
          stroke,
        );
      case 'antenna':
        canvas.drawLine(
          Offset(cx - 10 * scale, cy - 74 * scale),
          Offset(cx - 18 * scale, cy - 108 * scale),
          stroke,
        );
        canvas.drawLine(
          Offset(cx + 10 * scale, cy - 74 * scale),
          Offset(cx + 18 * scale, cy - 108 * scale),
          stroke,
        );
        canvas.drawCircle(Offset(cx - 18 * scale, cy - 110 * scale), 6 * scale, fill);
        canvas.drawCircle(Offset(cx + 18 * scale, cy - 110 * scale), 6 * scale, fill);
        canvas.drawCircle(Offset(cx - 18 * scale, cy - 110 * scale), 6 * scale, stroke);
        canvas.drawCircle(Offset(cx + 18 * scale, cy - 110 * scale), 6 * scale, stroke);
      case 'mustache':
        final stache = Path()
          ..moveTo(cx - 22 * scale, cy + 22 * scale)
          ..quadraticBezierTo(cx - 8 * scale, cy + 34 * scale, cx, cy + 24 * scale)
          ..quadraticBezierTo(cx + 8 * scale, cy + 34 * scale, cx + 22 * scale, cy + 22 * scale);
        canvas.drawPath(stache, stroke);
      case 'legend_horns':
      case 'devil_horns':
        for (final dir in [-1.0, 1.0]) {
          final horn = Path()
            ..moveTo(cx + dir * 22 * scale, cy - 70 * scale)
            ..lineTo(cx + dir * 34 * scale, cy - 108 * scale)
            ..lineTo(cx + dir * 12 * scale, cy - 78 * scale)
            ..close();
          canvas.drawPath(horn, fill);
          canvas.drawPath(horn, stroke);
        }
      case 'angel_wings':
        for (final dir in [-1.0, 1.0]) {
          final wing = Path()
            ..moveTo(cx + dir * 40 * scale, cy + 8 * scale)
            ..quadraticBezierTo(
              cx + dir * 80 * scale,
              cy - 20 * scale,
              cx + dir * 70 * scale,
              cy + 30 * scale,
            )
            ..quadraticBezierTo(
              cx + dir * 55 * scale,
              cy + 18 * scale,
              cx + dir * 40 * scale,
              cy + 8 * scale,
            );
          canvas.drawPath(wing, fill);
          canvas.drawPath(wing, stroke);
        }
      default:
        break;
    }
  }

  void _drawScarf(Canvas canvas, double cx, double cy, double scale) {
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;

    if (cosmetic.id == 'streak_cape' || cosmetic.id == 'rainbow_scarf') {
      final capeFill = Paint()..color = cosmetic.accent;
      final cape = Path()
        ..moveTo(cx - 28 * scale, cy - 40 * scale)
        ..lineTo(cx + 28 * scale, cy - 40 * scale)
        ..lineTo(cx + 48 * scale, cy + 50 * scale)
        ..quadraticBezierTo(cx, cy + 70 * scale, cx - 48 * scale, cy + 50 * scale)
        ..close();
      canvas.drawPath(cape, capeFill);
      canvas.drawPath(cape, stroke);
      if (cosmetic.id == 'rainbow_scarf') {
        final stripes = [
          const Color(0xFFFF4D6D),
          const Color(0xFFFFE566),
          const Color(0xFF7DFFB3),
          const Color(0xFF7B5CFF),
        ];
        for (var i = 0; i < stripes.length; i++) {
          canvas.drawLine(
            Offset(cx - 20 * scale + i * 8 * scale, cy - 20 * scale),
            Offset(cx - 30 * scale + i * 10 * scale, cy + 40 * scale),
            Paint()
              ..color = stripes[i]
              ..strokeWidth = 5 * scale
              ..strokeCap = StrokeCap.round,
          );
        }
      }
      return;
    }

    final fill = Paint()..color = cosmetic.accent;
    final band = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy - 46 * scale),
        width: 56 * scale,
        height: 18 * scale,
      ),
      Radius.circular(8 * scale),
    );
    final tail = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + 10 * scale, cy - 42 * scale, 16 * scale, 42 * scale),
      Radius.circular(6 * scale),
    );
    canvas.drawRRect(band, fill);
    canvas.drawRRect(band, stroke);
    canvas.drawRRect(tail, fill);
    canvas.drawRRect(tail, stroke);
  }

  void _drawGlasses(Canvas canvas, double cx, double eyeY, double scale) {
    final stroke = Paint()
      ..color = BuddyColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    final lens = Paint()..color = cosmetic.accent.withValues(alpha: 0.45);

    if (cosmetic.id == 'monocle') {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + 30 * scale, eyeY),
          width: 28 * scale,
          height: 28 * scale,
        ),
        Radius.circular(14 * scale),
      );
      canvas.drawRRect(r, lens);
      canvas.drawRRect(r, stroke);
      canvas.drawLine(
        Offset(cx + 44 * scale, eyeY + 10 * scale),
        Offset(cx + 44 * scale, eyeY + 34 * scale),
        stroke,
      );
      return;
    }

    if (cosmetic.id == 'heart_specs') {
      for (final ox in [-30.0, 30.0]) {
        canvas.drawCircle(Offset(cx + (ox - 5) * scale, eyeY - 2 * scale), 8 * scale, lens);
        canvas.drawCircle(Offset(cx + (ox + 5) * scale, eyeY - 2 * scale), 8 * scale, lens);
        final heart = Path()
          ..moveTo(cx + ox * scale, eyeY + 10 * scale)
          ..lineTo(cx + (ox - 12) * scale, eyeY - 2 * scale)
          ..lineTo(cx + (ox + 12) * scale, eyeY - 2 * scale)
          ..close();
        canvas.drawPath(heart, lens);
        canvas.drawCircle(Offset(cx + (ox - 5) * scale, eyeY - 2 * scale), 8 * scale, stroke);
        canvas.drawCircle(Offset(cx + (ox + 5) * scale, eyeY - 2 * scale), 8 * scale, stroke);
      }
      canvas.drawLine(Offset(cx - 16 * scale, eyeY), Offset(cx + 16 * scale, eyeY), stroke);
      return;
    }

    for (final ox in [-30.0, 30.0]) {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + ox * scale, eyeY),
          width: cosmetic.id == 'sun_visors' ? 30 * scale : 28 * scale,
          height: cosmetic.id == 'sun_visors' ? 14 * scale : 20 * scale,
        ),
        Radius.circular(6 * scale),
      );
      canvas.drawRRect(r, lens);
      canvas.drawRRect(r, stroke);
    }
    canvas.drawLine(
      Offset(cx - 16 * scale, eyeY),
      Offset(cx + 16 * scale, eyeY),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant LungPainter oldDelegate) {
    return oldDelegate.smokeRatio != smokeRatio ||
        oldDelegate.coughPhase != coughPhase ||
        oldDelegate.flowPhase != flowPhase ||
        oldDelegate.cosmetic.id != cosmetic.id;
  }
}
