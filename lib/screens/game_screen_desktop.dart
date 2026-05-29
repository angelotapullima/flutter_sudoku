import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/control_buttons.dart';
import '../widgets/number_pad.dart';
import '../widgets/ability_bar.dart';
import 'settings_screen.dart';

class GameScreenDesktop extends ConsumerWidget {
  final GameState gameState;
  final dynamic sudokuTheme;
  final bool isDark;
  final dynamic settings;
  final String min;
  final String sec;
  final VoidCallback onAbilityUsed;

  const GameScreenDesktop({
    super.key,
    required this.gameState,
    required this.sudokuTheme,
    required this.isDark,
    required this.settings,
    required this.min,
    required this.sec,
    required this.onAbilityUsed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildHeader(context, ref),
        Expanded(
          child: Row(
            children: [
              // Lado Izquierdo: Tablero Gigante
              Expanded(
                flex: 3,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: const SudokuGrid(),
                    ),
                  ),
                ),
              ),
              // Lado Derecho: Controles y Poderes
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.02)
                        : Colors.black.withOpacity(0.02),
                    border: Border(
                        left: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black12)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        _buildDesktopStats(isDark),
                        const SizedBox(height: 32),
                        const ControlButtons(),
                        const SizedBox(height: 32),
                        const NumberPad(),
                        const SizedBox(height: 32),
                        AbilityBar(onAbilityUsed: onAbilityUsed),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final bool isBoss = gameState.bossName != null;
    final bool hasTimerLimit = gameState.modifiers.containsKey('timer_limit');
    final String timeStr = hasTimerLimit
        ? _formatRemainingTime(
            gameState.modifiers['timer_limit'] as int, gameState.elapsedSeconds)
        : '$min:$sec';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (gameState.difficulty == 'Tutorial') {
                ref.read(gameProvider.notifier).quitGame();
              }
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          ),
          Column(
            children: [
              Text(
                isBoss
                    ? 'DESAFÍO DEL GUARDIÁN: ${gameState.bossName!.toUpperCase()}'
                    : (gameState.isCampaign
                        ? 'VIAJE NIVEL ${gameState.campaignLevelNumber}'
                        : gameState.difficulty.toUpperCase()),
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: isBoss ? 1.5 : 0,
                    color:
                        isBoss ? Colors.redAccent : sudokuTheme.primaryColor),
              ),
              Text(
                'Errores: ${gameState.errorsCount}/3',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: gameState.errorsCount > 0
                        ? Colors.redAccent
                        : Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              if (settings.showTimer)
                Text(
                  timeStr,
                  style: GoogleFonts.shareTechMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: (hasTimerLimit &&
                              (gameState.modifiers['timer_limit'] as int) -
                                      gameState.elapsedSeconds <
                                  30)
                          ? Colors.redAccent
                          : (gameState.isTimerFrozen
                              ? Colors.amber
                              : (isDark ? Colors.white : Colors.black))),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => ref.read(gameProvider.notifier).togglePause(),
                icon: Icon(
                  gameState.isPaused
                      ? Icons.play_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen())),
                icon: const Icon(Icons.settings_outlined, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStats(bool isDark) {
    final bool hasTimerLimit = gameState.modifiers.containsKey('timer_limit');
    final String timeStr = hasTimerLimit
        ? _formatRemainingTime(
            gameState.modifiers['timer_limit'] as int, gameState.elapsedSeconds)
        : '$min:$sec';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: sudokuTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildStatRow(
              hasTimerLimit ? 'Tiempo Restante' : 'Tiempo Transcurrido',
              timeStr,
              isDark),
          const SizedBox(height: 12),
          _buildStatRow(
              'Errores Cometidos', '${gameState.errorsCount}/3', isDark),
        ],
      ),
    );
  }

  String _formatRemainingTime(int limit, int elapsed) {
    final remaining = (limit - elapsed).clamp(0, limit);
    final m = (remaining ~/ 60).toString().padLeft(2, '0');
    final s = (remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54, fontSize: 13)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
