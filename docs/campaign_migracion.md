# Reporte de Migración: Módulo de Mapa Estelar (Campaña)

Este documento contiene el desglose técnico y las validaciones de los cambios estructurales aplicados al módulo de **Mapa Estelar (Campaña)** bajo el patrón **Clean Architecture**.

---

## 1. Archivos Creados e Integrados

El módulo de campaña fue organizado bajo la estructura modular por características (`features`), aislando todo el código de campaña en `lib/features/campaign/`:

### Capa de Dominio (Domain)
*   **[campaign_level.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/features/campaign/domain/entities/campaign_level.dart)**
    - *Responsabilidad:* Representar a un nivel estelar de manera pura e inmutable (`levelNumber`, `difficulty`, `puzzleData`, `solutionData`, `bossName`, `rewardCoins`, `rewardXp`, `modifiers`).
*   **[campaign_repository.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/features/campaign/domain/repositories/campaign_repository.dart)**
    - *Responsabilidad:* Definir la interfaz abstracta del repositorio de negocio (`getCampaignLevels`, `completeCampaignLevel`).
*   **[get_campaign_levels_usecase.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/features/campaign/domain/usecases/get_campaign_levels_usecase.dart)**
    - *Responsabilidad:* Encapsular el caso de uso único para descargar la lista de niveles estelares de la campaña.
*   **[complete_campaign_level_usecase.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/features/campaign/domain/usecases/complete_campaign_level_usecase.dart)**
    - *Responsabilidad:* Encapsular el caso de uso único para notificar al servidor sobre un nivel de campaña completado.

### Capa de Datos (Data)
*   **[campaign_level_model.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/features/campaign/data/models/campaign_level_model.dart)**
    - *Responsabilidad:* Extender la entidad y realizar la serialización JSON segura (`fromJson`/`toJson`), protegiendo nulos en los modificadores.
*   **[campaign_remote_data_source.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/features/campaign/data/datasources/campaign_remote_data_source.dart)**
    - *Responsabilidad:* Cliente de red que interactúa directamente con los endpoints del servidor para misiones y obtención de campaña.
*   **[campaign_repository_impl.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/features/campaign/data/repositories/campaign_repository_impl.dart)**
    - *Responsabilidad:* Conectar fuente de datos y mapear excepciones a fallos controlados de negocio (`Failure`).

### Capa de Presentación (Presentation)
*   **[campaign_notifier.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/features/campaign/presentation/providers/campaign_notifier.dart)**
    - *Responsabilidad:* Proveedores Riverpod (`campaignNotifierProvider`) y StateNotifier gestor del Mapa Estelar y la sincronización con `profileProvider`.

---

## 2. Refactorización e Integración de UI y Lógica de Juego

### Mapa Estelar: [star_map_screen.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/screens/star_map_screen.dart)
*   Se eliminó la dependencia con el antiguo `campaignProvider`.
*   Se conectó la vista serpenteante de planetas al nuevo proveedor reactivo:
    ```dart
    final campaign = ref.watch(campaignNotifierProvider);
    ```
*   Se reemplazaron accesos a propiedades dinámicas por las propiedades inmutables y tipadas de la entidad.

### Finalización de Partidas: [game_provider.dart](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/lib/providers/game_provider.dart)
*   Se modificó el flujo para que, al ganar un nivel de campaña, invoque al nuevo `completeLevel` de `campaignNotifierProvider.notifier`.

### Limpieza de Código Muerto
*   Se eliminó por completo el archivo obsoleto `lib/providers/campaign_provider.dart` limpiando el directorio de providers antiguos.

---

## 3. Reporte de Validación Estática

Corrimos un análisis estático exhaustivo del compilador mediante `flutter analyze` obteniendo los siguientes resultados:
*   **Cero Errores de Compilación o de Tipos.**
*   El compilador de Dart 3 certifica la completa seguridad de tipos en todo el árbol de flujo de datos (DataSource -> Repositorio -> Caso de Uso -> StateNotifier -> Widgets de UI).
