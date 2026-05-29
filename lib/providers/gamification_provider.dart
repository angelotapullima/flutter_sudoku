import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gamification_models.dart';
import '../services/api_service.dart';
import '../utils/sudoku_generator.dart';

/// Estado de presentación exclusivo de Torneos Comunitarios Globales.
class GamificationState {
  final GlobalTournament? activeTournament;
  final List<dynamic> tournamentRanking;
  final bool isLoading;
  final String? error;

  GamificationState({
    this.activeTournament,
    this.tournamentRanking = const [],
    this.isLoading = false,
    this.error,
  });

  GamificationState copyWith({
    GlobalTournament? activeTournament,
    List<dynamic>? tournamentRanking,
    bool? isLoading,
    String? error,
  }) {
    return GamificationState(
      activeTournament: activeTournament ?? this.activeTournament,
      tournamentRanking: tournamentRanking ?? this.tournamentRanking,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Administrador de estado encargado de coordinar la participación y rankings de torneos.
class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(GamificationState()) {
    refreshAll();
  }

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, error: null);
    await fetchActiveTournament();
    state = state.copyWith(isLoading: false);
  }

  Future<void> fetchActiveTournament() async {
    final result = await ApiService.getActiveTournament();
    if (result['success']) {
      final tournament =
          GlobalTournament.fromJson(result['data']['tournament']);
      final ranking = result['data']['ranking'] as List<dynamic>;
      state = state.copyWith(
          activeTournament: tournament, tournamentRanking: ranking);
    } else {
      state = state.copyWith(error: result['message']);
    }
  }

  Future<void> submitTournamentResult(int time, int errors) async {
    if (state.activeTournament == null) return;

    final result = await ApiService.submitTournamentResult(
        state.activeTournament!.id, time, errors);

    if (result['success']) {
      await fetchActiveTournament(); // Refrescar ranking
    }
  }

  Future<Map<String, dynamic>> createTournament(
      String title, String difficulty) async {
    // 1. Generar un Sudoku real para el torneo
    final sudokuData = SudokuGenerator.generate(difficulty: difficulty);
    final board = sudokuData['board']!;
    final solution = sudokuData['solution']!;

    // 2. Convertir a string (formato plano) para el servidor
    String puzzleStr = '';
    String solutionStr = '';
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        puzzleStr += board[r][c].toString();
        solutionStr += solution[r][c].toString();
      }
    }

    // 3. Enviar al servidor
    final result = await ApiService.createTournament(
      title: title,
      difficulty: difficulty,
      puzzleData: puzzleStr,
      solutionData: solutionStr,
    );

    if (result['success']) {
      await refreshAll();
      return {'success': true};
    } else {
      return {'success': false, 'message': result['message']};
    }
  }
}

/// Proveedor de estado de torneos expuesto al sistema.
final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier();
});
