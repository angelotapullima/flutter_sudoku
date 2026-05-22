import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;
    final settings = ref.watch(settingsProvider);

    // Función que calcula la cantidad de veces que el número 'num' ha sido colocado de forma correcta en el tablero.
    int getCorrectCount(int num) {
      if (gameState.grid.isEmpty) return 0;
      int count = 0;
      for (var row in gameState.grid) {
        for (var cell in row) {
          if (cell.value == num && cell.value == cell.solutionValue) {
            count++;
          }
        }
      }
      return count;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = (constraints.maxWidth - (8 * 8)) / 9;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(9, (index) {
              final number = index + 1;
              final correctCount = getCorrectCount(number);
              final countLeft = 9 - correctCount;

              // Si está activada la opción de mostrar restantes y ya se encontraron las 9 instancias, la "carta" desaparece
              if (settings.showRemainingNumbers && countLeft <= 0) {
                return SizedBox(
                  width: buttonSize,
                  height: buttonSize * 1.25,
                );
              }

              return GestureDetector(
                onTap: () {
                  ref.read(gameProvider.notifier).inputNumber(number);
                },
                child: Container(
                  width: buttonSize,
                  height: buttonSize * 1.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF2B2B3C), const Color(0xFF1E1E2E)]
                          : [Colors.grey[100]!, Colors.white],
                    ),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey[200]!,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black38
                            : Colors.grey.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Número grande perfectamente centrado
                      Text(
                        '$number',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : sudokuTheme.textColorLight,
                        ),
                      ),
                      // Indicador de faltantes posicionado absolutamente (solo si showRemainingNumbers está activo)
                      if (settings.showRemainingNumbers)
                        Positioned(
                          bottom: 3,
                          right: 5,
                          child: Text(
                            '$countLeft',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white38 : Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
