import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/control_buttons.dart';
import '../widgets/number_pad.dart';
import '../widgets/ability_bar.dart';
import 'settings_screen.dart';

class GameScreenMobile extends ConsumerWidget {
  final GameState gameState;
  final dynamic sudokuTheme;
  final bool isDark;
  final dynamic settings;
  final String min;
  final String sec;
  final bool showFlash;
  final VoidCallback onAbilityUsed;

  const GameScreenMobile({
    super.key,
    required this.gameState,
    required this.sudokuTheme,
    required this.isDark,
    required this.settings,
    required this.min,
    required this.sec,
    required this.showFlash,
    required this.onAbilityUsed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildHeader(context, ref),
        const Divider(height: 1),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: const SudokuGrid(),
                  ),
                ),
              ),
              const Flexible(flex: 3, child: ControlButtons()),
              Flexible(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AbilityBar(onAbilityUsed: onAbilityUsed),
                ),
              ),
              const Flexible(flex: 7, child: NumberPad()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final bool isBoss = gameState.bossName != null;
    final bool hasTimerLimit = gameState.modifiers.containsKey('timer_limit');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          Expanded(
            child: Column(
              children: [
                Text(
                  isBoss
                      ? 'GUARDIÁN: ${gameState.bossName!.toUpperCase()}'
                      : (gameState.isCampaign
                          ? 'VIAJE NIVEL ${gameState.campaignLevelNumber}'
                          : gameState.difficulty.toUpperCase()),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: isBoss ? 1.0 : 0,
                      color:
                          isBoss ? Colors.redAccent : sudokuTheme.primaryColor),
                ),
                Text(
                  'Errores: ${gameState.errorsCount}/3',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: gameState.errorsCount > 0
                          ? Colors.redAccent
                          : Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (settings.showTimer)
                Text(
                  hasTimerLimit
                      ? _formatRemainingTime(
                          gameState.modifiers['timer_limit'] as int,
                          gameState.elapsedSeconds)
                      : '$min:$sec',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 18,
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
                  size: 22,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen())),
                icon: const Icon(Icons.settings_outlined, size: 20),
              ),
            ],
          ),
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
}
