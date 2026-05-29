import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/profile_provider.dart';
import '../../domain/entities/campaign_level.dart';
import '../../domain/usecases/complete_campaign_level_usecase.dart';
import '../../domain/usecases/get_campaign_levels_usecase.dart';
import '../../domain/repositories/campaign_repository.dart';
import '../../data/repositories/campaign_repository_impl.dart';
import '../../data/datasources/campaign_remote_data_source.dart';

// --- Providers de Infraestructura ---

/// Proveedor para la fuente de datos remota.
final campaignRemoteDataSourceProvider =
    Provider<CampaignRemoteDataSource>((ref) {
  return CampaignRemoteDataSourceImpl();
});

/// Proveedor para la implementación del repositorio.
final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final remoteDataSource = ref.watch(campaignRemoteDataSourceProvider);
  return CampaignRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Providers de Casos de Uso ---

/// Proveedor para el caso de uso de obtención de niveles.
final getCampaignLevelsUseCaseProvider =
    Provider<GetCampaignLevelsUseCase>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return GetCampaignLevelsUseCase(repository);
});

/// Proveedor para el caso de uso de completitud de nivel.
final completeCampaignLevelUseCaseProvider =
    Provider<CompleteCampaignLevelUseCase>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return CompleteCampaignLevelUseCase(repository);
});

// --- State & Notifier ---

/// Estado reactivo para la característica de Campaña.
class CampaignState {
  final List<CampaignLevel> levels;
  final bool isLoading;
  final String? error;

  const CampaignState({
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

/// Notificador que gestiona el estado y la lógica de la Campaña.
class CampaignNotifier extends StateNotifier<CampaignState> {
  final GetCampaignLevelsUseCase _getLevelsUseCase;
  final CompleteCampaignLevelUseCase _completeLevelUseCase;
  final Ref _ref;

  CampaignNotifier({
    required GetCampaignLevelsUseCase getLevelsUseCase,
    required CompleteCampaignLevelUseCase completeLevelUseCase,
    required Ref ref,
  })  : _getLevelsUseCase = getLevelsUseCase,
        _completeLevelUseCase = completeLevelUseCase,
        _ref = ref,
        super(const CampaignState()) {
    fetchLevels();
  }

  /// Carga los niveles de campaña desde el servidor.
  Future<void> fetchLevels() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getLevelsUseCase();

    result.fold(
      (levels) => state = state.copyWith(levels: levels, isLoading: false),
      (failure) =>
          state = state.copyWith(error: failure.message, isLoading: false),
    );
  }

  /// Marca un nivel como completado, sincronizando localmente y con el servidor.
  Future<bool> completeLevel(int levelNumber) async {
    final profileNotifier = _ref.read(profileProvider.notifier);
    final profile = _ref.read(profileProvider);

    // 1. Actualización local inmediata del progreso si es el nivel actual
    if (levelNumber >= profile.campaignLevel) {
      profileNotifier.updateCampaignLevel(levelNumber + 1);
    }

    // 2. Reporte al servidor si el usuario está registrado
    if (profile.isRegistered) {
      final result = await _completeLevelUseCase(levelNumber);

      return result.fold(
        (_) async {
          // Sincronizar perfil para asegurar que monedas y XP de recompensa se reflejen
          await profileNotifier.syncWithServer();
          return true;
        },
        (failure) {
          // Si falla la red, el progreso local ya se guardó, se sincronizará luego
          return false;
        },
      );
    }

    return true;
  }
}

/// Proveedor principal para exponer el estado de la Campaña a la UI.
final campaignNotifierProvider =
    StateNotifierProvider<CampaignNotifier, CampaignState>((ref) {
  final getLevels = ref.watch(getCampaignLevelsUseCaseProvider);
  final completeLevel = ref.watch(completeCampaignLevelUseCaseProvider);

  return CampaignNotifier(
    getLevelsUseCase: getLevels,
    completeLevelUseCase: completeLevel,
    ref: ref,
  );
});
