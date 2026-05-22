import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_provider.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import 'game_screen.dart';

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen> {
  String _selectedDivision = 'Plata'; // Por defecto Plata

  // Datos fijos de divisiones
  final Map<String, Map<String, dynamic>> _divisionsData = {
    'Bronce': {
      'cost': 30,
      'maxReward': '80 S-Coins + 250 XP',
      'difficulty': 'Fácil',
      'gradient': [Color(0xFFCD7F32), Color(0xFF8B5A2B)],
      'bots': [
        {'name': 'Lucas P.', 'speed': 'Lento (~5-7 min)', 'range': [260, 420]},
        {'name': 'Marta G.', 'speed': 'Lento (~6-8 min)', 'range': [320, 480]},
        {'name': 'Carlos D.', 'speed': 'Principiante (~7-9 min)', 'range': [380, 540]},
        {'name': 'Sofía T.', 'speed': 'Principiante (~8-10 min)', 'range': [440, 600]},
      ],
    },
    'Plata': {
      'cost': 60,
      'maxReward': '150 S-Coins + 400 XP',
      'difficulty': 'Medio',
      'gradient': [Color(0xFFC0C0C0), Color(0xFF708090)],
      'bots': [
        {'name': 'Diego R.', 'speed': 'Moderado (~3-4 min)', 'range': [160, 240]},
        {'name': 'Clara J.', 'speed': 'Moderado (~4-5 min)', 'range': [220, 300]},
        {'name': 'Javier S.', 'speed': 'Intermedio (~5-6 min)', 'range': [280, 360]},
        {'name': 'Ana M.', 'speed': 'Intermedio (~6-7 min)', 'range': [340, 420]},
      ],
    },
    'Oro': {
      'cost': 100,
      'maxReward': '250 S-Coins + 600 XP',
      'difficulty': 'Difícil',
      'gradient': [Color(0xFFFFD700), Color(0xFFDAA520)],
      'bots': [
        {'name': 'Master Ken', 'speed': 'Extremo (~1.5-2 min)', 'range': [90, 130]},
        {'name': 'SudokuGod', 'speed': 'Experto (~2-2.5 min)', 'range': [120, 160]},
        {'name': 'LogicLord', 'speed': 'Experto (~2.5-3 min)', 'range': [150, 190]},
        {'name': 'NeuralNet', 'speed': 'Avanzado (~3-4 min)', 'range': [180, 240]},
      ],
    },
  };

  void _startTournament() {
    final userProfile = ref.read(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final gameNotifier = ref.read(gameProvider.notifier);

    final divisionData = _divisionsData[_selectedDivision]!;
    final cost = divisionData['cost'] as int;

    if (userProfile.coins < cost) {
      // Monedas insuficientes: mostrar elegante SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🪙 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  'Monedas insuficientes. Necesitas $cost S-Coins para inscribirte.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Descontar monedas
    profileNotifier.deductCoins(cost);

    // Generar oponentes y sus tiempos aleatorios basados en el rango
    final random = Random();
    final List<String> opponents = [];
    final List<int> opponentTimes = [];

    final botsList = divisionData['bots'] as List<Map<String, dynamic>>;
    for (var bot in botsList) {
      opponents.add(bot['name'] as String);
      final range = bot['range'] as List<int>;
      // Generar tiempo aleatorio en segundos dentro del rango
      final time = range[0] + random.nextInt(range[1] - range[0] + 1);
      opponentTimes.add(time);
    }

    // Iniciar juego de torneo
    gameNotifier.startTournamentGame(_selectedDivision, opponents, opponentTimes);

    // Navegar a la pantalla del juego
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
              child: Text(
                'LIGA DE CAMPEONES',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : const Color(0xFF2B2B36),
                ),
              ),
            ),

            // Selector Horizontal de Divisiones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _divisionsData.keys.map((division) {
                  final isSelected = _selectedDivision == division;
                  final divColor = _divisionsData[division]!['gradient'] as List<Color>;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDivision = division;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: divColor,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: !isSelected
                              ? (isDark ? const Color(0xFF1E1E2E) : Colors.white)
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? Colors.white10 : Colors.grey[200]!),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: divColor[0].withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            division.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.grey[400] : Colors.grey[700]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta de la división seleccionada
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey[200]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titular de la división y costo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIGA $_selectedDivision',
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: _divisionsData[_selectedDivision]!['gradient'][0],
                              ),
                            ),
                            Text(
                              'Dificultad: ${_divisionsData[_selectedDivision]!['difficulty']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sudokuTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Entrada: 🪙 ${_divisionsData[_selectedDivision]!['cost']}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: sudokuTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(height: 1, color: Colors.white10),
                    const SizedBox(height: 14),

                    // Premios
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Premio 1º Lugar:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_divisionsData[_selectedDivision]!['maxReward']}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Rivales a Batir
                    Text(
                      'Rivales de la Arena',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: (_divisionsData[_selectedDivision]!['bots'] as List).length,
                        itemBuilder: (context, index) {
                          final bot = (_divisionsData[_selectedDivision]!['bots'] as List)[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                                  child: Text(
                                    bot['name'].substring(0, 1),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bot['name'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        'Récord estimado: ${bot['speed']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.bolt, color: Colors.amber, size: 18),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón de Inscripción
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startTournament,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sudokuTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                    shadowColor: sudokuTheme.primaryColor.withOpacity(0.3),
                  ),
                  child: Text(
                    'Pagar Inscripción y Jugar',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
