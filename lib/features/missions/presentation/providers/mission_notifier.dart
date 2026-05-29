import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/daily_mission.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/usecases/get_daily_missions_usecase.dart';
import '../../domain/usecases/update_mission_progress_usecase.dart';
import '../../data/datasources/mission_remote_data_source.dart';
import '../../data/repositories/mission_repository_impl.dart';
import '../../../auth/presentation/providers/auth_notifier.dart'; // Para authLocalDataSourceProvider
import '../../../leaderboards/presentation/providers/leaderboard_notifier.dart'; // Para httpClientProvider
import '../../../../providers/profile_provider.dart'; // Para profileProvider

// =========================================================================
// 1. ESTADO DE PRESENTACIÓN (Missions State)
// =========================================================================

/// Clase inmutable que representa el estado del tablón de misiones en la interfaz.
class MissionsState {
  final List<DailyMission> missionsList;
  final bool isLoading;
  final String? errorMessage;

  const MissionsState({
    this.missionsList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MissionsState copyWith({
    List<DailyMission>? missionsList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MissionsState(
      missionsList: missionsList ?? this.missionsList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Permite limpiar el error pasando null
    );
  }
}

// =========================================================================
// 2. INYECCIÓN DE DEPENDENCIAS (Riverpod Providers)
// =========================================================================

/// Inyección del Data Source remoto de misiones.
final missionRemoteDataSourceProvider =
    Provider<MissionRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final authLocal = ref.watch(authLocalDataSourceProvider);
  return MissionRemoteDataSourceImpl(
    client: client,
    authLocalDataSource: authLocal,
  );
});

/// Inyección de la implementación del repositorio de misiones.
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final remote = ref.watch(missionRemoteDataSourceProvider);
  return MissionRepositoryImpl(remoteDataSource: remote);
});

/// Inyección del caso de uso para consultar las misiones.
final getDailyMissionsUseCaseProvider =
    Provider<GetDailyMissionsUseCase>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return GetDailyMissionsUseCase(repository);
});

/// Inyección del caso de uso para actualizar progreso de una misión.
final updateMissionProgressUseCaseProvider =
    Provider<UpdateMissionProgressUseCase>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return UpdateMissionProgressUseCase(repository);
});

/// Proveedor global para consumir el estado de misiones diarias en la interfaz de usuario.
final missionsStateProvider =
    StateNotifierProvider<MissionsNotifier, MissionsState>((ref) {
  final getMissions = ref.watch(getDailyMissionsUseCaseProvider);
  final updateProgress = ref.watch(updateMissionProgressUseCaseProvider);
  return MissionsNotifier(
    getDailyMissionsUseCase: getMissions,
    updateMissionProgressUseCase: updateProgress,
    ref: ref,
  )..fetchDailyMissions();
});

// =========================================================================
// 3. ADMINISTRADOR DE ESTADO (Missions Notifier)
// =========================================================================

/// StateNotifier encargado de administrar la reactividad y llamadas de las misiones diarias.
class MissionsNotifier extends StateNotifier<MissionsState> {
  final GetDailyMissionsUseCase _getDailyMissionsUseCase;
  final UpdateMissionProgressUseCase _updateMissionProgressUseCase;
  final Ref _ref;

  MissionsNotifier({
    required GetDailyMissionsUseCase getDailyMissionsUseCase,
    required UpdateMissionProgressUseCase updateMissionProgressUseCase,
    required Ref ref,
  })  : _getDailyMissionsUseCase = getDailyMissionsUseCase,
        _updateMissionProgressUseCase = updateMissionProgressUseCase,
        _ref = ref,
        super(const MissionsState());

  /// Consulta el tablón de misiones del servidor actualizando el estado de la vista.
  Future<void> fetchDailyMissions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getDailyMissionsUseCase();

    result.fold(
      (list) {
        state = state.copyWith(
          missionsList: list,
          isLoading: false,
        );
      },
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
    );
  }

  /// Informa sobre progreso en una misión y sincroniza automáticamente las monedas y experiencia del perfil.
  Future<void> updateMissionProgress(int missionId, {int increment = 1}) async {
    final result = await _updateMissionProgressUseCase(
      missionId: missionId,
      increment: increment,
    );

    result.fold(
      (_) async {
        // Refrescar el tablón de misiones localmente
        await fetchDailyMissions();
        // Sincronizar de inmediato el perfil para reflejar posibles recompensas (S-Coins, XP)
        await _ref.read(profileProvider.notifier).refreshProfileFromServer();
      },
      (failure) {
        // Reportar el fallo en el estado de misiones sin interrumpir
        state = state.copyWith(errorMessage: failure.message);
      },
    );
  }
}
