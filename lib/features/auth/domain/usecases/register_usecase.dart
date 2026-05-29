import '../../../../core/utils/result.dart';
import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

/// Caso de Uso de Dominio: Registrar una nueva cuenta sincronizando progreso local opcionalmente.
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Método invocable para ejecutar el caso de uso directamente.
  Future<Result<UserSession>> call({
    required String username,
    required String email,
    required String password,
    Map<String, dynamic>? localProgress,
  }) {
    return repository.register(
      username: username,
      email: email,
      password: password,
      localProgress: localProgress,
    );
  }
}
