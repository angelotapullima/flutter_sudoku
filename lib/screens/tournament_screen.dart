import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_provider.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/gamification_provider.dart';
import 'game_screen.dart';

class TournamentScreen extends ConsumerWidget {
  const TournamentScreen({super.key});

  void _startTournament(BuildContext context, WidgetRef ref) {
    final gamification = ref.read(gamificationProvider);
    final tournament = gamification.activeTournament;
    
    if (tournament == null) return;

    final userProfile = ref.read(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final gameNotifier = ref.read(gameProvider.notifier);

    const cost = 100; // Costo fijo por ahora para el torneo global

    if (userProfile.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🪙 Monedas insuficientes para la inscripción.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    profileNotifier.deductCoins(cost);

    // Iniciar juego con el tablero real del torneo
    gameNotifier.startRealTournamentGame(
      tournament.id,
      tournament.puzzleData,
      tournament.solutionData,
      tournament.difficulty,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final gamification = ref.watch(gamificationProvider);

    if (gamification.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tournament = gamification.activeTournament;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TORNEO GLOBAL',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white : const Color(0xFF2B2B36),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showCreateTournamentDialog(context, ref),
                    icon: Icon(Icons.add_circle_outline, color: sudokuTheme.primaryColor, size: 28),
                    tooltip: 'Crear Torneo',
                  ),
                ],
              ),
            ),

            if (tournament == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 64, color: isDark ? Colors.white24 : Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay torneos activos hoy.\n¡Crea uno tú mismo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Tarjeta del Torneo
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      tournament.title,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dificultad: ${tournament.difficulty}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'PREMIO: ${tournament.prizeFirst} S-Coins',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ranking Real
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.leaderboard_rounded, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'TOP 10 MUNDIAL',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: gamification.tournamentRanking.length,
                  itemBuilder: (context, index) {
                    final entry = gamification.tournamentRanking[index];
                    final isMe = entry['username'] == ref.read(profileProvider).username;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isMe 
                          ? Colors.amber.withOpacity(0.1) 
                          : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isMe ? Colors.amber : (isDark ? Colors.white10 : Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: index < 3 ? Colors.amber : (isDark ? Colors.white38 : Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              entry['username'],
                              style: TextStyle(
                                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            '${(entry['best_time_seconds'] ~/ 60).toString().padLeft(2, '0')}:${(entry['best_time_seconds'] % 60).toString().padLeft(2, '0')}',
                            style: GoogleFonts.jetBrainsMono(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Botón Jugar (siempre visible si hay torneo)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _startTournament(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sudokuTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      'PARTICIPAR POR 100 🪙',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _showCreateTournamentDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String difficulty = 'Medio';

    showDialog(
      context: context,
      barrierDismissible: false, // Evitar cerrar durante la creación
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool creating = false;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Nuevo Torneo Comunitario'),
            content: creating 
              ? const SizedBox(
                  height: 100, 
                  child: Center(child: CircularProgressIndicator())
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Torneo',
                        hintText: 'Ej: Gran Reto Sudoku',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Dificultad del Tablero:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: difficulty,
                      isExpanded: true,
                      items: ['Fácil', 'Medio', 'Difícil', 'Experto']
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) => setState(() => difficulty = val!),
                    ),
                  ],
                ),
            actions: creating ? [] : [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  
                  setState(() => creating = true);
                  
                  final res = await ref.read(gamificationProvider.notifier).createTournament(
                        titleController.text,
                        difficulty,
                      );
                      
                  if (res['success']) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Torneo publicado con éxito! 🏆'), backgroundColor: Colors.green),
                    );
                  } else {
                    setState(() => creating = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
                  }
                },
                child: const Text('Lanzar Torneo'),
              ),
            ],
          );
        },
      ),
    );
  }
}
