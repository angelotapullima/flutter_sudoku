import 'dart:async';
import 'dart:io';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementación concreta del Repositorio de Autenticación.
/// Encapsula el control de errores técnicos y el flujo de guardado de credenciales locales.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<UserSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userSessionModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Guardamos el token JWT de forma segura si existe
      if (userSessionModel.token != null) {
        await localDataSource.saveToken(userSessionModel.token!);
      }

      return Success(userSessionModel);
    } on SocketException catch (_) {
      return const FailureResult(
          NetworkFailure('Sin conexión a internet. Verifica tu red estelar.'));
    } on TimeoutException catch (_) {
      return const FailureResult(NetworkFailure(
          'Tiempo de espera agotado. El servidor tardó demasiado en responder.'));
    } catch (e) {
      return FailureResult(
          ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Result<UserSession>> register({
    required String username,
    required String email,
    required String password,
    Map<String, dynamic>? localProgress,
  }) async {
    try {
      final userSessionModel = await remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        localProgress: localProgress,
      );

      // Guardamos el token JWT de forma segura si existe
      if (userSessionModel.token != null) {
        await localDataSource.saveToken(userSessionModel.token!);
      }

      return Success(userSessionModel);
    } on SocketException catch (_) {
      return const FailureResult(NetworkFailure('Sin conexión a internet.'));
    } on TimeoutException catch (_) {
      return const FailureResult(NetworkFailure('Tiempo de espera agotado.'));
    } catch (e) {
      return FailureResult(
          ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.clearToken();
      return const Success(null);
    } catch (e) {
      return FailureResult(
          CacheFailure('Fallo al borrar credenciales locales: $e'));
    }
  }

  @override
  Future<Result<UserSession>> getCurrentSession() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) {
        return Success(UserSession.guest());
      }

      // Si hay un token, validamos la sesión contra el servidor stelar
      final userSessionModel = await remoteDataSource.getCurrentProfile(token);
      return Success(userSessionModel);
    } on SocketException catch (_) {
      // Si no hay red, devolvemos sesión de invitado o permitimos cargar modo local
      return const FailureResult(
          NetworkFailure('Sin red para validar sesión activa.'));
    } catch (e) {
      // Si el token expiró o falló, borramos el token y devolvemos sesión de invitado
      await localDataSource.clearToken();
      return Success(UserSession.guest());
    }
  }
}
