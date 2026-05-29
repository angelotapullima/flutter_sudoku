# 🌌 Sudoku Arena: Chronicles of Logic — Documento Funcional

# 1. Visión General
Sudoku Arena no es solo una aplicación de Sudoku; es una **Aventura RPG de Lógica** diseñada para 2026. Combina la pureza del Sudoku clásico con mecánicas de progresión profunda, habilidades tácticas y una capa social competitiva asíncrona.

- **Identidad:** Neo-Cyber / Dark Zen.
- **Núcleo:** Sudoku generado por Backtracking en tiempo real.
- **Diferenciación:** Mapa estelar, habilidades roguelike y guerra de logias.
- **Estética:** Fondos OLED, neones vibrantes (Cian/Púrpura) y feedback ASMR.

---

# 2. Objetivos del Producto
- **Conquista Galáctica:** Progresar a través de un mapa de 100 niveles únicos.
- **Estrategia Táctica:** Gestionar un inventario de poderes para superar retos extremos.
- **Comunidad Activa:** Colaborar en Logias para derrotar al "Titán del Grid".
- **Retención Emocional:** Sistema de rangos y títulos de prestigio.
- **Economía Viva:** Un mercado de suministros que va más allá de simples temas visuales.

---

# 3. Identidad de Marca y Visual (Branding)
- **Nombre:** Sudoku Arena
- **Paleta de Colores:** 
  - Fondo: `#0B0B12` (Espacio Profundo / Dark Zen).
  - Acento Primario: `#00E5FF` (Cian Eléctrico).
  - Acento Secundario: `#B000FF` (Púrpura Neón).
  - Éxito/Oro: `#FFD700`.
- **Tipografía:** *Outfit* (Moderna y geométrica) y *Share Tech Mono* (Para cronómetros y datos técnicos).
- **Logo:** Un núcleo de energía neón rodeado por una cuadrícula lógica de alto impacto.

---

# 4. Modos de Juego

## A. El Viaje (Modo Campaña)
- **Mapa Estelar:** Scroll vertical infinito con planetas (nodos).
- **Niveles:** 100 niveles con dificultad progresiva.
- **Boss Battles:** Cada 10 niveles aparece un **Guardián del Sector**.
  - Condiciones especiales: Niebla, tiempo límite estricto o prohibición de ciertas habilidades.

## B. Inicio (Modo Clásico)
- Selector rápido de dificultad: Fácil, Medio, Difícil, Experto.
- Generación instantánea de tableros únicos.

## C. Reto Diario
- Un tablero único por día para toda la comunidad.
- Sistema de rachas (Streaks) con recompensas exponenciales.

---

# 5. Sistema de Habilidades (Roguelike)
Debajo del tablero, el jugador dispone de una **Barra de Habilidades** que consumen "Cargas" del inventario.

| Habilidad | Efecto | Costo Sugerido |
|---|---|---|
| **Visión Verdadera** | Resalta errores en rojo por 15s sin penalización de vida. | 1 Carga |
| **Reloj Estelar** | Congela el cronómetro por 45 segundos. | 1 Carga |
| **Toque Divino** | Limpia todos los errores y revela 3 casillas correctas al azar. | 1 Carga |

- **Feedback:** Efecto visual de flash (Divine Flash) en toda la pantalla al activar un poder.

---

# 6. La Capa Social: Logias (Clanes)
- **Fundación:** Los usuarios pueden crear o unirse a Logias (máx. 20 miembros).
- **Sala de Logia:** Chat en tiempo real mediante WebSockets (mensajes propios a la derecha, otros a la izquierda).
- **Guerra de Monstruos:** El "Titán Semanal" tiene 100,000 HP.
  - Cada Sudoku ganado por un miembro aporta Daño (DMG).
  - **MVP Semanal:** Se resalta al miembro con más daño con una corona dorada 👑.
- **Botín de Guerra:** Si el Titán cae, todos los miembros reciben S-Coins y Gemas Neón.

---

# 7. Sistema de Rangos y XP
Basado en la experiencia acumulada (XP).

| Nivel | Título | Icono |
|---|---|---|
| 1–5 | Iniciado | 🌱 |
| 6–15 | Aprendiz | ⚙️ |
| 16–30 | Analista | 🔬 |
| 31–50 | Arquitecto | 📐 |
| 51–99 | Gran Maestro | 👑 |
| 100+ | Oráculo | 👁️ |

- **XP Boost:** Item "Pergamino de Sabiduría" que otorga 2x XP por 24 horas.

---

# 8. Centro de Suministros (Tienda RPG)
Dividido en tres categorías:
1. **Consumibles:** Packs de cargas para Visión, Reloj y Toque Divino.
2. **Identidad:** Marcos de avatar animados y Títulos de Prestigio.
3. **Estética:** Temas dinámicos (Cyberpunk, Zen, Dorado Lujo).

---

# 9. Funcionalidades de Retención (Growth)
- **Sincronización en la Nube:** Progreso persistente entre dispositivos.
- **Compartir Victoria:** Generación de una imagen (tarjeta de victoria) estilizada para WhatsApp/Instagram con estadísticas y logo.
- **Notificaciones:** Aviso de misiones nuevas y estado del Titán de la Logia.

---

# 10. Especificaciones Técnicas (Stack)
- **Frontend:** Flutter (Dart).
- **Backend:** Node.js + Express + Socket.io.
- **Base de Datos:** PostgreSQL.
- **Infraestructura:** Soporte para Proxy (Nginx/Cloudflare) con Rate Limit por capas.

---

# 11. Conclusión para Diseño
El diseño debe alejarse de lo "amigable y redondeado" para ir hacia lo **"tecnológico, misterioso y premium"**. Cada interacción debe sentirse como si el usuario estuviera operando una interfaz de inteligencia superior.
