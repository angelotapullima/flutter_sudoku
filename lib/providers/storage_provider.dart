import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Proveedor global de la interfaz StorageService.
/// Lanzará un error si no es sobreescrito en el arranque en main.dart tras inicializar.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider no ha sido inicializado en el Scope.');
});
