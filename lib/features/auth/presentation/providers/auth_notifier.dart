import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../leaderboards/presentation/providers/leaderboard_notifier.dart'; // Para httpClientProvider

// =========================================================================
// 1. ESTADO DE AUTENTICACIÓN (Auth State)
// =========================================================================

class AuthState {
  final UserSession session;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.session,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserSession? session,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Permite nulos para limpiar errores
    );
  }
}

// =========================================================================
// 2. INYECCIÓN DE DEPENDENCIAS (Riverpod Providers)
// =========================================================================

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return AuthRemoteDataSourceImpl(client: client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final local = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repo);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repo);
});

// =========================================================================
// 3. ADMINISTRADOR DE ESTADO (StateNotifier)
// =========================================================================

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _authRepository = authRepository,
        super(AuthState(session: UserSession.guest())) {
    _checkActiveSession();
  }

  /// Comprueba al iniciar si existe un token local y valida la sesión.
  Future<void> _checkActiveSession() async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.getCurrentSession();
    result.fold(
      (userSession) {
        state = state.copyWith(session: userSession, isLoading: false);
      },
      (failure) {
        state = state.copyWith(session: UserSession.guest(), isLoading: false);
      },
    );
  }

  /// Ejecuta el inicio de sesión.
  Future<Result<UserSession>> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _loginUseCase(email: email, password: password);

    return result.fold(
      (userSession) {
        state = state.copyWith(session: userSession, isLoading: false);
        return Success(userSession);
      },
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return FailureResult(failure);
      },
    );
  }

  /// Ejecuta el registro de cuenta.
  Future<Result<UserSession>> register({
    required String username,
    required String email,
    required String password,
    Map<String, dynamic>? localProgress,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _registerUseCase(
      username: username,
      email: email,
      password: password,
      localProgress: localProgress,
    );

    return result.fold(
      (userSession) {
        state = state.copyWith(session: userSession, isLoading: false);
        return Success(userSession);
      },
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return FailureResult(failure);
      },
    );
  }

  /// Ejecuta el cierre de sesión.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final result = await _logoutUseCase();
    result.fold(
      (_) {
        state = AuthState(session: UserSession.guest());
      },
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }
}

/// Proveedor global reactivo para interactuar con la sesión en la UI.
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final login = ref.watch(loginUseCaseProvider);
  final register = ref.watch(registerUseCaseProvider);
  final logout = ref.watch(logoutUseCaseProvider);
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(
    loginUseCase: login,
    registerUseCase: register,
    logoutUseCase: logout,
    authRepository: repo,
  );
});
