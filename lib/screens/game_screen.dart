import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/control_buttons.dart';
import '../widgets/number_pad.dart';
import '../widgets/settings_dialog.dart';

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
                            onPressed: () => ref.read(gameProvider.notifier).togglePause(),
                            icon: Icon(
                              gameState.isPaused
                                  ? Icons.play_circle_outline_rounded
                                  : Icons.pause_circle_outline_rounded,
                              size: 26,
                            ),
                          ),
                          IconButton(
                            onPressed: () => SettingsDialog.show(context),
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

    // Ordenar de menor a mayor tiempo
    leaderboard.sort((a, b) => (a['time'] as int).compareTo(b['time'] as int));

    // Determinar índice y clasificación del jugador
    final playerIndex = leaderboard.indexWhere((item) => item['isPlayer'] == true);
    final placement = playerIndex + 1;

    // Calcular copa y recompensas
    String cupEmoji = '🏆';
    String cupName = 'Sin Podio';
    Color cupColor = Colors.grey;
    int coinsReward = 0;
    int xpReward = 0;

    if (placement == 1) {
      cupEmoji = '🥇';
      cupName = 'Copa de Oro';
      cupColor = const Color(0xFFFFD700);
      if (gameState.tournamentDivision == 'Oro') {
        coinsReward = 250;
        xpReward = 600;
      } else if (gameState.tournamentDivision == 'Plata') {
        coinsReward = 150;
        xpReward = 400;
      } else {
        coinsReward = 80;
        xpReward = 250;
      }
    } else if (placement == 2) {
      cupEmoji = '🥈';
      cupName = 'Copa de Plata';
      cupColor = const Color(0xFFC0C0C0);
      if (gameState.tournamentDivision == 'Oro') {
        coinsReward = 120;
        xpReward = 400;
      } else if (gameState.tournamentDivision == 'Plata') {
        coinsReward = 80;
        xpReward = 250;
      } else {
        coinsReward = 40;
        xpReward = 150;
      }
    } else if (placement == 3) {
      cupEmoji = '🥉';
      cupName = 'Copa de Bronce';
      cupColor = const Color(0xFFCD7F32);
      if (gameState.tournamentDivision == 'Oro') {
        coinsReward = 60;
        xpReward = 200;
      } else if (gameState.tournamentDivision == 'Plata') {
        coinsReward = 40;
        xpReward = 150;
      } else {
        coinsReward = 20;
        xpReward = 100;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            backgroundColor: dark ? const Color(0xFF1E1E2E) : Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono e indicación de trofeo
                Center(
                  child: Column(
                    children: [
                      Text(
                        cupEmoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        placement <= 3 ? '¡PODIO CONSEGUIDO!' : '¡TORNEO COMPLETADO!',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cupColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        placement <= 3 ? cupName.toUpperCase() : 'PUESTO #$placement',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: dark ? Colors.white : const Color(0xFF2B2B36),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Liga ${gameState.tournamentDivision}',
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1, color: Colors.white24),
                const SizedBox(height: 16),

                // Lista de Clasificación
                Text(
                  'Clasificación Final',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: dark ? Colors.grey[350] : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Contenedor de la lista
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final item = leaderboard[index];
                      final isCurrentPlayer = item['isPlayer'] as bool;
                      final rawSecs = item['time'] as int;
                      final minStr = (rawSecs ~/ 60).toString().padLeft(2, '0');
                      final secStr = (rawSecs % 60).toString().padLeft(2, '0');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCurrentPlayer
                              ? theme.primaryColor.withOpacity(0.12)
                              : (dark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrentPlayer
                                ? theme.primaryColor.withOpacity(0.4)
                                : Colors.transparent,
                          ),
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
