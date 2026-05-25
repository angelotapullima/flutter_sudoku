import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tutorial_keys_provider.dart';
import '../widgets/divine_flash_effect.dart';
import '../widgets/tutorial_hand.dart';
import '../utils/enums.dart';
import 'game_screen_mobile.dart';
import 'game_screen_desktop.dart';
import 'game_screen_landscape.dart';

final showFlashProvider = StateProvider.autoDispose<bool>((ref) => false);

class GameScreen extends ConsumerStatefulWidget {
  final TutorialScript? tutorialScript;
  const GameScreen({super.key, this.tutorialScript});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final FocusNode _keyboardFocusNode;
  final GlobalKey _stackKey = GlobalKey();

  Offset _handPosition = const Offset(2000, 500);
  bool _isHandPressing = false;
  bool _isTutorialRunning = false;

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode = FocusNode();
    if (widget.tutorialScript != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _runInGameTutorial(widget.tutorialScript!);
        });
      });
    }
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // --- TUTORIAL LOGIC (Mantenida igual) ---
  Future<void> _runInGameTutorial(TutorialScript script) async {
    if (_isTutorialRunning || !mounted) return;
    setState(() => _isTutorialRunning = true);
    final keys = ref.read(tutorialKeysProvider);
    switch (script) {
      case TutorialScript.lawRow:
        await _executeRowLawTutorial(keys);
        break;
      case TutorialScript.lawCol:
        await _executeColLawTutorial(keys);
        break;
      case TutorialScript.lawBox:
        await _executeBoxLawTutorial(keys);
        break;
      case TutorialScript.masteryExclusion:
        await _executeExclusionMasteryTutorial(keys);
        break;
      case TutorialScript.powerVision:
        await _executeVisionTutorial(keys);
        break;
      case TutorialScript.powerClock:
        await _executeClockTutorial(keys);
        break;
      case TutorialScript.powerDivine:
        await _executeDivineTutorial(keys);
        break;
    }
    if (mounted) {
      setState(() {
        _isTutorialRunning = false;
        _handPosition = const Offset(2000, 500);
      });
      _showTutorialEndDialog(script);
    }
  }

  void _showTutorialEndDialog(TutorialScript script) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = ref.read(themeProvider.notifier).currentSudokuTheme;
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E2E)
                : Colors.white,
            title: const Text('💡 LECCIÓN COMPLETADA',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: const Text(
                '¿Deseas repetir esta enseñanza o volver a la Academia?',
                textAlign: TextAlign.center),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _runInGameTutorial(script);
                  },
                  child: Text('REPETIR',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold))),
              ElevatedButton(
                  onPressed: () {
                    ref.read(gameProvider.notifier).quitGame();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor),
                  child: const Text('VOLVER')),
            ],
          ),
        );
      },
    );
  }

  // --- SCRIPTS DE TUTORIAL (Mantenidos) ---
  Future<void> _executeRowLawTutorial(TutorialKeys keys) async {
    _showTutorialMsg('LEY 1: El Horizonte (Filas)', seconds: 4);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _moveHandToWidget(keys.cellKeys[0][2]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).selectCell(0, 2);
    _showTutorialMsg('Esta celda está vacía. Vamos a rellenarla con lógica.',
        seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _moveHandToWidget(keys.numKeys[3]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).inputNumber(4);
    _showTutorialMsg(
        '¡Bien! El 4 se une al horizonte sin repetir ningún otro número.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> _executeColLawTutorial(TutorialKeys keys) async {
    _showTutorialMsg('LEY 2: El Pilar (Columnas)', seconds: 4);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _moveHandToWidget(keys.cellKeys[1][1]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).selectCell(1, 1);
    _showTutorialMsg(
        'Observa la columna vertical. El 7 es el guardián que falta.',
        seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _moveHandToWidget(keys.numKeys[6]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).inputNumber(7);
    _showTutorialMsg('Perfecto. La columna mantiene su equilibrio numérico.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> _executeBoxLawTutorial(TutorialKeys keys) async {
    _showTutorialMsg('LEY 3: El Sector Galáctico (Cajas)', seconds: 4);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _moveHandToWidget(keys.cellKeys[2][0]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).selectCell(2, 0);
    _showTutorialMsg('En este cuadro de 3x3, el número 1 aún no ha despertado.',
        seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _moveHandToWidget(keys.numKeys[0]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).inputNumber(1);
    _showTutorialMsg(
        'Logrado. Las nueve esencias conviven en armonía en este sector.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> _executeExclusionMasteryTutorial(TutorialKeys keys) async {
    _showTutorialMsg('MAESTRÍA: "El Camino del Descarte"', seconds: 4);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await _moveHandToWidget(keys.cellKeys[0][2]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).selectCell(0, 2);
    _showTutorialMsg('Paso 1: Mira esta celda vacía. ¿Qué número pondrías?',
        seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _moveHandToWidget(keys.cellKeys[1][0]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    _showTutorialMsg('En este sector ya vive el 6... El 6 queda descartado.',
        seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _moveHandToWidget(keys.cellKeys[0][4]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    _showTutorialMsg(
        'En esta fila ya habita el 7... El 7 tampoco puede entrar.',
        seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    _showTutorialMsg(
        'Tras descartar los intrusos, el número 4 es la única verdad.',
        seconds: 5);
    await _moveHandToWidget(keys.numKeys[3]);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).inputNumber(4);
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> _executeVisionTutorial(TutorialKeys keys) async {
    _showTutorialMsg('TÁCTICA: "Visión Verdadera"', seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _moveHandToWidget(keys.visionKey);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).simulateTrueVision();
    _showTutorialMsg(
        '¡Mira el tablero! Aparecen "Números Fantasma" tenues en el sector seleccionado.',
        seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    _showTutorialMsg(
        'Este escáner de Rayos X revela temporalmente la solución de la caja de 3x3 (Sector) seleccionada por 10s.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    _showTutorialMsg(
        '¡Muévete por el tablero usando las flechas de dirección, WASD o clics para escanear y revelar otros sectores!',
        seconds: 6);
    await Future.delayed(const Duration(seconds: 5));
  }

  Future<void> _executeClockTutorial(TutorialKeys keys) async {
    _showTutorialMsg('TÁCTICA: "Reloj Estelar"', seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _moveHandToWidget(keys.clockKey);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).simulateFreezeTimer();
    _showTutorialMsg(
        '¡Mira el cronómetro! Se ha vuelto ámbar y el tiempo se ha detenido.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    _showTutorialMsg(
        'El Reloj Estelar es tu mejor aliado contra la presión del tiempo.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    _showTutorialMsg(
        'Ideal para los Torneos y Retos Diarios donde cada segundo define tu rango.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 4));
  }

  Future<void> _executeDivineTutorial(TutorialKeys keys) async {
    _showTutorialMsg('TÁCTICA: "Toque Divino"', seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _moveHandToWidget(keys.divineKey);
    if (!mounted) return;
    await _pressHand();
    if (!mounted) return;
    ref.read(gameProvider.notifier).simulateDivineTouch();
    ref.read(showFlashProvider.notifier).state = true;
    _showTutorialMsg(
        '¡Una bendición! Han aparecido 3 números correctos en el tablero.',
        seconds: 4);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    _showTutorialMsg(
        'El Orbe Divino también purifica el tablero entero, borrando tus errores.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    _showTutorialMsg(
        'Es el poder definitivo ante el caos. Úsalo con sabiduría.',
        seconds: 5);
    await Future.delayed(const Duration(seconds: 4));
  }

  void _showTutorialMsg(String msg, {int seconds = 3}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        backgroundColor: const Color(0xFF6200EA),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: seconds),
        margin: const EdgeInsets.only(bottom: 120, left: 30, right: 30),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
  }

  Future<void> _moveHandToWidget(GlobalKey key) async {
    final RenderBox? rb = key.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? sb =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb != null && sb != null && mounted) {
      final Offset gp = rb.localToGlobal(Offset.zero);
      final Offset lp = sb.globalToLocal(gp);
      final Size s = rb.size;
      setState(() {
        _handPosition =
            Offset(lp.dx + (s.width / 2) - 15, lp.dy + (s.height / 2) - 15);
      });
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  Future<void> _pressHand() async {
    if (!mounted) return;
    setState(() => _isHandPressing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isHandPressing = false);
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final gs = ref.watch(gameProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final theme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final settings = ref.watch(settingsProvider);
    final showFlash = ref.watch(showFlashProvider);
    final min = (gs.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (gs.elapsedSeconds % 60).toString().padLeft(2, '0');

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          final lk = event.logicalKey;
          int? n;
          if (lk == LogicalKeyboardKey.digit1 ||
              lk == LogicalKeyboardKey.numpad1)
            n = 1;
          else if (lk == LogicalKeyboardKey.digit2 ||
              lk == LogicalKeyboardKey.numpad2)
            n = 2;
          else if (lk == LogicalKeyboardKey.digit3 ||
              lk == LogicalKeyboardKey.numpad3)
            n = 3;
          else if (lk == LogicalKeyboardKey.digit4 ||
              lk == LogicalKeyboardKey.numpad4)
            n = 4;
          else if (lk == LogicalKeyboardKey.digit5 ||
              lk == LogicalKeyboardKey.numpad5)
            n = 5;
          else if (lk == LogicalKeyboardKey.digit6 ||
              lk == LogicalKeyboardKey.numpad6)
            n = n = 6;
          else if (lk == LogicalKeyboardKey.digit7 ||
              lk == LogicalKeyboardKey.numpad7)
            n = 7;
          else if (lk == LogicalKeyboardKey.digit8 ||
              lk == LogicalKeyboardKey.numpad8)
            n = 8;
          else if (lk == LogicalKeyboardKey.digit9 ||
              lk == LogicalKeyboardKey.numpad9) n = 9;
          if (n != null) {
            ref.read(gameProvider.notifier).inputNumber(n);
            return;
          }
          int sr = gs.selectedRow;
          int sc = gs.selectedCol;
          if (lk == LogicalKeyboardKey.arrowUp ||
              lk == LogicalKeyboardKey.keyW) {
            if (sr != -1)
              ref.read(gameProvider.notifier).selectCell((sr - 1 + 9) % 9, sc);
          } else if (lk == LogicalKeyboardKey.arrowDown ||
              lk == LogicalKeyboardKey.keyS) {
            if (sr != -1)
              ref.read(gameProvider.notifier).selectCell((sr + 1) % 9, sc);
          } else if (lk == LogicalKeyboardKey.arrowLeft ||
              lk == LogicalKeyboardKey.keyA) {
            if (sc != -1)
              ref.read(gameProvider.notifier).selectCell(sr, (sc - 1 + 9) % 9);
          } else if (lk == LogicalKeyboardKey.arrowRight ||
              lk == LogicalKeyboardKey.keyD) {
            if (sc != -1)
              ref.read(gameProvider.notifier).selectCell(sr, (sc + 1) % 9);
          } else if (lk == LogicalKeyboardKey.backspace ||
              lk == LogicalKeyboardKey.delete ||
              lk == LogicalKeyboardKey.digit0) {
            ref.read(gameProvider.notifier).inputNumber(0);
          }
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;

              // Lógica de detección de Layout Trifecta para el Juego
              Widget currentLayout;
              if (width > 1100) {
                currentLayout = GameScreenDesktop(
                    gameState: gs,
                    sudokuTheme: theme,
                    isDark: isDark,
                    settings: settings,
                    min: min,
                    sec: sec,
                    onAbilityUsed: () =>
                        ref.read(showFlashProvider.notifier).state = true);
              } else if (width > height && height < 600) {
                currentLayout = GameScreenLandscape(
                    gameState: gs,
                    sudokuTheme: theme,
                    isDark: isDark,
                    settings: settings,
                    min: min,
                    sec: sec,
                    onAbilityUsed: () =>
                        ref.read(showFlashProvider.notifier).state = true);
              } else {
                currentLayout = GameScreenMobile(
                    gameState: gs,
                    sudokuTheme: theme,
                    isDark: isDark,
                    settings: settings,
                    min: min,
                    sec: sec,
                    showFlash: showFlash,
                    onAbilityUsed: () =>
                        ref.read(showFlashProvider.notifier).state = true);
              }

              return Stack(
                key: _stackKey,
                children: [
                  IgnorePointer(
                      ignoring: _isTutorialRunning, child: currentLayout),
                  if (gs.isPaused)
                    _buildPauseOverlay(context, ref, theme, isDark),
                  if (showFlash)
                    DivineFlashEffect(
                        color: Colors.white,
                        onComplete: () =>
                            ref.read(showFlashProvider.notifier).state = false),
                  TutorialHand(
                      position: _handPosition,
                      isPressing: _isHandPressing,
                      color: theme.primaryColor),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(
      BuildContext context, WidgetRef ref, dynamic theme, bool isDark) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
      child: Container(
        color: isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause_circle_filled_rounded,
                  size: 80, color: theme.primaryColor),
              const SizedBox(height: 20),
              Text('JUEGO EN PAUSA',
                  style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 40),
              SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                      onPressed: () =>
                          ref.read(gameProvider.notifier).togglePause(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: const Text('REANUDAR',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)))),
            ],
          ),
        ),
      ),
    );
  }

  void _showVictoryDialog(
      BuildContext context, WidgetRef ref, String difficulty, int seconds) {
    final theme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              backgroundColor: dark ? const Color(0xFF1E1E2E) : Colors.white,
              title: Text('¡VICTORIA!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, color: theme.primaryColor)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Has conquistado el grid.',
                    style: TextStyle(
                        color: dark ? Colors.white70 : Colors.black54)),
                const SizedBox(height: 20),
                Text('Tiempo: $min:$sec',
                    style: const TextStyle(fontWeight: FontWeight.bold))
              ]),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      ref.read(gameProvider.notifier).quitGame();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('CONTINUAR'))
              ],
            )));
  }

  void _showGameOverDialog(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              backgroundColor: dark ? const Color(0xFF1E1E2E) : Colors.white,
              title: const Text('FIN DEL JUEGO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
              content: const Text('Has cometido 3 errores lógicos.'),
              actions: [
                TextButton(
                    onPressed: () {
                      ref.read(gameProvider.notifier).quitGame();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('SALIR'))
              ],
            ));
  }
}
