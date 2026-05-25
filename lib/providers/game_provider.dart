import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sudoku_cell.dart';
import '../utils/sudoku_generator.dart';
import '../utils/sudoku_crypto.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';
import 'profile_provider.dart';
import 'gamification_provider.dart';
import 'settings_provider.dart';
import 'campaign_provider.dart';

class GameState {
  final List<List<SudokuCell>> grid;
  final int selectedRow;
  final int selectedCol;
  final int errorsCount;
  final bool isGameOver;
  final bool isGameWon;
  final String difficulty;
  final bool isNotesMode;
  final int elapsedSeconds;
  final bool isPaused;
  final int hintsUsed;
  final bool hasStarted;

  // Habilidades Tácticas (Fase 1 GDD)
  final bool isTimerFrozen;
  final bool isShowingErrors;

  // Campos de campaña (Fase 3 GDD)
  final bool isCampaign;
  final int? campaignLevelNumber;

  // Campos de torneo y retos
  final bool isTournament;
  final String tournamentDivision;
  final List<String> tournamentOpponents;
  final List<int> tournamentOpponentTimes;
  final int tournamentPlacement;
  final bool isDailyChallenge;
  final int? tournamentId;

  const GameState({
    this.grid = const [],
    this.selectedRow = -1,
    this.selectedCol = -1,
    this.errorsCount = 0,
    this.isGameOver = false,
    this.isGameWon = false,
    this.difficulty = 'Fácil',
    this.isNotesMode = false,
    this.elapsedSeconds = 0,
    this.isPaused = false,
    this.hintsUsed = 0,
    this.hasStarted = false,
    this.isTimerFrozen = false,
    this.isShowingErrors = false,
    this.isCampaign = false,
    this.campaignLevelNumber,
    this.isTournament = false,
    this.tournamentDivision = '',
    this.tournamentOpponents = const [],
    this.tournamentOpponentTimes = const [],
    this.tournamentPlacement = 0,
    this.isDailyChallenge = false,
    this.tournamentId,
  });

