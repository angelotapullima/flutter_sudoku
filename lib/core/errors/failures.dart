abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Ocurrió un error en el servidor.'])
      : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [String message = 'Sin conexión a Internet. Verifica tu red.'])
      : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(
      [String message = 'Error al leer o escribir datos locales.'])
      : super(message);
}
