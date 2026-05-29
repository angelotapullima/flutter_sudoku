import '../errors/failures.dart';

/// Clase sellada genérica para el manejo tipado y seguro de respuestas en la capa de negocio.
/// Reemplaza el lanzamiento de excepciones directas a la UI y obliga al manejo de errores.
sealed class Result<S> {
  const Result();

  /// Ejecuta [onSuccess] si el resultado es exitoso o [onFailure] si ha fallado.
  T fold<T>(
    T Function(S data) onSuccess,
    T Function(Failure failure) onFailure,
  ) {
    switch (this) {
      case Success<S>():
        return onSuccess((this as Success<S>).value);
      case FailureResult<S>():
        return onFailure((this as FailureResult<S>).failure);
    }
  }
}

class Success<S> extends Result<S> {
  final S value;
  const Success(this.value);
}

class FailureResult<S> extends Result<S> {
  final Failure failure;
  const FailureResult(this.failure);
}
