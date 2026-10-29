import 'package:flutter/material.dart';

import '../../domain/cosmetic_loadout.dart';
import '../../theme/app_theme.dart';
import '../home/lung_painter.dart';

/// Static buddy snapshot for widget / icon rendering.
class BuddyRender extends StatelessWidget {
  const BuddyRender({
    super.key,
    this.size = 160,
    this.smokeRatio = 0.08,
    this.loadout = CosmeticLoadout.empty,
    this.backgroundColor = BuddyColors.cream,
    this.showBackground = true,
  });

  final double size;
  final double smokeRatio;
  final CosmeticLoadout loadout;
  final Color backgroundColor;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BuddyBackdropPainter(
          smokeRatio: smokeRatio,
          loadout: loadout,
          backgroundColor: backgroundColor,
          showBackground: showBackground,
        ),
      ),
    );
  }
}

class _BuddyBackdropPainter extends CustomPainter {
  _BuddyBackdropPainter({
    required this.smokeRatio,
    required this.loadout,
    required this.backgroundColor,
    required this.showBackground,
  });

  final double smokeRatio;
  final CosmeticLoadout loadout;
  final Color backgroundColor;
  final bool showBackground;

  @override
  void paint(Canvas canvas, Size size) {
    if (showBackground) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(size.width * 0.18),
        ),
        Paint()..color = backgroundColor,
      );
    }
    LungPainter(
      smokeRatio: smokeRatio,
      coughPhase: 0,
      loadout: loadout,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _BuddyBackdropPainter oldDelegate) {
    return oldDelegate.smokeRatio != smokeRatio ||
        oldDelegate.loadout.hatId != loadout.hatId ||
        oldDelegate.loadout.eyesId != loadout.eyesId ||
        oldDelegate.loadout.backId != loadout.backId ||
        oldDelegate.loadout.faceId != loadout.faceId ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.showBackground != showBackground;
  }
}
