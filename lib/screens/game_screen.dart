import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/control_buttons.dart';
import '../widgets/number_pad.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;

    final min = (gameState.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (gameState.elapsedSeconds % 60).toString().padLeft(2, '0');

    // Escuchar el estado de victoria para mostrar un modal premium inmediatamente
    ref.listen(gameProvider.select((s) => s.isGameWon), (prev, isWon) {
      if (isWon == true) {
        _showVictoryDialog(context, ref, gameState.difficulty, gameState.elapsedSeconds, gameState.errorsCount);
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
                            gameState.difficulty.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.0,
                              color: sudokuTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Errores
                          Text(
                            'Errores: ${gameState.errorsCount}/3',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: gameState.errorsCount > 0 ? Colors.redAccent : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // Temporizador y Pausa
                      Row(
                        children: [
                          Text(
                            '$min:$sec',
                            style: GoogleFonts.shareTechMono(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => ref.read(gameProvider.notifier).togglePause(),
                            icon: Icon(
                              gameState.isPaused
                                  ? Icons.play_circle_outline_rounded
                                  : Icons.pause_circle_outline_rounded,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),
                const Spacer(),

                // 2. Tablero de Sudoku
                const SudokuGrid(),

                const Spacer(),

                // 3. Controles (Deshacer, Borrar, Notas, Pista)
                const ControlButtons(),

                const Spacer(),

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

  Widget _buildPauseOverlay(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
    bool isDark,
  ) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
      child: Container(
        color: isDark ? Colors.black54 : Colors.white54,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
              ),
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
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
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
                    child: const Text(
                      'Volver al Menú',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  void _showGameOverDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final dark = ref.read(themeProvider).isDarkMode;
        final theme = ref.read(themeProvider.notifier).currentSudokuTheme;
        final userProfile = ref.watch(profileProvider);
        final canRevive = userProfile.coins >= 50;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
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
