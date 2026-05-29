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
        // Si la pantalla es más ancha que el máximo permitido, centramos y contenemos
        if (width > maxWidth) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: child,
            ),
          );
        }
        // Si no, renderizamos normalmente (aplica padding local si es necesario desde la vista)
        return child;
      },
    );
  }
}
