import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sudoku_cell.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class SudokuCellWidget extends ConsumerWidget {
  final int row;
  final int col;

  const SudokuCellWidget({
    super.key,
    required this.row,
    required this.col,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;

    // VALIDACIÓN DE SEGURIDAD (Hotfix para RangeError al cerrar partida)
    if (gameState.grid.isEmpty || gameState.grid.length <= row || gameState.grid[row].length <= col) {
      return const SizedBox();
    }

    final SudokuCell cell = gameState.grid[row][col];
    final isSelected = gameState.selectedRow == row && gameState.selectedCol == col;

    // Resaltado inteligente
    bool isHighlighted = false;
    bool isSameNumber = false;
    bool isSameBox = false;

    if (gameState.selectedRow != -1 && gameState.selectedCol != -1) {
      // 1. Compartir fila, columna o caja 3x3
      final selR = gameState.selectedRow;
      final selC = gameState.selectedCol;
      isSameBox = (row ~/ 3 == selR ~/ 3) && (col ~/ 3 == selC ~/ 3);
      if (row == selR || col == selC || isSameBox) {
        isHighlighted = true;
      }

      // 2. Compartir el mismo número seleccionado (distinto de 0)
      final selectedCell = gameState.grid[selR][selC];
      if (selectedCell.value != 0 && cell.value == selectedCell.value) {
        isSameNumber = true;
      }
    }

    final settings = ref.watch(settingsProvider);

    // Colores según el modo claro/oscuro con alto contraste premium
    final isDark = themeState.isDarkMode;
    Color cellBgColor;

    // LÓGICA DE VISIÓN VERDADERA (Habilidad Roguelike)
    bool isMarkedAsErrorByAbility = false;
    if (gameState.isShowingErrors && cell.value != 0 && cell.value != cell.solutionValue) {
      isMarkedAsErrorByAbility = true;
    }
    
    if (isSelected) {
      cellBgColor = isDark
          ? sudokuTheme.textColorDark.withOpacity(0.25)
          : sudokuTheme.textColorLight.withOpacity(0.18);
    } else if (isMarkedAsErrorByAbility) {
      cellBgColor = Colors.redAccent.withOpacity(0.2); // Resaltado de la habilidad
    } else if (settings.enableHighlighting && isSameNumber) {
      cellBgColor = isDark
          ? sudokuTheme.textColorDark.withOpacity(0.15)
          : sudokuTheme.textColorLight.withOpacity(0.10);
    } else if (settings.enableHighlighting && isHighlighted) {
      cellBgColor = isDark ? sudokuTheme.highlightColorDark : sudokuTheme.highlightColorLight;
    } else {
      cellBgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    }

    // Definición de estilo de texto para el número
    Color textColor;
    FontWeight fontWeight = FontWeight.normal;

    if (cell.isOriginal) {
      textColor = isDark ? Colors.white70 : const Color(0xFF2B2B36);
      fontWeight = FontWeight.bold;
    } else if (cell.isError) {
      textColor = Colors.redAccent;
      fontWeight = FontWeight.bold;
    } else {
      textColor = isDark ? sudokuTheme.textColorDark : sudokuTheme.textColorLight;
      fontWeight = FontWeight.w600;
    }

    return GestureDetector(
      onTap: () {
        ref.read(gameProvider.notifier).selectCell(row, col);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cellBgColor,
          // Bordes interiores de celdas
          border: Border(
            right: BorderSide(
              color: col % 3 == 2 && col != 8
                  ? (isDark ? Colors.white54 : const Color(0xFF555566))
                  : (isDark ? Colors.white10 : Colors.grey[200]!),
              width: col % 3 == 2 && col != 8 ? 2.0 : 0.8,
            ),
            bottom: BorderSide(
              color: row % 3 == 2 && row != 8
                  ? (isDark ? Colors.white54 : const Color(0xFF555566))
                  : (isDark ? Colors.white10 : Colors.grey[200]!),
              width: row % 3 == 2 && row != 8 ? 2.0 : 0.8,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: cell.value != 0
            ? Text(
                '${cell.value}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  // MODO VISIÓN VERDADERA (ESCÁNER DE SECTOR GALÁCTICO): Mostrar "Número Fantasma" (Solución tenue)
                  // únicamente en las celdas vacías del Sector Galáctico (Caja 3x3) actualmente seleccionado.
                  if (gameState.isShowingErrors && isSameBox)
                    Text(
                      '${cell.solutionValue}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark 
                          ? Colors.cyanAccent.withOpacity(0.2) 
                          : Colors.indigo.withOpacity(0.15),
                      ),
                    ),
                  
                  _buildNotesGrid(
                    cell.notes,
                    isDark ? sudokuTheme.textColorDark : sudokuTheme.textColorLight,
                    isDark,
                  ),
                ],
              ),
      ),
    );
  }

  /// Construye la minicuadrícula de 3x3 de marcas a lápiz (notas)
  Widget _buildNotesGrid(Set<int> notes, Color noteColor, bool isDark) {
    if (notes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemBuilder: (context, index) {
          final num = index + 1;
          final hasNote = notes.contains(num);

          return Center(
            child: Text(
              hasNote ? '$num' : '',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
                color: hasNote
                    ? (isDark ? noteColor.withOpacity(0.8) : noteColor.withOpacity(0.75))
                    : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }
}
