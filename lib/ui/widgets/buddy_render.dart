import 'package:flutter/material.dart';

import '../../domain/cosmetic_catalog.dart';
import '../../theme/app_theme.dart';
import '../home/lung_painter.dart';

/// Static buddy snapshot for widget / icon rendering.
class BuddyRender extends StatelessWidget {
  const BuddyRender({
    super.key,
    this.size = 160,
    this.smokeRatio = 0.08,
    this.cosmetic = CosmeticCatalog.none,
    this.backgroundColor = BuddyColors.cream,
    this.showBackground = true,
  });

  final double size;
  final double smokeRatio;
  final CosmeticDef cosmetic;
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
          cosmetic: cosmetic,
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
    required this.cosmetic,
    required this.backgroundColor,
    required this.showBackground,
  });

  final double smokeRatio;
  final CosmeticDef cosmetic;
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
      cosmetic: cosmetic,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _BuddyBackdropPainter oldDelegate) {
    return oldDelegate.smokeRatio != smokeRatio ||
        oldDelegate.cosmetic.id != cosmetic.id ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.showBackground != showBackground;
  }
}
