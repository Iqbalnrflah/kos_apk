import 'package:flutter/material.dart';

class GenieTransition extends StatefulWidget {
  final bool visible;
  final Widget child;
  final Alignment origin; // posisi tombol chat

  const GenieTransition({
    super.key,
    required this.visible,
    required this.child,
    this.origin = Alignment.bottomRight,
  });

  @override
  State<GenieTransition> createState() => _GenieTransitionState();
}

class _GenieTransitionState extends State<GenieTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    reverseDuration: const Duration(milliseconds: 350),
  );

  late final Animation<double> _scaleY = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    reverseCurve: Curves.easeInCubic,
  );

  late final Animation<double> _scaleX = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.25, 1.0, curve: Curves.elasticOut),
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void initState() {
    super.initState();
    if (widget.visible) _c.forward(); // animasi jalan saat pertama muncul
  }

  // didUpdateWidget, dispose, dan build tetap sama seperti sebelumnya

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        if (_c.isDismissed) return const SizedBox.shrink();

        final sx = 0.05 + 0.95 * _scaleX.value;
        final sy = 0.02 + 0.98 * _scaleY.value;

        return Opacity(
          opacity: (_c.value * 2).clamp(0.0, 1.0),
          child: Transform(
            alignment: widget.origin,
            transform: Matrix4.diagonal3Values(sx, sy, 1),
            child: child,
          ),
        );
      },
    );
  }
}