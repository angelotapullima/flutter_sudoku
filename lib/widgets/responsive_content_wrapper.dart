import 'package:flutter/material.dart';

class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = 850,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // Si es pantalla de escritorio, enmarcamos en una sección central refinada
        if (width > 800) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: child,
            ),
          );
        }
        // En móviles, se renderiza de borde a borde normal
        return child;
      },
    );
  }
}
