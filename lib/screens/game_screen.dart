import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/control_buttons.dart';
import '../widgets/number_pad.dart';
import '../widgets/ability_bar.dart';
import '../widgets/divine_flash_effect.dart';
import 'settings_screen.dart';
import '../widgets/share_victory_card.dart';
import '../utils/platform_file_saver.dart';

// Proveedor local para el efecto visual de flash
final showFlashProvider = StateProvider.autoDispose<bool>((ref) => false);

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;
    final settings = ref.watch(settingsProvider);
    final showFlash = ref.watch(showFlashProvider);

    final min = (gameState.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (gameState.elapsedSeconds % 60).toString().padLeft(2, '0');

    // Escuchar el estado de victoria para mostrar un modal premium inmediatamente
    ref.listen(gameProvider.select((s) => s.isGameWon), (prev, isWon) {
      if (isWon == true) {
        if (gameState.isTournament) {
          _showTournamentPodiumDialog(context, ref, gameState);
        } else {
          _showVictoryDialog(context, ref, gameState.difficulty, gameState.elapsedSeconds, gameState.errorsCount);
        }
      }
    });

    // Escuchar el estado de derrota para dar una segunda oportunidad
    ref.listen(gameProvider.select((s) => s.isGameOver), (prev, isOver) {
      if (isOver == true) {
        _showGameOverDialog(context, ref);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final bool isDesktop = width > 800;

                if (isDesktop) {
                  // --- DISEÑO WEB DE ESCRITORIO PANORÁMICO REAL (A PANTALLA COMPLETA) ---
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna Izquierda: Tablero de Sudoku Centrado + Header de Partida
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               // Header del juego en escritorio
                              _buildDesktopHeader(context, ref, gameState, settings, sudokuTheme, isDark, min, sec),
                              const SizedBox(height: 16),
                              // Grid del Sudoku limitado a un tamaño ergonómico máximo
                              const Center(
                                child: SizedBox(
                                  width: 460,
                                  child: SudokuGrid(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 32),
                        
                        // Columna Derecha: Panel de Control Táctico Flotante
                        Container(
                          width: 380,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2E).withOpacity(0.6) : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Título del Panel de Operaciones
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PANEL TÁCTICO',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: sudokuTheme.primaryColor,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  // Errores
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: gameState.errorsCount > 0 
                                          ? Colors.redAccent.withOpacity(0.12)
                                          : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      settings.enableErrorLimit
                                          ? 'Errores: ${gameState.errorsCount}/3'
                                          : 'Errores: ${gameState.errorsCount}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: gameState.errorsCount > 0 ? Colors.redAccent : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(height: 1),
                              const SizedBox(height: 20),
                              
                              // Botones de control (Deshacer, Borrar, Notas, Pista)
                              const ControlButtons(),
                              const SizedBox(height: 24),
                              
                              // Habilidades RPG
                              Text(
                                'HABILIDADES TÁCTICAS',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                  color: Colors.grey[500],
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              AbilityBar(
                                onAbilityUsed: () {
                                  ref.read(showFlashProvider.notifier).state = true;
                                },
                              ),
                              const SizedBox(height: 28),
                              
                              // Teclado Numérico
                              const NumberPad(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // --- DISEÑO MÓVIL ORIGINAL (COLUMNA VERTICAL CON SCROLL) ---
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Barra de encabezado
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                            ),
                            Column(
                              children: [
                                Text(
                                  gameState.isTournament
                                      ? 'LIGA ${gameState.tournamentDivision.toUpperCase()}'
                                      : gameState.difficulty.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.0,
                                    color: sudokuTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  settings.enableErrorLimit
                                      ? 'Errores: ${gameState.errorsCount}/3'
                                      : 'Errores: ${gameState.errorsCount}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: gameState.errorsCount > 0 ? Colors.redAccent : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (settings.showTimer) ...[
                                  Text(
                                    '$min:$sec',
                                    style: GoogleFonts.shareTechMono(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: gameState.isTimerFrozen ? Colors.amber : (isDark ? Colors.white : Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                IconButton(
                                  onPressed: () => _shareVictory(
                                    context, 
                                    ref, 
                                    gameState.difficulty, 
                                    '$min:$sec', 
                                    sudokuTheme, 
                                    isDark
                                  ),
                                  icon: const Icon(Icons.share_rounded, size: 22),
                                ),
                                IconButton(
                                  onPressed: () => ref.read(gameProvider.notifier).togglePause(),
                                  icon: Icon(
                                    gameState.isPaused
                                        ? Icons.play_circle_outline_rounded
                                        : Icons.pause_circle_outline_rounded,
                                    size: 26,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                  ),
                                  icon: const Icon(Icons.settings_outlined, size: 24),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      const SudokuGrid(),
                      const SizedBox(height: 12),
                      const ControlButtons(),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AbilityBar(
                          onAbilityUsed: () {
                            ref.read(showFlashProvider.notifier).state = true;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const NumberPad(),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),

            // CAPA DE PAUSA (ANTI-TRAMPAS)
            if (gameState.isPaused)
              _buildPauseOverlay(context, ref, sudokuTheme, isDark),

            // EFECTO VISUAL DIVINO
            if (showFlash)
              DivineFlashEffect(
                color: Colors.white,
                onComplete: () {
                  ref.read(showFlashProvider.notifier).state = false;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context, WidgetRef ref, SudokuTheme theme, bool isDark) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
      child: Container(
        color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause_circle_filled_rounded, size: 80, color: theme.primaryColor),
              const SizedBox(height: 20),
              Text(
                'JUEGO EN PAUSA',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => ref.read(gameProvider.notifier).togglePause(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                  child: const Text('REANUDAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context, WidgetRef ref, SudokuTheme theme, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey[200]!,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pause_rounded,
                  size: 64,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Juego en Pausa',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'El tablero está oculto para asegurar la honestidad intelectual.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => ref.read(gameProvider.notifier).togglePause(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Reanudar Partida',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVictoryDialog(
    BuildContext context,
    WidgetRef ref,
    String difficulty,
    int seconds,
    int errors,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final dark = ref.read(themeProvider).isDarkMode;
        final theme = ref.read(themeProvider.notifier).currentSudokuTheme;
        final min = (seconds ~/ 60).toString().padLeft(2, '0');
        final sec = (seconds % 60).toString().padLeft(2, '0');

        // Monedas base y bonos
        int baseCoins = 25;
        if (difficulty == 'Fácil') baseCoins = 20;
        if (difficulty == 'Medio') baseCoins = 40;
        if (difficulty == 'Difícil') baseCoins = 75;
        if (difficulty == 'Experto') baseCoins = 150;

        final isPerfect = errors == 0;
        final totalCoins = baseCoins + (isPerfect ? 25 : 0);

        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: dark ? const Color(0xFF1E1E2E) : Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 12),
                Text(
                  '¡VICTORIA!',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Has completado exitosamente el Sudoku.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: dark ? Colors.grey[300] : Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _buildStatRow('Dificultad:', difficulty, dark),
                _buildStatRow('Tiempo:', '$min:$sec', dark),
                _buildStatRow('Errores:', '$errors/3', dark),
                _buildStatRow('Recompensa:', '🪙 +$totalCoins S-Coins', dark, color: Colors.amber[700]),
                if (isPerfect)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '✨ ¡Bono de partida perfecta! (+25)',
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 24),
                // Botones de Acción
                Row(
                  children: [
                    // Botón Compartir
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => _shareVictory(context, ref, difficulty, '$min:$sec', theme, dark),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: theme.primaryColor),
                        ),
                        child: Icon(Icons.share_rounded, color: theme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón Salir
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(gameProvider.notifier).quitGame();
                          Navigator.of(context).pop(); // Cierra diálogo
                          Navigator.of(context).pop(); // Vuelve al Home
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Volver al Menú',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareVictory(
    BuildContext context, 
    WidgetRef ref, 
    String difficulty, 
    String timeStr, 
    SudokuTheme theme, 
    bool isDark
  ) async {
    try {
      final screenshotController = ScreenshotController();
      final userProfile = ref.read(profileProvider);
      
      // Mostrar feedback visual de que se está generando la imagen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generando tarjeta de victoria... 🎨'),
          duration: Duration(seconds: 1),
        ),
      );

      // Generamos la imagen en memoria usando el widget oculto
      final imageBytes = await screenshotController.captureFromWidget(
        Material(
          child: ShareVictoryCard(
            time: timeStr,
            difficulty: difficulty,
            level: userProfile.level,
            theme: theme,
            isDark: isDark,
          ),
        ),
        delay: const Duration(milliseconds: 100),
      );

      // Delegar en el platform_file_saver la acción correcta según la plataforma
      if (context.mounted) {
        await saveAndShareVictory(
          context: context,
          imageBytes: imageBytes,
          filename: 'victoria_numbra_sudoku.png',
          shareText: '¡Mira mi progreso en Numbra! 🧩🏆 #NumbraRPG',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la tarjeta: $e')),
        );
      }
    }
  }

  void _showTournamentPodiumDialog(
    BuildContext context,
    WidgetRef ref,
    GameState gameState,
  ) {
    final dark = ref.read(themeProvider).isDarkMode;
    final theme = ref.read(themeProvider.notifier).currentSudokuTheme;

    // Crear lista de posiciones ordenadas por tiempo
    // Incluir al jugador y los bots
    final List<Map<String, dynamic>> leaderboard = [];
    leaderboard.add({
      'name': 'Tú (Jugador)',
      'time': gameState.elapsedSeconds,
      'isPlayer': true,
    });

    for (int i = 0; i < gameState.tournamentOpponents.length; i++) {
      leaderboard.add({
        'name': gameState.tournamentOpponents[i],
        'time': gameState.tournamentOpponentTimes[i],
        'isPlayer': false,
      });
    }

    leaderboard.sort((a, b) => a['time'].compareTo(b['time']));

    final int placement = leaderboard.indexWhere((e) => e['isPlayer']) + 1;
    final int coinsReward = placement == 1 ? 250 : (placement == 2 ? 100 : (placement == 3 ? 50 : 0));
    final int xpReward = placement == 1 ? 500 : (placement == 2 ? 250 : (placement == 3 ? 100 : 50));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Dialog(
            backgroundColor: dark ? const Color(0xFF1E1E2E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    placement <= 3 ? '¡PODIO LOGRADO! 🏆' : 'TORNEO FINALIZADO',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Has quedado en la posición #$placement',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Lista del Mini-Ranking del torneo
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: dark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: leaderboard.length,
                      itemBuilder: (context, index) {
                        final item = leaderboard[index];
                        final isCurrentPlayer = item['isPlayer'];
                        final minStr = (item['time'] ~/ 60).toString().padLeft(2, '0');
                        final secStr = (item['time'] % 60).toString().padLeft(2, '0');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isCurrentPlayer
                                ? theme.primaryColor.withOpacity(0.4)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${index + 1}º',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: index == 0
                                      ? const Color(0xFFFFD700)
                                      : (index == 1
                                          ? const Color(0xFFC0C0C0)
                                          : (index == 2 ? const Color(0xFFCD7F32) : Colors.grey)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                    color: isCurrentPlayer
                                        ? (dark ? Colors.white : Colors.black)
                                        : (dark ? Colors.grey[300] : Colors.grey[800]),
                                  ),
                                ),
                              ),
                              Text(
                                '$minStr:$secStr',
                                style: GoogleFonts.shareTechMono(
                                  fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                  color: isCurrentPlayer ? theme.primaryColor : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Colors.white24),
                  const SizedBox(height: 14),

                  // Recompensas Obtenidas
                  if (coinsReward > 0 || xpReward > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (coinsReward > 0)
                          Row(
                            children: [
                              const Text('🪙 ', style: TextStyle(fontSize: 18)),
                              Text(
                                '+$coinsReward S-Coins',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.amber[700],
                                ),
                              ),
                            ],
                          ),
                        if (xpReward > 0)
                          Row(
                            children: [
                              const Text('👑 ', style: TextStyle(fontSize: 18)),
                              Text(
                                '+$xpReward XP',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Botón
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(gameProvider.notifier).quitGame();
                        Navigator.of(context).pop(); // Cierra diálogo
                        Navigator.of(context).pop(); // Vuelve al Home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        placement <= 3 ? 'Reclamar Premios' : 'Volver al Menú',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGameOverDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final dark = ref.read(themeProvider).isDarkMode;
        final userProfile = ref.watch(profileProvider);
        final canRevive = userProfile.coins >= 50;

        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: dark ? const Color(0xFF1E1E2E) : Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💀', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 12),
                Text(
                  'FIN DEL JUEGO',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Has cometido 3 errores. ¿Qué deseas hacer?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                // Botón revivir (Segunda Oportunidad)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: canRevive
                        ? () {
                            final success = ref.read(gameProvider.notifier).useSecondChance();
                            if (success) {
                              Navigator.of(context).pop(); // Cierra diálogo
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Segunda Oportunidad (🪙 50)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: canRevive ? Colors.white : Colors.white38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Botón Rendirse
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(gameProvider.notifier).quitGame();
                      Navigator.of(context).pop(); // Cierra diálogo
                      Navigator.of(context).pop(); // Vuelve al Home
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: dark ? Colors.white24 : Colors.grey[300]!),
                    ),
                    child: Text(
                      'Rendirse y Salir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white70 : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopHeader(
    BuildContext context,
    WidgetRef ref,
    dynamic gameState,
    dynamic settings,
    dynamic sudokuTheme,
    bool isDark,
    String min,
    String sec,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameState.isTournament
                      ? 'LIGA ${gameState.tournamentDivision.toUpperCase()}'
                      : 'MODO ${gameState.difficulty.toUpperCase()}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.0,
                    color: sudokuTheme.primaryColor,
                  ),
                ),
                Text(
                  'Partida de Campaña Estelar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        
        Row(
          children: [
            if (settings.showTimer) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined, 
                      size: 18, 
                      color: gameState.isTimerFrozen ? Colors.amber : sudokuTheme.primaryColor
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$min:$sec',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: gameState.isTimerFrozen ? Colors.amber : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            IconButton(
              onPressed: () => _shareVictory(
                context, 
                ref, 
                gameState.difficulty, 
                '$min:$sec', 
                sudokuTheme, 
                isDark
              ),
              icon: const Icon(Icons.share_rounded, size: 22),
              tooltip: 'Compartir progreso',
            ),
            
            IconButton(
              onPressed: () => ref.read(gameProvider.notifier).togglePause(),
              icon: Icon(
                gameState.isPaused
                    ? Icons.play_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                size: 26,
              ),
              tooltip: gameState.isPaused ? 'Reanudar' : 'Pausar',
            ),
            
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings_outlined, size: 24),
              tooltip: 'Ajustes',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
