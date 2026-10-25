import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Soft candy gradient + floating doodle blobs.
class PlayfulBackdrop extends StatelessWidget {
  const PlayfulBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                BuddyColors.skyTop,
                BuddyColors.skyBottom,
                Color(0xFFB8F0FF),
              ],
            ),
          ),
        ),
        CustomPaint(painter: _DoodlePainter()),
        child,
      ],
    );
  }
}

class _DoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    for (var i = 0; i < 14; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 8 + rng.nextDouble() * 28;
      final colors = [
        BuddyColors.mint.withValues(alpha: 0.35),
        BuddyColors.lemon.withValues(alpha: 0.4),
        BuddyColors.grape.withValues(alpha: 0.22),
        Colors.white.withValues(alpha: 0.35),
      ];
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StickerBadge extends StatelessWidget {
  const StickerBadge({
    super.key,
    required this.label,
    this.color = BuddyColors.lemon,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.04,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BuddyColors.ink, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x331A1028),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: BuddyColors.ink),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class CartoonProgressBar extends StatelessWidget {
  const CartoonProgressBar({
    super.key,
    required this.value,
    required this.over,
  });

  final double value;
  final bool over;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BuddyColors.ink, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          alignment: Alignment.centerLeft,
          child: ColoredBox(
            color: over ? BuddyColors.grape : BuddyColors.mint,
          ),
        ),
      ),
    );
  }
}

class BoomButton extends StatelessWidget {
  const BoomButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: BuddyColors.bubblegum,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: const BorderSide(color: BuddyColors.ink, width: 4),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
