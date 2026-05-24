import 'package:flutter/material.dart';

class DivineFlashEffect extends StatefulWidget {
  final VoidCallback onComplete;
  final Color color;

  const DivineFlashEffect({
    super.key,
    required this.onComplete,
    this.color = Colors.white,
  });

  @override
  State<DivineFlashEffect> createState() => _DivineFlashEffectState();
}

class _DivineFlashEffectState extends State<DivineFlashEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.8), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 80),
    ]).animate(_controller);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          child: Stack(
            children: [
              // El Flash de pantalla completa
              Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        widget.color,
                        widget.color.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Un círculo expansivo de "energía"
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withOpacity(_opacityAnimation.value),
                        width: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
