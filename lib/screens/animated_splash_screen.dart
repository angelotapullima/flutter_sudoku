import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_navigation_screen.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _exitFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Remover el splash nativo una vez que Flutter ha pintado su primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    // Duración total ampliada para apreciar la flotación y el gran despegue curvo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    // 1. Escala de aparición inicial
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // 2. Opacidad de aparición inicial
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // 3. Opacidad de salida justo al final de la parábola
    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 0.98, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navegar a la pantalla principal justo después de que el cohete salga de pantalla en su parábola
    Timer(const Duration(milliseconds: 3400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B18), // Fondo espacial del Star Map
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Lógica física de órbita y despegue en parábola
            double x = 0.0;
            double y = 0.0;
            double floatOffset = 0.0;
            double rotationAngle = 0.0;

            if (_controller.value < 0.70) {
              // --- FASE 1: FLOTACIÓN DE ÓRBITA EN GRAVEDAD CERO (0% a 70%) ---
              // Vaivén vertical sinusoidal
              floatOffset = math.sin(_controller.value * math.pi * 3) * 8.0;
              // Balanceo de inclinación sutil (2 grados) para simular flotabilidad natural
              rotationAngle = math.sin(_controller.value * math.pi * 3) * 0.04;
            } else {
              // --- FASE 2: DESPEGUE CINEMÁTICO EN PARÁBOLA (70% a 100%) ---
              // Normalizamos el tiempo de despegue de 0.0 a 1.0
              double t = (_controller.value - 0.70) / 0.30;
              
              // Ecuaciones de la trayectoria de la parábola
              x = t * 260.0;             // Desplazamiento horizontal a la derecha
              y = - (t * t) * 600.0;     // Disparo vertical acelerado hacia arriba

              // Derivadas para calcular la dirección tangencial (vector de velocidad)
              double dx = 260.0;
              double dy = - 2.0 * t * 600.0;

              // Ángulo en el que viaja el cohete en la curva
              // Sumamos pi/2 porque por defecto el cohete está dibujado apuntando hacia arriba
              rotationAngle = math.atan2(dy, dx) + (math.pi / 2);
            }

            return Opacity(
              opacity: _fadeAnimation.value * _exitFadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // El Cohete Vectorial (CustomPaint) con física de parábola y rotación
                    Transform.translate(
                      offset: Offset(x, y + floatOffset),
                      child: Transform.rotate(
                        angle: rotationAngle,
                        child: CustomPaint(
                          size: const Size(200, 200),
                          painter: RocketPainter(
                            primaryColor: const Color(0xFF0F62FE), // Azul Océano Cósmico
                            accentColor: const Color(0xFF78A9FF),  // Ice Blue
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    Text(
                      'Sudoku Arena',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Odisea del Intelecto Estelar',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// CustomPainter para dibujar un cohete de Sudoku 100% vectorial, limpio y nítido.
class RocketPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  RocketPainter({required this.primaryColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();

    final double w = size.width;
    final double h = size.height;

    // 1. DIBUJAR EL FUEGO DEL PROPULSOR (Naranja y Amarillo)
    paint.color = Colors.orangeAccent;
    path.reset();
    path.moveTo(w * 0.46, h * 0.76);
    path.lineTo(w * 0.5, h * 0.92);
    path.lineTo(w * 0.54, h * 0.76);
    path.close();
    canvas.drawPath(path, paint);

    paint.color = Colors.yellow;
    path.reset();
    path.moveTo(w * 0.48, h * 0.76);
    path.lineTo(w * 0.5, h * 0.86);
    path.lineTo(w * 0.52, h * 0.76);
    path.close();
    canvas.drawPath(path, paint);

    // 2. ALETAS LATERALES TRASERA (Azul Cósmico)
    paint.color = primaryColor;
    // Aleta izquierda
    path.reset();
    path.moveTo(w * 0.40, h * 0.58);
    path.quadraticBezierTo(w * 0.26, h * 0.68, w * 0.32, h * 0.76);
    path.lineTo(w * 0.40, h * 0.72);
    path.close();
    canvas.drawPath(path, paint);

    // Aleta derecha
    path.reset();
    path.moveTo(w * 0.60, h * 0.58);
    path.quadraticBezierTo(w * 0.74, h * 0.68, w * 0.68, h * 0.76);
    path.lineTo(w * 0.60, h * 0.72);
    path.close();
    canvas.drawPath(path, paint);

    // 3. CUERPO PRINCIPAL DEL COHETE (Blanco nítido)
    paint.color = Colors.white;
    path.reset();
    path.moveTo(w * 0.40, h * 0.42);
    // Punta ojiva aerodinámica redondeada
    path.cubicTo(w * 0.40, h * 0.22, w * 0.60, h * 0.22, w * 0.60, h * 0.42);
    path.lineTo(w * 0.60, h * 0.72);
    path.lineTo(w * 0.40, h * 0.72);
    path.close();
    canvas.drawPath(path, paint);

    // 4. PUNTA DEL COHETE (Azul Cósmico - Sombrero)
    paint.color = primaryColor;
    path.reset();
    path.moveTo(w * 0.40, h * 0.42);
    path.cubicTo(w * 0.40, h * 0.22, w * 0.60, h * 0.22, w * 0.60, h * 0.42);
    // Cerrar el sombrero del cohete de forma curva
    path.quadraticBezierTo(w * 0.50, h * 0.46, w * 0.40, h * 0.42);
    path.close();
    canvas.drawPath(path, paint);

    // 5. LA VENTANA DE CRISTAL (Cian con borde blanco)
    paint.color = accentColor;
    canvas.drawCircle(Offset(w * 0.5, h * 0.51), w * 0.07, paint);
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawCircle(Offset(w * 0.5, h * 0.51), w * 0.07, paint);

    // 6. CUADRÍCULA DE SUDOKU GRABADA EN EL FUSELAJE
    paint.color = Colors.grey.withOpacity(0.25);
    paint.strokeWidth = 1.0;
    paint.style = PaintingStyle.stroke;

    // Líneas horizontales del Sudoku
    canvas.drawLine(Offset(w * 0.41, h * 0.60), Offset(w * 0.59, h * 0.60), paint);
    canvas.drawLine(Offset(w * 0.41, h * 0.66), Offset(w * 0.59, h * 0.66), paint);

    // Líneas verticales del Sudoku
    canvas.drawLine(Offset(w * 0.47, h * 0.57), Offset(w * 0.47, h * 0.71), paint);
    canvas.drawLine(Offset(w * 0.53, h * 0.57), Offset(w * 0.53, h * 0.71), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
