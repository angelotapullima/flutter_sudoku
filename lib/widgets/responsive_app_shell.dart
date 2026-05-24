import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class ResponsiveAppShell extends ConsumerWidget {
  final Widget child;

  const ResponsiveAppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // Definir umbral de responsividad unificado (800px)
        final bool isDesktop = width > 800;

        if (!isDesktop) {
          // En móviles se ve de borde a borde nativo directo
          return child;
        }

        // Estilos adaptativos de fondo para pantallas de escritorio (Web Premium)
        final backgroundGradient = isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF07070A),
                  Color(0xFF0D0D18),
                  Color(0xFF050508),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE2E6F0),
                  Color(0xFFF0F3FA),
                  Color(0xFFE2E6F0),
                ],
              );

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: backgroundGradient,
            ),
            child: Stack(
              children: [
                // Luces de atmósfera ambientadas en el fondo de escritorio (Web Premium)
                if (isDark) ...[
                  Positioned(
                    top: -100,
                    left: -100,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0F62FE),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8A3FFC),
                      ),
                    ),
                  ),
                  
                  // Filtro de desenfoque premium para el brillo del fondo
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                      child: Container(
                        color: Colors.black.withOpacity(0.12), // Un ligero velo oscuro integrador
                      ),
                    ),
                  ),
                ],
                
                // En escritorio permitimos que el child ocupe todo el espacio responsivamente
                Positioned.fill(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}
