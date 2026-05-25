import 'package:flutter/material.dart';

class TutorialHand extends StatelessWidget {
  final Offset position;
  final bool isPressing;
  final Color color;

  const TutorialHand({
    super.key,
    required this.position,
    this.isPressing = false,
    this.color = const Color(0xFF00E5FF), // Cian Numbra
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      left: position.dx,
      top: position.dy,
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Efecto de pulso al presionar
            if (isPressing)
              _PulseEffect(color: color),
            
            // La mano (Icono estilizado con sombra)
            Transform.rotate(
              angle: -0.5,
              child: Icon(
                Icons.pan_tool_alt_rounded,
                size: 40,
                color: color,
                shadows: [
                  Shadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                  const Shadow(
                    color: Colors.black45,
                    offset: Offset(4, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseEffect extends StatefulWidget {
  final Color color;
  const _PulseEffect({required this.color});

  @override
  State<_PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<_PulseEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
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
        return Container(
          width: 60 * _controller.value,
          height: 60 * _controller.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(1 - _controller.value),
              width: 4,
            ),
          ),
        );
      },
    );
  }
}
