import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/leaderboard_player.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';
import '../../data/datasources/leaderboard_remote_data_source.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';

// =========================================================================
// 1. ESTADO DE LA VISTA (Presentation State)
// =========================================================================

/// Clase inmutable que modela todos los estados lógicos de la vista de clasificaciones.
class LeaderboardState {
  final List<LeaderboardPlayer> players;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadMoreRunning;

  const LeaderboardState({
    this.players = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadMoreRunning = false,
  });

  LeaderboardState copyWith({
    List<LeaderboardPlayer>? players,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadMoreRunning,
  }) {
    return LeaderboardState(
      players: players ?? this.players,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Permite pasar nulo para limpiar el error
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadMoreRunning: isLoadMoreRunning ?? this.isLoadMoreRunning,
    );
  }
}

// =========================================================================
// 2. INYECCIÓN DE DEPENDENCIAS (Dependency Injection Providers)
// =========================================================================

/// Cliente HTTP global inyectado.
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

/// Fuente de datos remota de clasificaciones.
final leaderboardDataSourceProvider =
    Provider<LeaderboardRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return LeaderboardRemoteDataSourceImpl(client: client);
});

/// Repositorio concreto de clasificaciones.
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final dataSource = ref.watch(leaderboardDataSourceProvider);
  return LeaderboardRepositoryImpl(remoteDataSource: dataSource);
});

/// Caso de uso específico para consultar clasificaciones globales.
final getLeaderboardUseCaseProvider = Provider<GetLeaderboardUseCase>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return GetLeaderboardUseCase(repository);
});

// =========================================================================
// 3. ADMINISTRADOR DE ESTADO (StateNotifier)
// =========================================================================

/// StateNotifier de nivel Senior encargado de coordinar los estados y flujos de negocio.
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final GetLeaderboardUseCase _getLeaderboardUseCase;

  String _currentType = 'level';
  String _currentDifficulty = 'General';

  LeaderboardNotifier(this._getLeaderboardUseCase)
      : super(const LeaderboardState());

  /// Consulta inicial del ranking global (resetea paginación).
  Future<void> fetchLeaderboard({
    required String type,
    required String difficulty,
  }) async {
    _currentType = type;
    _currentDifficulty = difficulty;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      hasMore: true,
      players: [],
    );

    final result = await _getLeaderboardUseCase(
      type: type,
      difficulty: difficulty,
      page: 1,
      limit: 15,
    );

    result.fold(
      (playersList) {
        state = state.copyWith(
          players: playersList,
          isLoading: false,
          hasMore: playersList.length >= 15,
        );
      },
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
          hasMore: false,
        );
      },
    );
  }

  /// Petición perezosa para cargar la siguiente página (Lazy Load / Scroll Infinito).
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadMoreRunning || !state.hasMore) return;

    state = state.copyWith(isLoadMoreRunning: true);

    final nextPage = state.currentPage + 1;
    final result = await _getLeaderboardUseCase(
      type: _currentType,
      difficulty: _currentDifficulty,
      page: nextPage,
      limit: 15,
    );

    result.fold(
      (newPlayers) {
        if (newPlayers.isNotEmpty) {
          state = state.copyWith(
            players: [...state.players, ...newPlayers],
            currentPage: nextPage,
            isLoadMoreRunning: false,
            hasMore: newPlayers.length >= 15,
          );
        } else {
          state = state.copyWith(
            isLoadMoreRunning: false,
            hasMore: false,
          );
        }
      },
      (failure) {
        state = state.copyWith(
          isLoadMoreRunning: false,
          hasMore: false,
        );
      },
    );
  }
}

/// Proveedor global expuesto a la interfaz de usuario para observar el estado.
final leaderboardStateProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  final useCase = ref.watch(getLeaderboardUseCaseProvider);
  return LeaderboardNotifier(useCase);
});
