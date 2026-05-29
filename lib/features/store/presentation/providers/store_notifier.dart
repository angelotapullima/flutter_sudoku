import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/usecases/purchase_item_usecase.dart';
import '../../data/datasources/store_remote_data_source.dart';
import '../../data/repositories/store_repository_impl.dart';
import '../../../auth/presentation/providers/auth_notifier.dart'; // Para authLocalDataSourceProvider
import '../../../leaderboards/presentation/providers/leaderboard_notifier.dart'; // Para httpClientProvider
import '../../../../providers/profile_provider.dart'; // Para profileProvider

// =========================================================================
// 1. ESTADO DE LA TIENDA (Store State)
// =========================================================================

/// Estado reactivo para la transacción de compra en la Tienda RPG.
class StoreState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const StoreState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  StoreState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return StoreState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// =========================================================================
// 2. INYECCIÓN DE DEPENDENCIAS (Riverpod Providers)
// =========================================================================

/// Proveedor para el Data Source remoto de la tienda.
final storeRemoteDataSourceProvider = Provider<StoreRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final authLocal = ref.watch(authLocalDataSourceProvider);
  return StoreRemoteDataSourceImpl(
      client: client, authLocalDataSource: authLocal);
});

/// Proveedor para la implementación del repositorio.
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final remoteDataSource = ref.watch(storeRemoteDataSourceProvider);
  return StoreRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Proveedor para el caso de uso de compra de artículo.
final purchaseItemUseCaseProvider = Provider<PurchaseItemUseCase>((ref) {
  final repository = ref.watch(storeRepositoryProvider);
  return PurchaseItemUseCase(repository);
});

/// Proveedor principal que expone el notificador de compras a la interfaz de usuario.
final storeNotifierProvider =
    StateNotifierProvider<StoreNotifier, StoreState>((ref) {
  final purchaseUseCase = ref.watch(purchaseItemUseCaseProvider);
  return StoreNotifier(purchaseItemUseCase: purchaseUseCase, ref: ref);
});

// =========================================================================
// 3. ADMINISTRADOR DE ESTADO (Store Notifier)
// =========================================================================

/// StateNotifier encargado de orquestar el flujo y validación de compras en la Tienda RPG.
class StoreNotifier extends StateNotifier<StoreState> {
  final PurchaseItemUseCase _purchaseItemUseCase;
  final Ref _ref;

  StoreNotifier({
    required PurchaseItemUseCase purchaseItemUseCase,
    required Ref ref,
  })  : _purchaseItemUseCase = purchaseItemUseCase,
        _ref = ref,
        super(const StoreState());

  /// Realiza la compra de un artículo de la tienda y sincroniza el perfil del jugador.
  Future<void> purchaseItem({
    required String itemId,
    required int cost,
    required String type,
    required String name,
  }) async {
    // 1. Limpiar mensajes previos y establecer estado de carga
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);

    // 2. Validar saldo de S-Coins localmente para evitar peticiones inútiles
    final profile = _ref.read(profileProvider);
    if (profile.coins < cost) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No tienes suficientes S-Coins 🪙 para adquirir $name.',
      );
      return;
    }

    // 3. Ejecutar transacción de compra remota
    final result = await _purchaseItemUseCase(
      itemId: itemId,
      cost: cost,
      type: type,
    );

    result.fold(
      (_) async {
        // En caso de éxito, forzar la descarga del perfil fresco desde el servidor
        await _ref.read(profileProvider.notifier).refreshProfileFromServer();

        state = state.copyWith(
          isLoading: false,
          successMessage: '¡Has adquirido: $name! 🚀',
        );
      },
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Limpia los mensajes del estado.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