  GameState copyWith({
    List<List<SudokuCell>>? grid,
    int? selectedRow,
    int? selectedCol,
    int? errorsCount,
    bool? isGameOver,
    bool? isGameWon,
    String? difficulty,
    bool? isNotesMode,
    int? elapsedSeconds,
    bool? isPaused,
    int? hintsUsed,
    bool? hasStarted,
    bool? isTimerFrozen,
    bool? isShowingErrors,
    bool? isCampaign,
    int? campaignLevelNumber,
    bool? isTournament,
    String? tournamentDivision,
    List<String>? tournamentOpponents,
    List<int>? tournamentOpponentTimes,
    int? tournamentPlacement,
    bool? isDailyChallenge,
    int? tournamentId,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      errorsCount: errorsCount ?? this.errorsCount,
      isGameOver: isGameOver ?? this.isGameOver,
      isGameWon: isGameWon ?? this.isGameWon,
      difficulty: difficulty ?? this.difficulty,
      isNotesMode: isNotesMode ?? this.isNotesMode,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isPaused: isPaused ?? this.isPaused,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      hasStarted: hasStarted ?? this.hasStarted,
      isTimerFrozen: isTimerFrozen ?? this.isTimerFrozen,
      isShowingErrors: isShowingErrors ?? this.isShowingErrors,
      isCampaign: isCampaign ?? this.isCampaign,
      campaignLevelNumber: campaignLevelNumber ?? this.campaignLevelNumber,
      isTournament: isTournament ?? this.isTournament,
      tournamentDivision: tournamentDivision ?? this.tournamentDivision,
      tournamentOpponents: tournamentOpponents ?? this.tournamentOpponents,
      tournamentOpponentTimes:
          tournamentOpponentTimes ?? this.tournamentOpponentTimes,
      tournamentPlacement: tournamentPlacement ?? this.tournamentPlacement,
      isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
      tournamentId: tournamentId ?? this.tournamentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grid':
          grid.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
      'selectedRow': selectedRow,
      'selectedCol': selectedCol,
      'errorsCount': errorsCount,
      'isGameOver': isGameOver,
      'isGameWon': isGameWon,
      'difficulty': difficulty,
      'isNotesMode': isNotesMode,
      'elapsedSeconds': elapsedSeconds,
      'isPaused': isPaused,
      'hintsUsed': hintsUsed,
      'hasStarted': hasStarted,
      'isTimerFrozen': isTimerFrozen,
      'isShowingErrors': isShowingErrors,
      'isCampaign': isCampaign,
      'campaignLevelNumber': campaignLevelNumber,
      'isTournament': isTournament,
      'tournamentDivision': tournamentDivision,
      'tournamentOpponents': tournamentOpponents,
      'tournamentOpponentTimes': tournamentOpponentTimes,
      'tournamentPlacement': tournamentPlacement,
      'isDailyChallenge': isDailyChallenge,
      'tournamentId': tournamentId,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    var rawGrid = json['grid'] as List<dynamic>;
    List<List<SudokuCell>> parsedGrid = rawGrid.map((row) {
      return (row as List<dynamic>).map((cellJson) {
        return SudokuCell.fromJson(cellJson as Map<String, dynamic>);
      }).toList();
    }).toList();

    return GameState(
      grid: parsedGrid,
      selectedRow: json['selectedRow'] as int? ?? -1,
      selectedCol: json['selectedCol'] as int? ?? -1,
      errorsCount: json['errorsCount'] as int? ?? 0,
      isGameOver: json['isGameOver'] as bool? ?? false,
      isGameWon: json['isGameWon'] as bool? ?? false,
      difficulty: json['difficulty'] as String? ?? 'Fácil',
      isNotesMode: json['isNotesMode'] as bool? ?? false,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      isPaused: json['isPaused'] as bool? ?? false,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      hasStarted: json['hasStarted'] as bool? ?? false,
      isTimerFrozen: json['isTimerFrozen'] as bool? ?? false,
      isShowingErrors: json['isShowingErrors'] as bool? ?? false,
      isCampaign: json['isCampaign'] as bool? ?? false,
      campaignLevelNumber: json['campaignLevelNumber'] as int?,
      isTournament: json['isTournament'] as bool? ?? false,
      tournamentDivision: json['tournamentDivision'] as String? ?? '',
      tournamentOpponents: List<String>.from(
          json['tournamentOpponents'] as List<dynamic>? ?? []),
      tournamentOpponentTimes: List<int>.from(
          json['tournamentOpponentTimes'] as List<dynamic>? ?? []),
      tournamentPlacement: json['tournamentPlacement'] as int? ?? 0,
      isDailyChallenge: json['isDailyChallenge'] as bool? ?? false,
      tournamentId: json['tournamentId'] as int?,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final StorageService _storageService;
  final Ref _ref;
  Timer? _timer;

  // Historial inmutable para Undo/Redo de la grilla
  final List<List<List<SudokuCell>>> _undoStack = [];

  GameNotifier(this._storageService, this._ref) : super(const GameState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Inicializa o reanuda una partida guardada al iniciar la app.
  void tryLoadSavedGame() {
    final savedJson = _storageService.getActiveGame();
    if (savedJson != null) {
      try {
        final parsed = jsonDecode(savedJson) as Map<String, dynamic>;
        state = GameState.fromJson(parsed);
        if (state.hasStarted &&
            !state.isGameOver &&
            !state.isGameWon &&
            !state.isPaused) {
          _startTimer();
        }
      } catch (_) {
        _storageService.clearActiveGame();
      }
    }
  }

  /// Genera una nueva partida de Sudoku.
  void startNewGame(String difficulty) {
    _timer?.cancel();
    _undoStack.clear();

    final sudokuData = SudokuGenerator.generate(difficulty: difficulty);
    final board = sudokuData['board']!;
    final solution = sudokuData['solution']!;

    List<List<SudokuCell>> newGrid = List.generate(9, (r) {
      return List.generate(9, (c) {
        final val = board[r][c];
        return SudokuCell(
          row: r,
          col: c,
          value: val,
          solutionValue: solution[r][c],
          isOriginal: val != 0,
        );
      });
    });

    state = GameState(
      grid: newGrid,
      difficulty: difficulty,
      hasStarted: true,
    );

    // Guardar partida iniciada en estadísticas locales
    final currentPlayed = _storageService.getGamesPlayed(difficulty);
    _storageService.saveGamesPlayed(difficulty, currentPlayed + 1);

    _startTimer();
    _saveGameToStorage();
  }

  /// Genera un reto diario con una semilla específica y dificultad.
  void startDailyChallengeGame(int seed, String difficulty) {
    _timer?.cancel();
    _undoStack.clear();

    final sudokuData = SudokuGenerator.generate(difficulty: difficulty, seed: seed);
    final board = sudokuData['board']!;
    final solution = sudokuData['solution']!;

    List<List<SudokuCell>> newGrid = List.generate(9, (r) {
      return List.generate(9, (c) {
        final val = board[r][c];
        return SudokuCell(
          row: r,
          col: c,
          value: val,
          solutionValue: solution[r][c],
          isOriginal: val != 0,
        );
      });
    });

    state = GameState(
      grid: newGrid,
      difficulty: difficulty,
      hasStarted: true,
      isDailyChallenge: true,
    );

    _startTimer();
    _saveGameToStorage();
  }

  /// Genera una nueva partida de torneo real con tablero de la nube.
  void startRealTournamentGame(
      int tournamentId, String puzzle, String solution, String difficulty) {
    _timer?.cancel();
    _undoStack.clear();

    // Validación de seguridad para evitar RangeError (Fase 3 Fix)
    // El puzzle y la solución deben tener exactamente 81 caracteres.
    final String cleanPuzzle = puzzle.padRight(81, '0').substring(0, 81);
    final String decryptedSolution = SudokuCrypto.decryptSolutionResilient(solution);
    final String cleanSolution = decryptedSolution.padRight(81, '1').substring(0, 81);

    List<List<SudokuCell>> newGrid = List.generate(9, (r) {
      return List.generate(9, (c) {
        final index = r * 9 + c;
        final val = int.tryParse(cleanPuzzle[index]) ?? 0;
        final sol = int.tryParse(cleanSolution[index]) ?? 1;
        
        return SudokuCell(
          row: r,
          col: c,
          value: val,
          solutionValue: sol,
          isOriginal: val != 0,
        );
      });
    });

    state = GameState(
      grid: newGrid,
      difficulty: difficulty,
      hasStarted: true,
      isTournament: true,
      tournamentId: tournamentId,
    );

    _startTimer();
    _saveGameToStorage();
  }

  /// Alterna el modo pausa.
  void togglePause() {
    if (!state.hasStarted || state.isGameOver || state.isGameWon) return;

    if (state.isPaused) {
      state = state.copyWith(isPaused: false);
      _startTimer();
    } else {
      _timer?.cancel();
      state = state.copyWith(isPaused: true);
    }
    _saveGameToStorage();
  }

  /// Selecciona una celda.
  void selectCell(int row, int col) {
    if (state.isPaused || state.isGameOver || state.isGameWon) return;
    state = state.copyWith(selectedRow: row, selectedCol: col);
  }

  /// Inserta un número (1-9) en la celda seleccionada.
  void inputNumber(int num) {
    final r = state.selectedRow;
    final c = state.selectedCol;

    if (r == -1 ||
        c == -1 ||
        state.isPaused ||
        state.isGameOver ||
        state.isGameWon) return;

    final cell = state.grid[r][c];
    if (cell.isOriginal) return; // Las celdas iniciales son inmutables

    // Guardar estado actual en la pila de deshacer
    _pushToUndoStack();

    if (state.isNotesMode) {
      // MODO NOTAS: Insertar/Quitar candidato
      final newNotes = Set<int>.from(cell.notes);
      if (newNotes.contains(num)) {
        newNotes.remove(num);
      } else {
        newNotes.add(num);
      }

      final updatedCell =
          cell.copyWith(notes: newNotes, value: 0, isError: false);
      _updateGridCell(r, c, updatedCell);
    } else {
      // MODO VALOR FINAL
      if (cell.value == num) return; // Ya tiene el mismo número

      bool isError = num != cell.solutionValue;
      final updatedCell = cell.copyWith(
        value: num,
        notes: {}, // Limpiamos notas si colocamos valor final
        isError: isError,
      );

      _updateGridCell(r, c, updatedCell);

      if (isError) {
        final settings = _ref.read(settingsProvider);

        // Vibración háptica solo si está activada en la configuración
        if (settings.enableVibration) {
          HapticFeedback.vibrate();
        }

        // Límite de 3 errores estricto solo si está activado en la configuración
        if (settings.enableErrorLimit) {
          final newErrors = state.errorsCount + 1;
          state = state.copyWith(errorsCount: newErrors);

          if (newErrors >= 3) {
            _triggerGameOver();
          }
        }
      } else {
        // Correcto: Verificar si hemos resuelto el Sudoku entero
        _checkVictory();
      }
    }

    _saveGameToStorage();
  }

  /// Borra el contenido de la celda seleccionada.
  void eraseCell() {
    final r = state.selectedRow;
    final c = state.selectedCol;

    if (r == -1 ||
        c == -1 ||
        state.isPaused ||
        state.isGameOver ||
        state.isGameWon) return;

    final cell = state.grid[r][c];
    if (cell.isOriginal || cell.value == 0 && cell.notes.isEmpty) return;

    _pushToUndoStack();

    final updatedCell = cell.copyWith(value: 0, notes: {}, isError: false);
    _updateGridCell(r, c, updatedCell);

    _saveGameToStorage();
  }

  /// Alterna el modo Notas (Lápiz).
  void toggleNotesMode() {
    state = state.copyWith(isNotesMode: !state.isNotesMode);
  }

  /// Deshace la última jugada de la pila de historial.
  void undo() {
    if (_undoStack.isEmpty ||
        state.isPaused ||
        state.isGameOver ||
        state.isGameWon) return;

    final previousGrid = _undoStack.removeLast();
    state = state.copyWith(grid: previousGrid);
    _saveGameToStorage();
  }

  /// Proporciona una pista en la celda seleccionada.
  String useHint() {
    final r = state.selectedRow;
    final c = state.selectedCol;

    if (r == -1 || c == -1) return 'noSelection';
    if (state.isPaused || state.isGameOver || state.isGameWon)
      return 'invalidState';

    final cell = state.grid[r][c];
    if (cell.isOriginal || cell.value == cell.solutionValue)
      return 'alreadyCorrect';

    // Verificar si cuesta monedas (las primeras 3 pistas son gratuitas por partida)
    final profileNotifier = _ref.read(profileProvider.notifier);
    if (state.hintsUsed >= 3) {
      final success = profileNotifier.deductCoins(35); // Cuesta 35 S-Coins
      if (!success) return 'noCoins'; // No hay suficientes monedas
    }

    _pushToUndoStack();

    final updatedCell = cell.copyWith(
      value: cell.solutionValue,
      notes: {},
      isError: false,
    );

    _updateGridCell(r, c, updatedCell);
    state = state.copyWith(hintsUsed: state.hintsUsed + 1);

    _checkVictory();
    _saveGameToStorage();
    return 'success';
  }

  /// Otorga una "Segunda Oportunidad" reviviendo al usuario tras cometer 3 errores.
  bool useSecondChance() {
    if (!state.isGameOver) return false;

    final profileNotifier = _ref.read(profileProvider.notifier);
    final success =
        profileNotifier.deductCoins(50); // Cuesta 50 S-Coins para revivir
    if (!success) return false;

    // Restauramos el juego con 2 errores y quitamos el GameOver
    state = state.copyWith(
      isGameOver: false,
      errorsCount: 2,
    );
    _startTimer();
    _saveGameToStorage();
    return true;
  }

  /// Limpia la partida activa del almacenamiento local.
  void quitGame() {
    _timer?.cancel();
    _storageService.clearActiveGame();
    state = const GameState();
  }

  /// HABILIDAD: TOQUE DIVINO (Limpia errores y revela 3 números al azar)
  bool useDivineTouch() {
    if (!state.hasStarted || state.isGameOver || state.isGameWon) return false;

    final profileNotifier = _ref.read(profileProvider.notifier);
    final userProfile = _ref.read(profileProvider);

    // Verificar e implementar la lógica híbrida F2P (Cargas vs. Monedas en caliente)
    if (userProfile.divineTouchCharges > 0) {
      // 1. Consumir carga del inventario si tiene
      profileNotifier.updateProfile(userProfile.copyWith(
        divineTouchCharges: userProfile.divineTouchCharges - 1
      ));
    } else {
      // 2. Si no tiene cargas, comprar en caliente por 130 S-Coins (penalización)
      if (userProfile.coins < 130) return false;
      profileNotifier.deductCoins(130);
    }

    _pushToUndoStack();

    // 1. Limpiar todos los errores existentes en el grid
    List<List<SudokuCell>> newGrid = List.generate(9, (r) {
      return List.generate(9, (c) {
        final cell = state.grid[r][c];
        if (cell.isError) {
          return cell.copyWith(value: 0, isError: false, notes: {});
        }
        return cell;
      });
    });

    // 2. Encontrar casillas vacías para rellenar 3
    List<SudokuCell> emptyCells = [];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (newGrid[r][c].value == 0) {
          emptyCells.add(newGrid[r][c]);
        }
      }
    }

    emptyCells.shuffle();
    final cellsToFill = emptyCells.take(3).toList();

    for (var targetCell in cellsToFill) {
      newGrid[targetCell.row][targetCell.col] = targetCell.copyWith(
        value: targetCell.solutionValue,
        notes: {},
        isError: false,
      );
    }

    state = state.copyWith(grid: newGrid);
    
    _checkVictory();
    _saveGameToStorage();
    return true;
  }

  /// SIMULACIÓN DE PODERES PARA EL TUTORIAL (Sin costo de cargas)
  void simulateFreezeTimer() {
    state = state.copyWith(isTimerFrozen: true);
    Timer(const Duration(seconds: 15), () {
      if (mounted) state = state.copyWith(isTimerFrozen: false);
    });
  }

  void simulateTrueVision() {
    // Safeguard: Seleccionar la primera celda vacía si no hay ninguna seleccionada
    int selR = state.selectedRow;
    int selC = state.selectedCol;
    if (selR == -1 || selC == -1) {
      bool found = false;
      for (int r = 0; r < 9 && !found; r++) {
        for (int c = 0; c < 9 && !found; c++) {
          if (state.grid[r][c].value == 0) {
            selR = r;
            selC = c;
            found = true;
          }
        }
      }
      if (found) {
        state = state.copyWith(selectedRow: selR, selectedCol: selC);
      } else {
        state = state.copyWith(selectedRow: 0, selectedCol: 0);
      }
    }

    state = state.copyWith(isShowingErrors: true);
    Timer(const Duration(seconds: 10), () {
      if (mounted) state = state.copyWith(isShowingErrors: false);
    });
  }

  void simulateDivineTouch() {
    List<List<SudokuCell>> newGrid = List.generate(9, (r) {
      return List.generate(9, (c) {
        final cell = state.grid[r][c];
        return cell.isError ? cell.copyWith(value: 0, isError: false, notes: {}) : cell;
      });
    });

    List<SudokuCell> emptyCells = [];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (newGrid[r][c].value == 0) emptyCells.add(newGrid[r][c]);
      }
    }
    emptyCells.shuffle();
    final cellsToFill = emptyCells.take(3).toList();

    for (var targetCell in cellsToFill) {
      newGrid[targetCell.row][targetCell.col] = targetCell.copyWith(
        value: targetCell.solutionValue,
        notes: {},
        isError: false,
      );
    }
    state = state.copyWith(grid: newGrid);
  }

