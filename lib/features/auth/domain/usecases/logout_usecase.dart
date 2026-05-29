import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Caso de Uso de Dominio: Cerrar la sesión del usuario borrando tokens locales persistidos.
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Método invocable para ejecutar el caso de uso directamente.
  Future<Result<void>> call() {
    return repository.logout();
  }
}
