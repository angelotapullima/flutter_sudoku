import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/control_buttons.dart';
import '../widgets/number_pad.dart';
import 'settings_screen.dart';
import '../widgets/share_victory_card.dart';

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
            Column(
              children: [
                // 1. Barra de encabezado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Salir
                      IconButton(
                        onPressed: () {
                          // Si el juego no ha terminado, se guarda automáticamente
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      ),
                      // Dificultad del juego
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
                          // Errores
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
                      // Temporizador y Pausa/Ajustes
                      Row(
                        children: [
                          if (settings.showTimer) ...[
                            Text(
                              '$min:$sec',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
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
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            ),
                            icon: const Icon(
                              Icons.settings_outlined,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 12),

                // 2. Tablero de Sudoku
                const SudokuGrid(),

                const SizedBox(height: 12),

                // 3. Controles (Deshacer, Borrar, Notas, Pista)
                const ControlButtons(),

                const SizedBox(height: 12),

                // 4. Teclado Numérico
                const NumberPad(),
                const SizedBox(height: 16),
              ],
            ),

            // CAPA DE PAUSA (ANTI-TRAMPAS)
            if (gameState.isPaused)
              _buildPauseOverlay(context, ref, sudokuTheme, isDark),
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

      // Guardar temporalmente y compartir
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/victoria_sudoku.png').create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: '¡Mira mi progreso en Sudoku Master! 🧩🏆 #SudokuMaster',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir: $e')),
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
