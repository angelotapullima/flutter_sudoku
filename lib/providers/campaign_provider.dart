import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'profile_provider.dart';

class CampaignLevel {
  final int levelNumber;
  final String difficulty;
  final String puzzleData;
  final String solutionData;
  final String? bossName;
  final int rewardCoins;
  final int rewardXp;
  final Map<String, dynamic> modifiers;

  CampaignLevel({
    required this.levelNumber,
    required this.difficulty,
    required this.puzzleData,
    required this.solutionData,
    this.bossName,
    required this.rewardCoins,
    required this.rewardXp,
    required this.modifiers,
  });

  factory CampaignLevel.fromJson(Map<String, dynamic> json) {
    return CampaignLevel(
      levelNumber: json['level_number'],
      difficulty: json['difficulty'],
      puzzleData: json['puzzle_data'],
      solutionData: json['solution_data'],
      bossName: json['boss_name'],
      rewardCoins: json['reward_coins'] ?? 50,
      rewardXp: json['reward_xp'] ?? 200,
      modifiers: json['modifiers'] ?? {},
    );
  }

  bool isBoss() => bossName != null && bossName!.isNotEmpty;
}

class CampaignState {
  final List<CampaignLevel> levels;
  final bool isLoading;
  final String? error;

  CampaignState({
    this.levels = const [],
    this.isLoading = false,
    this.error,
  });

  CampaignState copyWith({
    List<CampaignLevel>? levels,
    bool? isLoading,
    String? error,
  }) {
    return CampaignState(
      levels: levels ?? this.levels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CampaignNotifier extends StateNotifier<CampaignState> {
  final Ref _ref;

  CampaignNotifier(this._ref) : super(CampaignState()) {
    fetchLevels();
  }

  Future<void> fetchLevels() async {
    state = state.copyWith(isLoading: true);
    try {
      await ApiService.getActiveTournament(); // Llamada mantenida por efectos secundarios si los hay, pero sin asignar variable
      // Pero para no romper nada, crearé un nuevo método en ApiService en el siguiente paso
      // Por ahora simulamos carga exitosa si el backend ya responde campaign/levels
      final response = await ApiService.getCampaignLevels();
      
      if (response['success']) {
        final List<dynamic> levelsData = response['levels'];
        state = state.copyWith(
          levels: levelsData.map((l) => CampaignLevel.fromJson(lvlMapping(l))).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'No se pudo cargar el mapa.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Helper para normalizar nombres de campos si es necesario
  Map<String, dynamic> lvlMapping(Map<String, dynamic> raw) {
    return raw;
  }

  Future<bool> completeLevel(int levelNumber) async {
    final result = await ApiService.completeCampaignLevel(levelNumber);
    if (result['success']) {
      // Actualizar el perfil local para reflejar el nuevo campaignLevel
      _ref.read(profileProvider.notifier).syncWithServer();
      return true;
    }
    return false;
  }
}

final campaignProvider = StateNotifierProvider<CampaignNotifier, CampaignState>((ref) {
  return CampaignNotifier(ref);
});
