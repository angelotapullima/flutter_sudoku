
# Documento Funcional — App de Sudoku Gamificada

# 1. Visión General

La aplicación será un juego de Sudoku moderno, simple y altamente adictivo, enfocado en:

- Experiencia rápida y limpia.
- Progresión por niveles.
- Sistema de gamificación.
- Retención de usuarios.
- Competencia y recompensas.
- Diseño minimalista.
- Fácil expansión futura.

---

# 2. Objetivos del Producto

## Objetivo Principal

Crear una aplicación de Sudoku intuitiva y gamificada donde el usuario:

- Resuelva sudokus por dificultad.
- Obtenga puntajes.
- Desbloquee rangos.
- Consiga recompensas.
- Administre recursos limitados (pistas).
- Mantenga rachas diarias.
- Compita consigo mismo.

---

# 3. Público Objetivo

## Perfil Principal

- Usuarios casuales.
- Personas que quieren ejercitar lógica.
- Usuarios móviles.
- Personas que juegan 5–20 minutos diarios.

## Edad objetivo

- 13 a 45 años.

---

# 4. Filosofía del Juego

## Debe sentirse:

- Simple.
- Fluido.
- Relajante.
- Inteligente.
- Adictivo.
- Elegante.

## Debe evitar:

- Pantallas saturadas.
- Animaciones excesivas.
- Publicidad invasiva.
- Configuración complicada.

---

# 5. Flujo Principal

## Pantalla Inicial

Opciones:

- Continuar partida.
- Nueva partida.
- Torneo.
- Estadísticas.
- Tienda.
- Configuración.

---

# 6. Dificultades

| Nivel | Nombre | Complejidad |
|---|---|---|
| 1 | Principiante | Muy fácil |
| 2 | Fácil | Fácil |
| 3 | Medio | Normal |
| 4 | Difícil | Complejo |
| 5 | Experto | Muy complejo |
| 6 | Maestro | Extremo |

---

# 7. Sistema de Rangos

## Objetivo

Dar sensación de progreso constante.

| Nivel | Nombre |
|---|---|
| 1 | Novato |
| 2 | Aprendiz |
| 3 | Estratega |
| 4 | Maestro Sudoku |
| 5 | Gran Maestro |
| 6 | Leyenda |

---

# 8. Gamificación

## Elementos principales

### Puntos

Se obtienen por:

- Completar partidas.
- Velocidad.
- No cometer errores.
- No usar pistas.
- Mantener rachas.

---

### Rachas Diarias

Si el usuario juega diariamente:

- Día 1 → recompensa pequeña.
- Día 7 → recompensa grande.
- Día 30 → premio especial.

---

### Monedas

Moneda virtual interna para:

- Comprar pistas.
- Temas.
- Avatares.
- Efectos visuales.

---

### Logros

Ejemplos:

| Logro | Requisito |
|---|---|
| Velocista | Terminar rápido |
| Perfecto | Sin errores |
| Cerebro Supremo | Completar expertos seguidos |
| Imparable | Racha larga |

---

# 9. Pantalla Principal del Juego

## Parte Superior

Debe mostrar:

- Racha actual.
- Tiempo.
- Puntaje.
- Errores.
- Pausa.

Ejemplo:

- Racha 13
- Puntaje: 1500
- Errores: 1/3
- Tiempo: 04:23

---

# 10. Tablero Sudoku

## Características

- Tablero 9x9.
- Líneas gruesas cada 3x3.
- Diseño limpio.
- Animaciones suaves.
- Colores minimalistas.

---

## Comportamientos

### Selección de celda

Cuando el usuario selecciona una celda:

- Se resalta fila.
- Se resalta columna.
- Se resalta subcuadro.

---

### Selección de número

Si selecciona un número:

- Todas las celdas con ese número se iluminan.

---

### Errores

Si pone un número incorrecto:

- La celda se pinta roja.
- Incrementa contador de errores.

Si llega a 3 errores:

- Pierde la partida.

---

# 11. Botones Principales

Debajo del tablero.

| Botón | Acción |
|---|---|
| Deshacer | Revierte movimiento |
| Borrar | Limpia celda |
| Reiniciar | Reinicia partida |
| Pista | Revela respuesta |

---

# 12. Sistema de Pistas

## Reglas

- Usuario inicia con 3 pistas.
- Las pistas son limitadas.
- Se ganan por:
  - Rachas.
  - Logros.
  - Completar niveles.
  - Recompensas.

---

## Uso de pista

Cuando usa una pista:

- Se revela el número correcto.
- Reduce bonus final.
- Reduce puntaje perfecto.

---

# 13. Panel de Números

Debajo de los botones.

## Números del 1 al 9

Cada número debe mostrar:

