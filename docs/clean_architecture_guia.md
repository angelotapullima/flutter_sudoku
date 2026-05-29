# Guía de Clean Architecture & Riverpod en Sudoku Arena

Esta guía explica de manera didáctica y paso a paso cómo funciona la arquitectura limpia implementada en el proyecto, diseñada bajo estándares de desarrollo de nivel **Senior**.

---

## 1. ¿Qué es Clean Architecture?

El objetivo principal de **Clean Architecture** (Arquitectura Limpia) es separar el código en capas lógicas con responsabilidades muy bien definidas. La regla fundamental es: **Las capas internas no conocen nada sobre las capas externas.**

Para entenderlo de forma muy sencilla, imagina que tu aplicación es un **restaurante de lujo**:

*   🍳 **El Chef (Domain / Dominio - Núcleo Puro):** Prepara la receta perfecta. Él no sabe de dónde vinieron los ingredientes (si de un supermercado de lujo o de una granja local) ni le importa qué mesa la ordenó. Él solo sabe cocinar. Es el corazón y las reglas de negocio de la app.
*   📦 **El Proveedor de Ingredientes (Data / Datos - Infraestructura):** Se encarga de ir a buscar la verdura y la carne. Si el mercado cierra, él busca otro mercado, pero al Chef siempre le entrega los mismos ingredientes limpios. Sabe cómo conseguir y almacenar los datos reales (APIs, bases de datos).
*   🍽️ **El Camarero y la Mesa (Presentation / Presentación - Interfaz):** Es lo que ve el cliente. Toma el pedido y muestra el plato final de forma elegante. Sabe cómo interactuar con el usuario y mostrar la información en pantalla (UI, pantallas de Flutter).

```
   ┌─────────────────────────────────────────────────────────┐
   │                  Presentation Layer (UI)                │
   │               (Flutter Screens, Widgets)                │
   └────────────────────────────┬────────────────────────────┘
                                │ Lee Estado / Envía Acción
                                ▼
   ┌─────────────────────────────────────────────────────────┐
   │               Presentation Layer (Riverpod)             │
   │               (StateNotifiers, Providers)               │
   └────────────────────────────┬────────────────────────────┘
                                │ Invoca
                                ▼
   ┌─────────────────────────────────────────────────────────┐
   │                      Domain Layer                       │
   │            (UseCases, Entities, Contracts)              │
   └────────────────────────────▲────────────────────────────┘
                                │ Implementa
                                │ Contratos
   ┌────────────────────────────┴────────────────────────────┐
   │                       Data Layer                        │
   │             (Models, DataSources, RepoImpls)            │
   └─────────────────────────────────────────────────────────┘
```

Esta separación garantiza que el **corazón de la aplicación (Domain)** sea 100% puro Dart, libre de librerías externas o de acoplamiento a redes o bases de datos específicas.

---

## 2. El Núcleo de Control de Flujo (`lib/core/`)

Para asegurar la robustez del sistema, definimos dos componentes fundamentales en el núcleo:

### A. Fallos de Negocio (`lib/core/errors/failures.dart`)
En lugar de lanzar excepciones genéricas descontroladas (`throw Exception`), modelamos los errores de negocio como clases tipadas:
*   `ServerFailure`: El servidor backend retornó un código de error o un JSON corrupto.
*   `NetworkFailure`: No hay conexión a internet o el servidor no responde (Timeout).

### B. El Patrón Result (`lib/core/utils/result.dart`)
Aprovechando las clases selladas (`sealed classes`) de Dart 3, creamos una estructura funcional `Result<S, F>` que representa el resultado de una operación asíncrona:
*   `Success(S data)`: Indica éxito y encapsula el resultado esperado.
*   `Failure(F error)`: Indica fallo y encapsula la clase de error.

**Por qué es Senior:** Obliga al programador a usar el método `.fold(onSuccess, onFailure)`. El compilador de Dart te impedirá compilar la app si olvidas manejar los casos de error, reduciendo a cero los cuelgues inesperados en producción.

---

## 3. Desglose del Flujo de una Pantalla (Piloto: Leaderboards)

Tomando el módulo de **Clasificaciones** como ejemplo, así se comportan las capas desde que la pantalla se dibuja hasta que el backend responde:

### Capa 1: Dominio (La Receta / El Negocio)
*   **Entidad (`leaderboard_player.dart`):** Clase de datos inmutable pura en Dart que define al jugador del ranking (`userId`, `username`, `level`, `bestTime`, `xp`).
*   **Contrato del Repositorio (`leaderboard_repository.dart`):** Interfaz abstracta que define las funciones de negocio necesarias sin implementar cómo se consiguen los datos.
*   **Caso de Uso (`get_leaderboard_usecase.dart`):** Clase ejecutable que coordina la petición de clasificaciones al repositorio. Es la representación directa de la acción del usuario en el código.

### Capa 2: Datos (La Cosecha / La Infraestructura)
*   **Modelo (`leaderboard_player_model.dart`):** Extiende la entidad del dominio añadiendo los métodos de serialización `fromJson`/`toJson` para interactuar de forma segura con el JSON del backend.
*   **Fuente de Datos (`leaderboard_remote_data_source.dart`):** Cliente de bajo nivel encargado de realizar el `http.get` directo a la API, inyectando el token JWT guardado en local.
*   **Implementación del Repositorio (`leaderboard_repository_impl.dart`):** Implementa el contrato del dominio. Llama a la fuente de datos, atrapa excepciones del protocolo de red (`SocketException`, `TimeoutException`) y las devuelve mapeadas como clases `Failure`.

### Capa 3: Presentación (Lo que ve el Usuario)
*   **Notificador de Estado (`leaderboard_notifier.dart`):**
    - Define un estado inmutable (`LeaderboardState`) con todo el control lógico de la pantalla (`isLoading`, `players`, `errorMessage`, `currentPage`, `hasMore`, `isLoadMoreRunning`).
    - Ofrece métodos orientados a la acción como `fetchLeaderboard` y `loadMore` (scroll infinito).
*   **Los Proveedores (Riverpod Providers):** Instancian de manera automática todas las dependencias mediante inyección, permitiendo desacoplamiento absoluto y facilitando pruebas automatizadas.
*   **La Pantalla (`stats_screen.dart`):** 
    - Observa el proveedor reactivo `ref.watch(leaderboardStateProvider)`.
    - Dibuja un `CircularProgressIndicator` si `isLoading` es verdadero.
    - Muestra un botón de reintentar si hay un `errorMessage`.
    - Renderiza la lista de forma robusta e inmutable leyendo `players` de forma fuertemente tipada (`player.username`, `player.bestTime`), erradicando los antiguos marcadores dinámicos tipo mapa (`player['username']`).
