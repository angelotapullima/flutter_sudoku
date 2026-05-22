import 'dart:math';

class SudokuGenerator {
  static final Random _random = Random();

  /// Genera un nuevo tablero de Sudoku y su solución.
  /// Retorna un mapa con 'board' (tablero para jugar con ceros) y 'solution' (tablero completo).
  static Map<String, List<List<int>>> generate({required String difficulty}) {
    // 1. Crear un tablero vacío
    List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));

    // 2. Llenar el tablero completamente con backtracking aleatorio
    _fillBoard(solution);

    // 3. Clonar el tablero completo para crear el de juego
    List<List<int>> board = List.generate(9, (r) => List.from(solution[r]));

    // 4. Remover celdas según la dificultad asegurando una solución única
    int cellsToRemove = 40; // Por defecto
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        cellsToRemove = 36; // Quedan ~45 celdas
        break;
      case 'medio':
      case 'medium':
        cellsToRemove = 46; // Quedan ~35 celdas
        break;
      case 'difícil':
      case 'hard':
        cellsToRemove = 53; // Quedan ~28 celdas
        break;
      case 'experto':
      case 'expert':
        cellsToRemove = 58; // Quedan ~23 celdas
        break;
    }

    _removeCells(board, solution, cellsToRemove);

    return {
      'board': board,
      'solution': solution,
    };
  }

  /// Llena el tablero completamente respetando las reglas clásicas.
  static bool _fillBoard(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          // Generar números del 1 al 9 en orden aleatorio
          List<int> numbers = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (int num in numbers) {
            if (isValid(board, r, c, num)) {
              board[r][c] = num;
              if (_fillBoard(board)) {
                return true;
              }
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Verifica si colocar `num` en la posición `(row, col)` es válido.
  static bool isValid(List<List<int>> board, int row, int col, int num) {
    // Verificar fila
    for (int c = 0; c < 9; c++) {
      if (c != col && board[row][c] == num) return false;
    }

    // Verificar columna
    for (int r = 0; r < 9; r++) {
      if (r != row && board[r][col] == num) return false;
    }

    // Verificar subcuadrícula 3x3
    int boxRowStart = (row ~/ 3) * 3;
    int boxColStart = (col ~/ 3) * 3;
    for (int r = boxRowStart; r < boxRowStart + 3; r++) {
      for (int c = boxColStart; c < boxColStart + 3; c++) {
        if ((r != row || c != col) && board[r][c] == num) return false;
      }
    }

    return true;
  }

  /// Remueve `count` celdas asegurando que el Sudoku resultante tenga una solución única.
  static void _removeCells(List<List<int>> board, List<List<int>> solution, int count) {
    int attempts = 0;
    int removed = 0;
    List<int> cellIndices = List.generate(81, (i) => i)..shuffle(_random);

    for (int idx in cellIndices) {
      if (removed >= count || attempts > 200) break;

      int r = idx ~/ 9;
      int c = idx % 9;

      if (board[r][c] != 0) {
        int backup = board[r][c];
        board[r][c] = 0;

        // Comprobar si la solución sigue siendo única
        if (_hasUniqueSolution(board)) {
          removed++;
        } else {
          // Si no es única, restauramos el número
          board[r][c] = backup;
        }
      }
      attempts++;
    }

    // Si por intentos aleatorios no llegamos a remover todos, hacemos una pasada forzada rápida
    // para garantizar que al menos se acerque al nivel de dificultad
    if (removed < count) {
      for (int idx in cellIndices) {
        if (removed >= count) break;
        int r = idx ~/ 9;
        int c = idx % 9;
        if (board[r][c] != 0) {
          int backup = board[r][c];
          board[r][c] = 0;
          if (_hasUniqueSolution(board)) {
            removed++;
          } else {
            board[r][c] = backup;
          }
        }
      }
    }
  }

  /// Verifica si el tablero actual tiene una única solución posible.
  static bool _hasUniqueSolution(List<List<int>> board) {
    // Clonar el tablero para no modificar el original durante la resolución
    List<List<int>> tempBoard = List.generate(9, (r) => List.from(board[r]));
    int solutionsCount = 0;

    bool solve(int row, int col) {
      if (row == 9) {
        solutionsCount++;
        return solutionsCount > 1; // Detener si hay más de una solución
      }

      int nextRow = (col == 8) ? row + 1 : row;
      int nextCol = (col == 8) ? 0 : col + 1;

      if (tempBoard[row][col] != 0) {
        return solve(nextRow, nextCol);
      }

      for (int num = 1; num <= 9; num++) {
        if (isValid(tempBoard, row, col, num)) {
          tempBoard[row][col] = num;
          if (solve(nextRow, nextCol)) {
            return true;
          }
          tempBoard[row][col] = 0;
        }
      }
      return false;
    }

    solve(0, 0);
    return solutionsCount == 1;
  }
}
