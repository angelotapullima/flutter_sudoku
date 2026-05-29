import '../../../../core/utils/result.dart';
import '../entities/user_session.dart';

/// Contrato del Repositorio de Autenticación definido en la capa de Dominio.
/// Quien implemente esta interfaz en la capa de Datos debe cumplir con estas funciones de negocio.
abstract class AuthRepository {
  /// Inicia sesión con correo y contraseña.
  Future<Result<UserSession>> login({
    required String email,
    required String password,
  });

  /// Registra una nueva cuenta de usuario, opcionalmente sincronizando el progreso local del invitado.
  Future<Result<UserSession>> register({
    required String username,
    required String email,
    required String password,
    Map<String, dynamic>? localProgress,
  });

  /// Cierra la sesión activa borrando credenciales locales.
  Future<Result<void>> logout();

  /// Recupera la sesión persistida localmente (ej: token JWT guardado).
  Future<Result<UserSession>> getCurrentSession();
}
