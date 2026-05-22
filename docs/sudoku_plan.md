# Plan de Implementación: Aplicación de Sudoku Premium en Flutter (Con Riverpod y Gamificación)

Este documento detalla la arquitectura, las reglas de negocio y el sistema de gamificación para construir una aplicación de Sudoku altamente interactiva, elegante, responsiva y escalable en Flutter, utilizando Riverpod para la gestión del estado global.

---

## 💼 El Negocio del Sudoku (Core Logic)
El éxito comercial y técnico de la aplicación descansa sobre un motor de juego impecable y lógico:
1. **Generación con Solución Única Garantizada**: Un Sudoku de calidad profesional no debe permitir múltiples caminos correctos ambiguos. Implementaremos un motor en Dart (`sudoku_generator.dart`) que:
   - Cree una cuadrícula resuelta válida mediante un algoritmo de Backtracking.
   - Remueva celdas selectivamente según la dificultad.
   - Resuelva el tablero resultante para certificar que posee exactamente **una única solución**. En caso de ambigüedad (múltiples soluciones), el tablero es descartado y se genera uno nuevo de forma instantánea.
2. **Ciclo de vida e Historial**:
   - **Historial de Deshacer/Rehacer (Undo/Redo Stack)**: Una estructura de datos inmutable que guarda los pasos de la partida para permitir al usuario retroceder celdas ingresadas, notas erróneas o borrados en caliente.
   - **Validación Dinámica**: Sistema de detección de conflictos visuales en fila, columna o subcuadrícula de 3x3 cuando un número es ingresado, permitiendo al usuario aprender de sus errores o desactivar las ayudas para un reto mayor.

---

## 🏆 Gamificación y Sistema de Recompensas (Rewards)
Para garantizar la retención a largo plazo y la fidelización del usuario, estructuraremos un ecosistema de recompensas lúdicas:

1. **Monedas del Juego (S-Coins - Sudoku Coins)**:
   - Recompensa base por completar partidas:
     - **Fácil**: +10 S-Coins.
     - **Medio**: +25 S-Coins.
     - **Difícil**: +50 S-Coins.
     - **Experto**: +100 S-Coins.
   - **Bono de Perfección**: Completar la partida sin un solo error otorga +15 S-Coins adicionales.
   - **Uso de Monedas**:
     - *Comprar Pistas (Hints)* adicionales.
     - *Segunda Oportunidad*: Si el usuario comete 3 errores (derrota), puede gastar 50 S-Coins para revivir y continuar la partida actual.
     - *Comprar Temas Premium*: Desbloquear paletas de colores exclusivas (matices de acento) creadas con alta estética en la tienda integrada.
2. **Experiencia (XP) y Niveles**:
   - Resolver celdas y partidas otorga XP. El jugador sube de nivel acumulando experiencia (ej. *Nivel 1: Novato del Sudoku* -> *Nivel 20: Leyenda del Sudoku*).
3. **Logros Desbloqueables (Achievements)**:
   - **"Velocista"**: Resolver un Sudoku en menos de 4 minutos (+30 S-Coins).
   - **"Mente de Acero"**: Resolver un Sudoku en nivel difícil sin cometer errores (+50 S-Coins).
   - **"Resiliencia"**: Completar un Sudoku tras haber cometido 2 errores (+20 S-Coins).
   - **"Constancia Diaria"**: Jugar 3 días seguidos (+40 S-Coins).
4. **Sudoku del Día (Rachas Diarias)**:
   - Un tablero único diario. Completarlo mantiene la racha de días consecutivos activa y otorga recompensas premium multiplicadas.

---

## 🏗️ Arquitectura de Software con Riverpod
Para garantizar la escalabilidad, la testabilidad y el desacoplamiento de la interfaz con la lógica de negocio, utilizaremos **Riverpod**:

```text
lib/
├── main.dart                      # Configuración de Riverpod y arranque de la app
├── models/
│   ├── sudoku_cell.dart           # Modelo de celda individual (valor, notas, original, etc.)
│   ├── sudoku_board.dart          # Modelo del estado del tablero y su progreso
│   ├── user_profile.dart          # Perfil, nivel, XP, monedas y logros del jugador
│   └── game_theme.dart            # Definición de temas visuales y matices de color
├── utils/
│   └── sudoku_generator.dart      # Generador y solucionador de backtracking en Dart
├── services/
│   ├── storage_service.dart       # Contrato abstracto de almacenamiento (API-Ready)
│   └── local_storage_service.dart # Implementación concreta con SharedPreferences
├── providers/
│   ├── storage_provider.dart      # Proporciona la instancia de persistencia activa
│   ├── theme_provider.dart        # StateNotifier para temas y matices de colores comprados
│   ├── game_provider.dart         # StateNotifier del estado de la partida y temporizador
│   └── profile_provider.dart      # StateNotifier para XP, monedas, logros y sincronización
├── screens/
│   ├── home_screen.dart           # Dashboard, nivel, monedas y dificultades
│   ├── game_screen.dart           # El juego interactivo con controles y modales gamificados
│   ├── stats_screen.dart          # Panel de estadísticas e historial
│   └── store_screen.dart          # Tienda del juego para comprar temas estéticos con S-Coins
└── widgets/
    ├── sudoku_grid.dart           # Tablero responsivo 9x9 con micro-animaciones
    ├── sudoku_cell_widget.dart    # Casillas del tablero con soporte de notas y efectos
    ├── number_pad.dart            # Teclado numérico adaptable
    └── reward_unlock_modal.dart   # Modal animado que festeja nuevos niveles o logros ganados
```

---

## 📝 Plan de Desarrollo

### Paso 1: Configuración y Librerías
* Modificar `pubspec.yaml` para añadir:
  * `flutter_riverpod` para el estado limpio y desacoplado.
  * `shared_preferences` para guardar localmente las monedas, temas comprados, configuración y estadísticas.
  * `google_fonts` para tipografía moderna de alta fidelidad.

### Paso 2: El Generador y Solucionador (Negocio Core)
* Implementar en `sudoku_generator.dart` la lógica pura en Dart para crear y verificar tableros válidos con solución única.

### Paso 3: Capa de Persistencia Desacoplada y Estado de Recompensas
* Implementar `storage_service.dart` y `local_storage_service.dart`.
* Crear `profile_provider.dart` y `user_profile.dart` para gestionar el estado de XP, S-Coins y Logros del usuario, persistiendo cada cambio de forma inmediata y transparente.

### Paso 4: Gestor de Estado del Juego con Riverpod
* Desarrollar `game_provider.dart` para gestionar la partida activa, interactuar con el generador, controlar el temporizador y el historial de jugadas.

### Paso 5: Componentes Estéticos y Pantallas Gamificadas
* Desarrollar el tablero, teclado numérico y selector de tema dinámico.
* Implementar la tienda (`store_screen.dart`) donde el usuario pueda previsualizar y comprar los matices de colores premium.
* Crear las notificaciones visuales emergentes de subidas de nivel y logros desbloqueados con animaciones y confeti.
