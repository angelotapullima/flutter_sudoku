# Clases Invocables (`call`) en el lenguaje Dart

En el desarrollo con Flutter y Dart, es muy común encontrar clases en la capa de negocio (como los **Casos de Uso**) que definen un método llamado exactamente `call`.

Esta es una característica especial y nativa del lenguaje Dart conocida como **Callable Classes (Clases Invocables)**, y no tiene relación con el framework de Flutter en sí.

---

## 1. ¿Cómo funciona el método `call`?

Normalmente, para ejecutar la lógica de un objeto que creas en programación orientada a objetos, debes llamar a un método específico usando el punto (ej. `objeto.ejecutar()`).

Sin embargo, en **Dart**, si defines un método dentro de cualquier clase con el nombre exacto de **`call`**, ese objeto se convierte automáticamente en una función. Puedes invocar al objeto directamente colocando paréntesis `()` a su lado, omitiendo la necesidad de escribir el nombre de un método.

---

## 2. Comparativa de Código

### Forma Tradicional (Sin usar `call`)
Definiendo un método con un nombre común como `execute`:

```dart
class GetLeaderboardUseCase {
  final LeaderboardRepository repository;
  
  GetLeaderboardUseCase(this.repository);

  Future<Result> execute({required String type}) {
    return repository.getLeaderboard(type: type);
  }
}

// Para usarlo:
void main() async {
  final useCase = GetLeaderboardUseCase(repo);
  
  // Tienes que escribir explícitamente el nombre del método:
  final result = await useCase.execute(type: 'level');
}
```

### Forma Senior de Dart (Usando `call`)
Definiendo el método como `call`:

```dart
class GetLeaderboardUseCase {
  final LeaderboardRepository repository;
  
  GetLeaderboardUseCase(this.repository);

  // El método se llama exactamente 'call'
  Future<Result> call({required String type}) {
    return repository.getLeaderboard(type: type);
  }
}

// Para usarlo:
void main() async {
  final useCase = GetLeaderboardUseCase(repo);
  
  // ¡Llamas al objeto directamente por su nombre, como si fuera una función!
  final result = await useCase(type: 'level');
}
```

---

## 3. ¿Por qué es un estándar en Clean Architecture?

En la Arquitectura Limpia, un **Caso de Uso (Use Case)** representa **una única acción de negocio** específica (un verbo único como *"Iniciar sesión"*, *"Registrar puntuación"*, *"Obtener la clasificación"*).

Dado que la clase tiene **una única responsabilidad y un único propósito**, no tiene sentido llenarla de múltiples métodos o inventar nombres genéricos y redundantes como `.execute()`, `.run()` o `.perform()`.

Usar el atajo `call` nos aporta tres grandes ventajas técnicas:

1.  **Semántica impecable:** En tu presentador o notifier, la lectura del código fluye de forma muy natural:
    ```dart
    final result = await _getLeaderboardUseCase(type: _currentType, difficulty: _currentDifficulty);
    ```
    Se entiende de inmediato que se está invocando la acción principal del caso de uso.
2.  **Limpieza visual:** Reduce el "ruido" de caracteres innecesarios en tus archivos de presentación, haciendo que el código sea más legible y estético.
3.  **Flexibilidad en Pruebas Unitarias:** Facilita el mockeo de las clases en las pruebas de comportamiento asíncrono, permitiendo tratar el caso de uso como una función mockeable pura.
