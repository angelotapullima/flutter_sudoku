import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tutorial_keys_provider.dart';

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
    final keys = ref.read(tutorialKeysProvider);

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = MediaQuery.of(context).size.width;
        // Definir umbral de responsividad unificado (800px)
        final bool isDesktop = width > 800;

        if (isDesktop) {
          // --- DISEÑO WEB DE ESCRITORIO: CUADRÍCULA 3x3 COMPACTA Y REFINADA ---
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.7, // Proporción ergonómica para PC
              ),
              itemBuilder: (context, index) {
                final number = index + 1;
                final correctCount = getCorrectCount(number);
                final countLeft = 9 - correctCount;

                // Si se habilitó ocultar restantes y ya no quedan instancias
                if (settings.showRemainingNumbers && countLeft <= 0) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  key: keys.numKeys[index],
                  onTap: () {
                    ref.read(gameProvider.notifier).inputNumber(number);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF232332), const Color(0xFF161622)]
                              : [Colors.grey[50]!, Colors.white],
                        ),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Número principal centrado
                          Text(
                            '$number',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : sudokuTheme.primaryColor,
                            ),
                          ),
                          
                          // Indicador de cantidad restante en la esquina superior derecha
                          if (settings.showRemainingNumbers && countLeft > 0)
                            Positioned(
                              top: 4,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? sudokuTheme.primaryColor.withOpacity(0.2) 
                                      : sudokuTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$countLeft',
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.cyanAccent : sudokuTheme.primaryColor,
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
            ),
          );
        }

        // --- DISEÑO MÓVIL ORIGINAL: UNA SOLA FILA HORIZONTAL DE 9 ELEMENTOS ---
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
              key: keys.numKeys[index],
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
                    // Indicador de faltantes posicionado absolutamente
                    if (settings.showRemainingNumbers)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$countLeft',
                            style: const TextStyle(
                              fontSize: 8.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
