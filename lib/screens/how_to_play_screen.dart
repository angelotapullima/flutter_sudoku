import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../widgets/responsive_content_wrapper.dart';

class HowToPlayScreen extends ConsumerStatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  ConsumerState<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends ConsumerState<HowToPlayScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- ESTADO DEL SIMULADOR INTERACTIVO 4X4 (ACADEMIA DE LEYES) ---
  final List<List<int>> _initialGrid = [
    [1, 0, 3, 4],
    [3, 4, 0, 2],
    [2, 3, 4, 0],
    [0, 1, 2, 3],
  ];
  
  final List<List<int>> _solution = [
    [1, 2, 3, 4],
    [3, 4, 1, 2],
    [2, 3, 4, 1],
    [4, 1, 2, 3],
  ];

  late List<List<int>> _grid;
  int _selectedRow = -1;
  int _selectedCol = -1;
  String _feedbackMessage = "Toca cualquier celda con el símbolo '?' para rellenarla.";
  Color _feedbackColor = Colors.grey;
  bool _isSolved = false;
  
  // Para resaltar celdas en conflicto
  int _conflictRow = -1;
  int _conflictCol = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _resetSimulator();
  }

  void _resetSimulator() {
    setState(() {
      _grid = List.generate(4, (r) => List.from(_initialGrid[r]));
      _selectedRow = -1;
      _selectedCol = -1;
      _conflictRow = -1;
      _conflictCol = -1;
      _feedbackMessage = "Toca cualquier celda con el símbolo '?' para rellenarla.";
      _feedbackColor = Colors.grey;
      _isSolved = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Lógica interactiva de validación del simulador de 4x4
  void _inputNumber(int val) {
    if (_selectedRow == -1 || _selectedCol == -1 || _isSolved) return;
    
    // 1. Validar colisión en la Fila
    for (int i = 0; i < 4; i++) {
      if (i != _selectedCol && _grid[_selectedRow][i] == val) {
        setState(() {
          _conflictRow = _selectedRow;
          _conflictCol = i;
          _feedbackMessage = "⚠️ LEY DE FILA VIOLADA: El número $val ya existe en la misma línea horizontal.";
          _feedbackColor = Colors.redAccent;
        });
        return;
      }
    }

    // 2. Validar colisión en la Columna
    for (int i = 0; i < 4; i++) {
      if (i != _selectedRow && _grid[i][_selectedCol] == val) {
        setState(() {
          _conflictRow = i;
          _conflictCol = _selectedCol;
          _feedbackMessage = "⚠️ LEY DE COLUMNA VIOLADA: El número $val ya existe en la misma línea vertical.";
          _feedbackColor = Colors.redAccent;
        });
        return;
      }
    }

    // 3. Validar colisión en la Caja de 2x2 (Subcuadrícula)
    final boxRow = (_selectedRow ~/ 2) * 2;
    final boxCol = (_selectedCol ~/ 2) * 2;
    for (int i = boxRow; i < boxRow + 2; i++) {
      for (int j = boxCol; j < boxCol + 2; j++) {
        if ((i != _selectedRow || j != _selectedCol) && _grid[i][j] == val) {
          setState(() {
            _conflictRow = i;
            _conflictCol = j;
            _feedbackMessage = "⚠️ LEY DE SECTOR VIOLADA: El número $val ya se encuentra en esta caja de 2x2.";
            _feedbackColor = Colors.redAccent;
          });
          return;
        }
      }
    }

    // 4. Validar si el número es el correcto para la solución (Evitar adivinar ciegamente)
    if (_solution[_selectedRow][_selectedCol] != val) {
      setState(() {
        _conflictRow = -1;
        _conflictCol = -1;
        _feedbackMessage = "⚠️ LEY INVISIBLE: Aunque el número $val no colisiona directamente en fila o columna, esa posición no resuelve el flujo sideral.";
        _feedbackColor = Colors.amber[700]!;
      });
      return;
    }

    // Movimiento correcto
    setState(() {
      _grid[_selectedRow][_selectedCol] = val;
      _conflictRow = -1;
      _conflictCol = -1;
      _feedbackMessage = "✨ ¡Movimiento estelar correcto! Las tres leyes se han respetado.";
      _feedbackColor = Colors.green;
      _selectedRow = -1;
      _selectedCol = -1;

      // Verificar si se completó
      _checkCompletion();
    });
  }

  void _checkCompletion() {
    bool solved = true;
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (_grid[r][c] != _solution[r][c]) {
          solved = false;
          break;
        }
      }
    }
    if (solved) {
      _isSolved = true;
      _feedbackMessage = "🎉 ¡MAESTRO DEL COSMOS! 🌟 Has resuelto el mini-grid estelar respetando todas las leyes lógicas de Numbra. ¡Estás listo para las ligas espaciales!";
      _feedbackColor = Colors.greenAccent[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
      appBar: AppBar(
        title: Text(
          'ACADEMIA COSMOS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: sudokuTheme.primaryColor,
          labelColor: sudokuTheme.primaryColor,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
          tabs: const [
            Tab(text: 'LAS TRES LEYES', icon: Icon(Icons.gavel_rounded, size: 20)),
            Tab(text: 'MAESTRÍA (TIPS)', icon: Icon(Icons.psychology_rounded, size: 20)),
            Tab(text: 'PODER RPG', icon: Icon(Icons.auto_awesome_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLawsTab(sudokuTheme, isDark),
          _buildTipsTab(sudokuTheme, isDark),
          _buildRpgTab(sudokuTheme, isDark),
        ],
      ),
    );
  }

  // --- PESTAÑA 1: LAS TRES LEYES CON SANDBOX INTERACTIVO 4X4 ---
  Widget _buildLawsTab(dynamic theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveContentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroductionCard(
              'EL RETO DEL VACÍO ESTELAR',
              'El Sudoku es un puzzle de lógica puro donde debes poblar el cosmos numérico. El tablero cuenta con 9 filas, 9 columnas y 9 cajas de 3x3. Tu objetivo es rellenar las celdas vacías con números del 1 al 9 siguiendo tres leyes absolutas que rigen la armonía sideral.',
              '🚀',
              theme,
              isDark,
            ),
            const SizedBox(height: 24),
            
            // --- SANDBOX INTERACTIVO 4X4 ---
            _buildSectionTitle('ENTRENAMIENTO TÁCTICO INTERACTIVO (4X4)'),
            const SizedBox(height: 8),
            Text(
              'Prueba las leyes en vivo en nuestro mini-Sudoku. Toca una casilla con "?" y presiona un número abajo para intentar resolverlo sin romper las tres leyes.',
              style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            _buildInteractiveSimulator(theme, isDark),
            
            const SizedBox(height: 28),
            _buildSectionTitle('LAS TRES LEYES EN DETALLE'),
            const SizedBox(height: 12),

            // Ley 1
            _buildLawCard(
              '1. LEY DE LA FILA HORTIZONTAL',
              'Cada una de las 9 filas horizontales debe contener todos los números del 1 al 9. Ningún número puede repetirse en la misma fila.',
              '↔️',
              _buildMiniGridDemo(type: 'row', theme: theme, isDark: isDark),
              theme,
              isDark,
            ),
            const SizedBox(height: 16),

            // Ley 2
            _buildLawCard(
              '2. LEY DE LA COLUMNA VERTICAL',
              'Cada una de las 9 columnas verticales debe albergar la secuencia completa del 1 al 9 sin duplicados.',
              '↕️',
              _buildMiniGridDemo(type: 'col', theme: theme, isDark: isDark),
              theme,
              isDark,
            ),
            const SizedBox(height: 16),

            // Ley 3
            _buildLawCard(
              '3. LEY DEL SECTOR 3X3 (LA CAJA)',
              'El tablero se divide en 9 cuadrículas de 3x3 llamadas cajas. Cada una de ellas debe contener los números del 1 al 9 una sola vez.',
              '⚃',
              _buildMiniGridDemo(type: 'box', theme: theme, isDark: isDark),
              theme,
              isDark,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- PESTAÑA 2: MAESTRÍA (CONSEJOS) ---
  Widget _buildTipsTab(dynamic theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveContentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroductionCard(
              'EL CAMINO DEL PENSAMIENTO TÁCTICO',
              'Resolver un Sudoku no requiere sumas ni matemáticas; es un ejercicio de escaneo visual y descarte ordenado. Los grandes maestros del cosmos aplican técnicas sencillas que simplifican el caos.',
              '🧠',
              theme,
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('TÉCNICAS DE MAESTRO (QUÉ TENER EN CUENTA)'),
            const SizedBox(height: 12),

            _buildTipStepCard(
              'Paso 1: Escaneo Cruzado (Cross-Hatching)',
              'Elige un número (por ejemplo, el 5) y sigue mentalmente sus filas y columnas asociadas en una caja de 3x3. Por descarte visual, verás que solo queda una celda libre en esa caja para colocarlo.',
              '👁️',
              isDark,
            ),
            const SizedBox(height: 12),

            _buildTipStepCard(
              'Paso 2: Usa el Lápiz (Modo Notas)',
              'Cuando dudes entre dos o tres opciones para una casilla, ¡no adivines! Activa el Modo Notas (tecla N). Esto te permite colocar pequeños números candidatos en las esquinas de la celda para estructurar tus deducciones.',
              '✏️',
              isDark,
            ),
            const SizedBox(height: 12),

            _buildTipStepCard(
              'Paso 3: Búsqueda del Único Candidato (Naked Single)',
              'Analiza casillas que compartan muchas restricciones. A veces, al mirar su fila, su columna y su caja de 3x3, verás que 8 de los 9 números posibles ya están colocados a su alrededor. ¡El número restante es el correcto por ley de exclusión!',
              '🎯',
              isDark,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- PESTAÑA 3: PODER RPG CON ICONOS CORRECTOS ---
  Widget _buildRpgTab(dynamic theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveContentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroductionCard(
              'EL SISTEMA TÁCTICO RPG DE NUMBRA',
              'A diferencia del Sudoku tradicional, en Numbra eres un Viajero del Espacio Lógico. Cuentas con un sistema de vidas y un arsenal de habilidades míticas que puedes desbloquear en el Centro de Suministros usando tus S-Coins.',
              '✨',
              theme,
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('REGLAS Y HABILIDADES TÁCTICAS RPG'),
            const SizedBox(height: 12),

            // Límite de errores
            _buildRpgFeatureCard(
              'Línea de Vida (3 Errores)',
              'Si cometes un error de lógica y colocas un número incorrecto, el sistema lo marcará en rojo y perderás 1 vida. Si acumulas 3 errores, la partida se congelará (Game Over). Puedes comprar una "Segunda Oportunidad" usando tus S-Coins.',
              Icons.favorite_rounded,
              Colors.redAccent,
              isDark,
            ),
            const SizedBox(height: 12),

            // Habilidad 1: Visión Verdadera
            _buildRpgFeatureCard(
              'Habilidad: Visión Verdadera (True Vision)',
              'Consume 1 Cristal de Visión de tu inventario. Activa un escáner que ilumina de forma visual en color rojo todos los errores actuales sobre tu tablero durante 15 segundos sin penalizar tus vidas.',
              Icons.auto_awesome_rounded, // ICONO REAL DEL JUEGO
              Colors.teal,
              isDark,
            ),
            const SizedBox(height: 12),

            // Habilidad 2: Reloj Estelar
            _buildRpgFeatureCard(
              'Habilidad: Reloj Estelar (Star Chrono)',
              'Consume 1 Reloj Eterno. Detiene por completo el transcurso del cronómetro de la partida durante 45 segundos, permitiéndote respirar, evaluar el grid sin prisa y mantener tus récords de velocidad intactos.',
              Icons.hourglass_bottom_rounded, // ICONO REAL DEL JUEGO
              Colors.blueAccent,
              isDark,
            ),
            const SizedBox(height: 12),

            // Habilidad 3: Toque Divino
            _buildRpgFeatureCard(
              'Habilidad: Toque Divino (Divine Touch)',
              'Consume 1 Orbe de Purificación. Purifica por completo tu tablero limpiando todos los errores que tengas acumulados y revela de forma instantánea 3 números correctos en el tablero al azar.',
              Icons.psychology_rounded, // ICONO REAL DEL JUEGO
              Colors.amber,
              isDark,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE DISEÑO ---

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildIntroductionCard(
    String headline,
    String desc,
    String emoji,
    dynamic theme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [theme.primaryColor.withOpacity(0.15), const Color(0xFF1E1E2E).withOpacity(0.5)]
              : [theme.primaryColor.withOpacity(0.08), Colors.white],
        ),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DEL SIMULADOR INTERACTIVO 4X4 ---
  Widget _buildInteractiveSimulator(dynamic theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isSolved 
              ? Colors.greenAccent.withOpacity(0.5)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          width: _isSolved ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isSolved 
                ? Colors.greenAccent.withOpacity(0.08)
                : Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          // Mensaje de feedback dinámico interactivo
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _feedbackColor.withOpacity(isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  _isSolved 
                      ? Icons.emoji_events_rounded 
                      : (_feedbackColor == Colors.redAccent ? Icons.warning_amber_rounded : Icons.info_outline),
                  color: _feedbackColor == Colors.grey ? theme.primaryColor : _feedbackColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _feedbackMessage,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _feedbackColor == Colors.grey ? (isDark ? Colors.grey[300] : Colors.grey[700]) : _feedbackColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Tablero de 4x4
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.white54 : Colors.black54, width: 2.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: List.generate(4, (r) {
                      return Expanded(
                        child: Row(
                          children: List.generate(4, (c) {
                            final cellVal = _grid[r][c];
                            final isInitial = _initialGrid[r][c] != 0;
                            final isSelected = _selectedRow == r && _selectedCol == c;
                            final isConflict = _conflictRow == r && _conflictCol == c;
                            
                            // Determinar color de la celda
                            Color cellBg = isDark ? const Color(0xFF1A1A26) : Colors.white;
                            if (isSelected) {
                              cellBg = theme.primaryColor.withOpacity(isDark ? 0.35 : 0.22);
                            } else if (isConflict) {
                              cellBg = Colors.redAccent.withOpacity(0.3);
                            } else if (_isSolved) {
                              cellBg = Colors.greenAccent.withOpacity(0.12);
                            }

                            // Bordes gruesos para demarcar cajas de 2x2
                            BorderSide borderRight = BorderSide(
                              color: c == 1 ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? Colors.white12 : Colors.grey[200]!),
                              width: c == 1 ? 2.5 : 0.8,
                            );
                            BorderSide borderBottom = BorderSide(
                              color: r == 1 ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? Colors.white12 : Colors.grey[200]!),
                              width: r == 1 ? 2.5 : 0.8,
                            );

                            return Expanded(
                              child: GestureDetector(
                                onTap: isInitial || _isSolved ? null : () {
                                  setState(() {
                                    _selectedRow = r;
                                    _selectedCol = c;
                                    _conflictRow = -1;
                                    _conflictCol = -1;
                                    _feedbackMessage = "Ingresa un número del 1 al 4 para esta casilla.";
                                    _feedbackColor = Colors.grey;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cellBg,
                                    border: Border(
                                      right: c != 3 ? borderRight : BorderSide.none,
                                      bottom: r != 3 ? borderBottom : BorderSide.none,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cellVal != 0 ? '$cellVal' : '?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isInitial ? FontWeight.bold : FontWeight.w500,
                                      color: isInitial
                                          ? (isDark ? Colors.white : Colors.black87)
                                          : (_isSolved 
                                              ? Colors.greenAccent[400] 
                                              : (isSelected ? theme.primaryColor : Colors.blueAccent)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Selector de números 1 a 4 (sólo visible al seleccionar celda)
          if (_selectedRow != -1 && _selectedCol != -1 && !_isSolved) ...[
            Text(
              'Selecciona el número para la celda ($_selectedRow, $_selectedCol):',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final num = i + 1;
                return GestureDetector(
                  onTap: () => _inputNumber(num),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF2B2B3C), const Color(0xFF1E1E2E)]
                            : [Colors.grey[100]!, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$num',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : theme.primaryColor,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ] else if (_isSolved) ...[
            ElevatedButton.icon(
              onPressed: _resetSimulator,
              icon: const Icon(Icons.replay_rounded, size: 16),
              label: const Text('Reiniciar Entrenamiento', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ] else ...[
            Text(
              'Toca cualquier casilla con "?" para seleccionarla.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLawCard(
    String title,
    String desc,
    String icon,
    Widget demoGrid,
    dynamic theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131F) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4),
          ),
          const SizedBox(height: 16),
          Center(child: demoGrid),
        ],
      ),
    );
  }

  Widget _buildTipStepCard(String stepTitle, String stepDesc, String stepEmoji, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stepEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepTitle,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepDesc,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRpgFeatureCard(String title, String desc, IconData icon, Color accent, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- DIBUJANTE DE MINI GRIDS DEMOSTRATIVAS DE SUDOKU (WIDGET DART) ---

  Widget _buildMiniGridDemo({required String type, required dynamic theme, required bool isDark}) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.white30 : Colors.black38, width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(3, (r) {
            return Expanded(
              child: Row(
                children: List.generate(3, (c) {
                  // Lógica de colorear según la ley explicada
                  bool highlight = false;
                  String val = '';
                  
                  if (type == 'row') {
                    if (r == 1) {
                      highlight = true;
                      val = '${c + 4}';
                    } else {
                      val = (r == 0) ? '${c + 1}' : '${c + 7}';
                    }
                  } else if (type == 'col') {
                    if (c == 1) {
                      highlight = true;
                      val = '${r + 4}';
                    } else {
                      val = (c == 0) ? '${r + 1}' : '${r + 7}';
                    }
                  } else if (type == 'box') {
                    highlight = true; 
                    val = '${r * 3 + c + 1}';
                  }

                  final cellBg = highlight
                      ? theme.primaryColor.withOpacity(isDark ? 0.25 : 0.18)
                      : (isDark ? const Color(0xFF191924) : Colors.grey[50]!);
                  
                  final textStyle = TextStyle(
                    fontSize: 14,
                    fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                    color: highlight
                        ? (isDark ? theme.textColorDark : theme.textColorLight)
                        : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  );

                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cellBg,
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(val, style: textStyle),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
