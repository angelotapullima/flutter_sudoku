import '../../../../core/utils/result.dart';
import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

/// Caso de Uso de Dominio: Iniciar sesión de forma segura contra el servidor.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Método invocable para ejecutar el caso de uso directamente.
  Future<Result<UserSession>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