  // --- MÉTODOS DE APOYO INTERNOS ---

  /// HABILIDAD: RELOJ ESTELAR (Congela el cronómetro por 45 segundos)
  bool useFreezeTimer() {
    if (state.isTimerFrozen || !state.hasStarted || state.isGameOver || state.isGameWon) return false;

    final profileNotifier = _ref.read(profileProvider.notifier);
    final userProfile = _ref.read(profileProvider);

    // Verificar e implementar la lógica híbrida F2P (Cargas vs. Monedas en caliente)
    if (userProfile.timeFreezeCharges > 0) {
      // 1. Consumir carga del inventario si tiene
      profileNotifier.updateProfile(userProfile.copyWith(
        timeFreezeCharges: userProfile.timeFreezeCharges - 1
      ));
    } else {
      // 2. Si no tiene cargas, comprar en caliente por 45 S-Coins (penalización)
      if (userProfile.coins < 45) return false;
      profileNotifier.deductCoins(45);
    }

    state = state.copyWith(isTimerFrozen: true);

    // El cronómetro volverá a correr en 45 segundos
    Timer(const Duration(seconds: 45), () {
      if (mounted) {
        state = state.copyWith(isTimerFrozen: false);
      }
    });

    _saveGameToStorage();
    return true;
  }

  /// HABILIDAD: VISIÓN VERDADERA (Resalta errores actuales por 10 segundos)
  bool useTrueVision() {
    if (state.isShowingErrors || !state.hasStarted || state.isGameOver || state.isGameWon) return false;

    final profileNotifier = _ref.read(profileProvider.notifier);
    final userProfile = _ref.read(profileProvider);

    // Verificar e implementar la lógica híbrida F2P (Cargas vs. Monedas en caliente)
    if (userProfile.visionCharges > 0) {
      // 1. Consumir carga del inventario si tiene
      profileNotifier.updateProfile(userProfile.copyWith(
        visionCharges: userProfile.visionCharges - 1
      ));
    } else {
      // 2. Si no tiene cargas, comprar en caliente por 65 S-Coins (penalización)
      if (userProfile.coins < 65) return false;
      profileNotifier.deductCoins(65);
    }

    // Safeguard: Seleccionar la primera celda vacía si no hay ninguna seleccionada
    int selR = state.selectedRow;
    int selC = state.selectedCol;
    if (selR == -1 || selC == -1) {
      bool found = false;
      for (int r = 0; r < 9 && !found; r++) {
        for (int c = 0; c < 9 && !found; c++) {
          if (state.grid[r][c].value == 0) {
            selR = r;
            selC = c;
            found = true;
          }
        }
      }
      if (found) {
        state = state.copyWith(selectedRow: selR, selectedCol: selC);
      } else {
        state = state.copyWith(selectedRow: 0, selectedCol: 0);
      }
    }

    state = state.copyWith(isShowingErrors: true);

    // Las pistas desaparecen en 10 segundos (Rebalanceado de 15s para mayor desafío)
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        state = state.copyWith(isShowingErrors: false);
      }
    });

    _saveGameToStorage();
    return true;
  }
  /// Genera una nueva partida de campaña (Fase 3 - Mapa Estelar)
  void startCampaignGame(
      int levelNumber, String puzzle, String solution, String difficulty) {
    _timer?.cancel();
    _undoStack.clear();

    final String cleanPuzzle = puzzle.padRight(81, '0').substring(0, 81);
    final String decryptedSolution = SudokuCrypto.decryptSolutionResilient(solution);
    final String cleanSolution = decryptedSolution.padRight(81, '1').substring(0, 81);

    List<List<SudokuCell>> newGrid = List.generate(9, (r) {
      return List.generate(9, (c) {
        final index = r * 9 + c;
        final val = int.tryParse(cleanPuzzle[index]) ?? 0;
        final sol = int.tryParse(cleanSolution[index]) ?? 1;
        return SudokuCell(
          row: r,
          col: c,
          value: val,
          solutionValue: sol,
          isOriginal: val != 0,
        );
      });
    });

    state = GameState(
      grid: newGrid,
      difficulty: difficulty,
      hasStarted: true,
      isCampaign: true,
      campaignLevelNumber: levelNumber,
    );

    _startTimer();
    _saveGameToStorage();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isTimerFrozen) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
        _saveGameToStorage();
      }
    });
  }

  void _pushToUndoStack() {
    // Generar copia profunda de la grilla de celdas
    List<List<SudokuCell>> gridClone =
        List.generate(9, (r) => List.from(state.grid[r]));
    _undoStack.add(gridClone);
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0); // Límite de historial de 50 pasos
    }
  }

  void _updateGridCell(int row, int col, SudokuCell newCell) {
    List<List<SudokuCell>> newGrid = List.generate(9, (r) {
      return List.generate(9, (c) {
        if (r == row && c == col) return newCell;
        return state.grid[r][c];
      });
    });
    state = state.copyWith(grid: newGrid);
  }

  void _triggerGameOver() {
    _timer?.cancel();
    state = state.copyWith(isGameOver: true);
    _storageService.clearActiveGame();
  }

  void _checkVictory() {
    // Si todas las celdas tienen el valor de la solución
    bool won = true;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (state.grid[r][c].value != state.grid[r][c].solutionValue) {
          won = false;
          break;
        }
      }
    }

    if (won) {
      _timer?.cancel();
      state = state.copyWith(isGameWon: true);
      _storageService.clearActiveGame();

      // Procesar recompensas de negocio en profileProvider
      final profileNotifier = _ref.read(profileProvider.notifier);

      // 1. Monedas base por dificultad (partida normal)
      int rewardCoins = 25;
      int xpGained = 200;

      if (state.isDailyChallenge) {
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        profileNotifier.completeDailyChallenge(todayStr);
        rewardCoins = 0;
        xpGained = 0;
      } else if (!state.isTournament) {
        switch (state.difficulty.toLowerCase()) {
          case 'fácil':
          case 'easy':
            rewardCoins = 20;
            xpGained = 150;
            break;
          case 'medio':
          case 'medium':
            rewardCoins = 40;
            xpGained = 300;
            break;
          case 'difícil':
          case 'hard':
            rewardCoins = 75;
            xpGained = 500;
            break;
          case 'experto':
          case 'expert':
            rewardCoins = 150;
            xpGained = 800;
            break;
        }
      }

      // Calcular posición en el torneo si corresponde
      if (state.isTournament && state.tournamentId != null) {
        // Enviar resultado real al servidor
        final gamification = _ref.read(gamificationProvider.notifier);
        gamification.submitTournamentResult(state.elapsedSeconds, state.errorsCount);
        
        // El ranking se actualizará automáticamente al volver a la pantalla de torneo
      }

      // 2. Bono de Perfección (sin errores) - Solo partidas normales
      if (!state.isTournament && state.errorsCount == 0) {
        rewardCoins += 25;
        xpGained += 100;
        profileNotifier.unlockAchievement('mente_acero');
      }

      // --- ACTUALIZAR MISIONES DIARIAS ---
      final gamification = _ref.read(gamificationProvider.notifier);
      
      // Misión: Ganar partidas
      if (!state.isDailyChallenge) {
        // Buscar si hay misión de "win_games"
        final missions = _ref.read(gamificationProvider).missions;
        for (var m in missions) {
          if (!m.isCompleted) {
             gamification.updateMissionProgress(m.id);
          }
        }
      }

      // 3. Bono de Resiliencia (2 errores y ganar)
      if (state.errorsCount == 2) {
        profileNotifier.unlockAchievement('resiliencia');
      }

      // 4. Bono de velocidad (menos de 4 minutos = 240 segundos)
      if (state.elapsedSeconds < 240) {
        profileNotifier.unlockAchievement('velocista');
      }

      // 5. Logro: Sabio Relámpago (menos de 2.5 min = 150 segundos)
      if (state.elapsedSeconds < 150) {
        profileNotifier.unlockAchievement('sabio_relampago');
      }

      // 6. Logro: El Intocable (sin pistas y sin errores)
      if (state.hintsUsed == 0 && state.errorsCount == 0) {
        profileNotifier.unlockAchievement('el_intocable');
      }

      // 7. Logro: Maestría Absoluta (completar dificultad Experto)
      if (state.difficulty.toLowerCase() == 'experto' ||
          state.difficulty.toLowerCase() == 'expert') {
        profileNotifier.unlockAchievement('gran_maestro');
      }

      // --- LÓGICA DE CAMPAÑA (Fase 3 - Desbloqueo de Niveles) ---
      if (state.isCampaign && state.campaignLevelNumber != null) {
        _ref.read(campaignProvider.notifier).completeLevel(state.campaignLevelNumber!);
      }

      profileNotifier.unlockAchievement('primera_victoria');

      if (rewardCoins > 0) {
        profileNotifier.addCoins(rewardCoins);
      }
      if (xpGained > 0) {
        profileNotifier.addXp(xpGained);
      }

      profileNotifier.checkDailyStreak();

      // Guardar victoria en estadísticas locales
      final currentWon = _storageService.getGamesWon(state.difficulty);
      _storageService.saveGamesWon(state.difficulty, currentWon + 1);

      // Guardar récord de mejor tiempo
      final bestTime = _storageService.getBestTime(state.difficulty);
      if (bestTime == 0 || state.elapsedSeconds < bestTime) {
        _storageService.saveBestTime(state.difficulty, state.elapsedSeconds);
      }

      // Sincronizar victoria y progreso nuevo con la nube
      profileNotifier.syncWithServer();
    }
  }

  void _saveGameToStorage() {
    // NO GUARDAR PARTIDAS DE TUTORIAL (Evita que aparezcan en la Home)
    if (state.difficulty == 'Tutorial') return;

    if (state.hasStarted && !state.isGameOver && !state.isGameWon) {
      final jsonStr = jsonEncode(state.toJson());
      _storageService.saveActiveGame(jsonStr);
    }
  }
}

// Proveedor global de la partida de Sudoku
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return GameNotifier(storage, ref);
});
