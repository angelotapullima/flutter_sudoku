import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/control_buttons.dart';
import '../widgets/number_pad.dart';
import '../widgets/ability_bar.dart';
import 'settings_screen.dart';

class GameScreenLandscape extends ConsumerWidget {
  final GameState gameState;
  final dynamic sudokuTheme;
  final bool isDark;
  final dynamic settings;
  final String min;
  final String sec;
  final VoidCallback onAbilityUsed;

  const GameScreenLandscape({
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
        _buildUltraCompactHeader(context, ref),
        Expanded(
          child: Row(
            children: [
              // LADO IZQUIERDO: El Tablero (Maximizado al alto)
              Expanded(
                flex: 11,
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: const SudokuGrid(),
                  ),
                ),
              ),

              // LADO DERECHO: Centro de Comando (CERO SCROLL)
              Expanded(
                flex: 9,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
                  child: Column(
                    children: [
                      // 1. Controles y Habilidades lado a lado
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(flex: 10, child: ControlButtons()),
                            const SizedBox(width: 4),
                            Expanded(
                                flex: 9,
                                child:
                                    AbilityBar(onAbilityUsed: onAbilityUsed)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // 2. Teclado Numérico Compacto
                      const Expanded(
                        flex: 4,
                        child: NumberPad(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUltraCompactHeader(BuildContext context, WidgetRef ref) {
    return Container(
      height: 30, // Máxima reducción
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0B12) : Colors.white,
        border: Border(
            bottom:
                BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
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
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            '${gameState.difficulty.toUpperCase()} • $min:$sec',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: sudokuTheme.primaryColor),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsScreen())),
            icon: const Icon(Icons.settings_outlined, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