- Número.
- Cantidad restante.

Ejemplo:

- 1 (5)
- 2 (3)
- 3 (0)

---

## Regla importante

Si un número ya fue usado completamente:

- Debe desaparecer.
o
- Deshabilitarse.

Esto genera sensación de progreso visual.

---

# 14. Sistema de Puntaje

## Basado en:

- Tiempo.
- Errores.
- Dificultad.
- Uso de pistas.

---

## Bonus

- Completar rápido.
- Sin errores.
- Sin pistas.
- Rachas altas.

---

# 15. Sistema de Tiempo

## Timer

Debe:

- Iniciar automáticamente.
- Pausar correctamente.
- Guardarse automáticamente.

---

# 16. Configuración

Opciones sugeridas:

| Configuración | Descripción |
|---|---|
| Contador | Mostrar tiempo |
| Límite de errores | Activar modo 3 errores |
| Zona resaltada | Resaltar fila/columna |
| Resaltar mismos números | Highlight de iguales |
| Borrado automático | Eliminar notas |
| Autocompletado | Completar últimas celdas |
| Puntaje | Mostrar score |
| Animaciones | Activar efectos |
| Número restante | Mostrar contador |
| Sonidos | Activar audio |
| Vibración | Feedback táctil |
| Tema oscuro | Dark mode |

---

# 17. Sistema de Notas

## Modo lápiz

El usuario puede escribir pequeños números candidatos dentro de una celda.

Características:

- Múltiples candidatos.
- Auto eliminación opcional.
- Diferente color.

---

# 18. Guardado Automático

La aplicación debe guardar automáticamente:

- Estado del tablero.
- Tiempo.
- Errores.
- Pistas restantes.
- Puntaje.

---

# 19. Estadísticas

## Métricas

| Métrica | Descripción |
|---|---|
| Juegos completados | Total |
| Tiempo promedio | Por dificultad |
| Mejor tiempo | Récord |
| Precisión | % |
| Errores promedio | Estadística |
| Racha máxima | Histórico |

---

# 20. Torneos

## Futuro

Competencias semanales.

Características:

- Ranking global.
- Premios.
- Monedas.
- Títulos especiales.

---

# 21. Tienda

## Ítems

- Temas.
- Colores.
- Avatares.
- Efectos.
- Packs de pistas.

---

# 22. Monetización

## Opciones

### Anuncios

- Recompensas por ver anuncios.
- Obtener pistas.
- Monedas extra.

---

## Premium

Beneficios:

- Sin anuncios.
- Temas exclusivos.
- Más estadísticas.
- Más pistas.

---

# 23. Experiencia Visual

## Estilo

Minimalista moderno.

Colores:

- Blanco.
- Azul suave.
- Gris claro.
- Negro suave.

---

# 24. Animaciones

## Deben ser suaves

Ejemplos:

- Pop al colocar número.
- Glow al ganar.
- Shake al error.

---

# 25. Sonidos

Opcionales:

- Click suave.
- Error.
- Victoria.
- Uso de pista.

---

# 26. Roadmap

## MVP

Debe incluir:

- Sudoku funcional.
- Dificultades.
- Timer.
- Errores.
- Pistas.
- Puntaje.
- Guardado automático.

---

## Segunda fase

- Rangos.
- Logros.
- Monedas.
- Estadísticas.
- Temas.

---

## Tercera fase

- Torneos.
- Ranking global.
- Eventos.
- Competencias.

---

# 27. Futuras Expansiones

## IA de ayuda

El sistema analiza:

- Errores frecuentes.
- Tiempo promedio.
- Dónde se atasca el jugador.

Y da recomendaciones.

---

## Modo historia

Mapa progresivo con mundos.

Ejemplos:

- Ciudad.
- Bosque.
- Espacio.
- Laboratorio.

---

## Eventos diarios

- Puzzle diario.
- Recompensas.
- Multiplicadores.

---

## Clanes

Usuarios pueden:

- Formar equipos.
- Competir.
- Compartir récords.

---

# 28. Objetivos del Producto

La aplicación debe transmitir:

- Sensación premium.
- Progreso constante.
- Competencia sana.
- Retención diaria.
- Juego relajante pero desafiante.

---

# 29. KPIs del Producto

| KPI | Objetivo |
|---|---|
| Retención día 1 | Alta |
| Retención día 7 | Alta |
| Tiempo promedio por sesión | 10+ min |
| Partidas por día | 3+ |

---

# 30. Conclusión

La app debe sentirse:

- Premium.
- Fluida.
- Minimalista.
- Inteligente.
- Adictiva.

El enfoque principal debe estar en:

1. UX limpia.
2. Gamificación inteligente.
3. Sensación de progreso.
4. Retención.
5. Escalabilidad futura.
