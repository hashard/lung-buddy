import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/cosmetic_catalog.dart';
import '../../theme/app_theme.dart';
import '../widgets/cartoon_chrome.dart';
import 'lung_painter.dart';

class MascotView extends StatefulWidget {
  const MascotView({
    super.key,
    required this.name,
    required this.line,
    required this.count,
    required this.budget,
    this.triggerCough = false,
    this.cosmetic = CosmeticCatalog.none,
  });

  final String name;
  final String line;
  final int count;
  final int budget;
  final bool triggerCough;
  final CosmeticDef cosmetic;

  @override
  State<MascotView> createState() => _MascotViewState();
}

class _MascotViewState extends State<MascotView>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _cough;
  late final AnimationController _flow;
  Timer? _autoCoughTimer;
  bool _showCoughLabel = false;

  double get _ratio {
    if (widget.budget <= 0) return 0;
    return widget.count / widget.budget;
  }

  bool get _overBudget => widget.count > widget.budget;

  Duration get _coughInterval {
    final r = _ratio;
    if (r < 0.15) return const Duration(days: 1);
    if (r < 0.35) return const Duration(seconds: 14);
    if (r < 0.55) return const Duration(seconds: 8);
    if (r < 0.8) return const Duration(seconds: 5);
    return const Duration(seconds: 3);
  }

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _cough = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _flow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _cough.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showCoughLabel = false);
        _cough.reset();
      }
    });
    _updateFlow();
    _scheduleAutoCough();
  }

  @override
  void didUpdateWidget(covariant MascotView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerCough && !oldWidget.triggerCough) {
      _playCough();
    }
    if (widget.count != oldWidget.count || widget.budget != oldWidget.budget) {
      _updateFlow();
      _scheduleAutoCough();
    }
  }

  void _updateFlow() {
    if (_overBudget) {
      if (!_flow.isAnimating) _flow.repeat();
    } else {
      _flow
        ..stop()
        ..value = 0;
    }
  }

  void _scheduleAutoCough() {
    _autoCoughTimer?.cancel();
    if (_ratio < 0.15) return;
    _autoCoughTimer = Timer.periodic(_coughInterval, (_) {
      if (!mounted) return;
      if (!_cough.isAnimating) _playCough();
    });
  }

  void _playCough() {
    setState(() => _showCoughLabel = true);
    _cough.forward(from: 0);
  }

  @override
  void dispose() {
    _autoCoughTimer?.cancel();
    _idle.dispose();
    _cough.dispose();
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bob = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _idle, curve: Curves.easeInOut),
    );

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: AnimatedBuilder(
            animation: Listenable.merge([_idle, _cough, _flow]),
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, bob.value * (1 - _ratio.clamp(0.0, 0.8))),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: const Size(250, 250),
                      painter: LungPainter(
                        smokeRatio: _ratio,
                        coughPhase: _cough.value,
                        flowPhase: _flow.value,
                        cosmetic: widget.cosmetic,
                      ),
                    ),
                    if (_showCoughLabel)
                      Positioned(
                        right: 0,
                        top: 18 + (_cough.value * 12),
                        child: Opacity(
                          opacity: (1 - _cough.value).clamp(0.0, 1.0),
                          child: Transform.rotate(
                            angle: -0.12,
                            child: StickerBadge(
                              label: _coughWord(),
                              color: BuddyColors.lemon,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Text(
          widget.name.toUpperCase(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            widget.line,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  String _coughWord() {
    if (_ratio > 1.0) return 'HACK!!';
    if (_ratio > 0.7) return 'COUGH!';
    return 'ahem';
  }
}
