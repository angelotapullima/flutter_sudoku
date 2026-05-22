import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/theme_selector.dart';
import '../widgets/reward_unlock_modal.dart';
import '../models/user_profile.dart';
import 'game_screen.dart';
import 'stats_screen.dart';
import 'store_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Intentar reanudar partida activa si existe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).tryLoadSavedGame();
      _setupGamificationCallbacks();
    });
  }

  void _setupGamificationCallbacks() {
    final profileNotifier = ref.read(profileProvider.notifier);

    // Callback para subida de nivel
    profileNotifier.onLevelUp = (newLevel, rewardCoins) {
      if (mounted) {
        RewardUnlockModal.show(
          context,
          ref: ref,
          title: 'Nivel $newLevel',
          description: '¡Felicidades! Has progresado intelectualmente y subido al siguiente nivel.',
          coinsReward: rewardCoins,
          xpReward: 0,
          icon: '👑',
          type: 'level',
        );
      }
    };

    // Callback para logro desbloqueado
    profileNotifier.onAchievementUnlocked = (title) {
      if (mounted) {
        final achievement = Achievement.allAchievements.firstWhere((a) => a.title == title);
        RewardUnlockModal.show(
          context,
          ref: ref,
          title: title,
          description: achievement.description,
          coinsReward: achievement.rewardCoins,
          xpReward: achievement.rewardXp,
          icon: achievement.icon,
          type: 'achievement',
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;

    final userProfile = ref.watch(profileProvider);
    final storage = ref.watch(storageServiceProvider);

    final fontHeadline = GoogleFonts.outfit(
      fontSize: 42,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
      color: isDark ? Colors.white : const Color(0xFF2B2B36),
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. Barra superior: Perfil, Nivel y Monedas
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nivel y barra de progreso
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: sudokuTheme.primaryColor,
                          child: Text(
                            '${userProfile.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nivel ${userProfile.level}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[300] : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Barra de progreso de XP
                            SizedBox(
                              width: 100,
                              height: 6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: userProfile.progressPercentage,
                                  backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(sudokuTheme.primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Monedas (S-Coins)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey[200]!,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('🪙 ', style: TextStyle(fontSize: 16)),
                          Text(
                            '${userProfile.coins}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Selector de tema
              const ThemeSelector(),

              const SizedBox(height: 16),

              // 2. Título de la App
              Text('SUDOKU', style: fontHeadline),
              Text(
                'PIENSA • RESUELVE • MEJORA',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4.0,
                  color: sudokuTheme.primaryColor.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 32),

              // Partida en progreso flotante si existe
              if (ref.watch(gameProvider).hasStarted)
                _buildActiveGameCard(context, ref, sudokuTheme, isDark),

              // 3. Selección de dificultades
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                      child: Text(
                        'Selecciona Dificultad',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    _buildDifficultyCard(
                      context,
                      ref,
                      title: 'Fácil',
                      description: 'Ideal para relajarse e iniciar en el juego.',
                      bestTime: storage.getBestTime('Fácil'),
                      gradientColors: [Colors.green[400]!, Colors.teal[500]!],
                    ),
                    const SizedBox(height: 12),
                    _buildDifficultyCard(
                      context,
                      ref,
                      title: 'Medio',
                      description: 'Desafío equilibrado para entrenar la mente.',
                      bestTime: storage.getBestTime('Medio'),
                      gradientColors: [Colors.blue[400]!, Colors.indigo[500]!],
                    ),
                    const SizedBox(height: 12),
                    _buildDifficultyCard(
                      context,
                      ref,
                      title: 'Difícil',
                      description: 'Requiere técnicas avanzadas de lógica.',
                      bestTime: storage.getBestTime('Difícil'),
                      gradientColors: [Colors.purple[400]!, Colors.deepPurple[500]!],
                    ),
                    const SizedBox(height: 12),
                    _buildDifficultyCard(
                      context,
                      ref,
                      title: 'Experto',
                      description: 'Récord solo para los verdaderos maestros.',
                      bestTime: storage.getBestTime('Experto'),
                      gradientColors: [Colors.red[400]!, Colors.pink[600]!],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. Botones inferiores: Tienda y Estadísticas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMenuButton(
                        context,
                        icon: Icons.store_rounded,
                        label: 'Tienda de Temas',
                        color: Colors.amber[700]!,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const StoreScreen()),
                        ),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMenuButton(
                        context,
                        icon: Icons.bar_chart_rounded,
                        label: 'Estadísticas',
                        color: sudokuTheme.primaryColor,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const StatsScreen()),
                        ),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveGameCard(
    BuildContext context,
    WidgetRef ref,
    SudokuTheme theme,
    bool isDark,
  ) {
    final game = ref.watch(gameProvider);
    final min = (game.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (game.elapsedSeconds % 60).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GameScreen()),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Partida en Curso',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Dificultad: ${game.difficulty} • Tiempo: $min:$sec',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required int bestTime,
    required List<Color> gradientColors,
  }) {
    final String recordText = bestTime == 0
        ? 'Sin Récord'
        : 'Récord: ${(bestTime ~/ 60).toString().padLeft(2, '0')}:${(bestTime % 60).toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(gameProvider.notifier).startNewGame(title);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const GameScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.whiteEF,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recordText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Column(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension ColorEF on Colors {
  static const Color whiteEF = Colors.white70;
}
