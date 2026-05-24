import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/theme_selector.dart';
import '../widgets/reward_unlock_modal.dart';
import '../models/user_profile.dart';
import '../providers/storage_provider.dart';
import 'game_screen.dart';
import 'store_screen.dart';
import 'login_screen.dart';
import '../widgets/responsive_content_wrapper.dart';

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
          description:
              '¡Felicidades! Has progresado intelectualmente y subido al siguiente nivel.',
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
        final achievement =
            Achievement.allAchievements.firstWhere((a) => a.title == title);
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
      fontSize: 32,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.5,
      color: isDark ? Colors.white : const Color(0xFF2B2B36),
    );

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ResponsiveContentWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

              // 1. Selector rápido de temas en pastilla Glassmorphic sutil
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.02)
                        : Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: const ThemeSelector(),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Partida en curso flotante
              if (ref.watch(gameProvider).hasStarted)
                _buildActiveGameCard(context, ref, sudokuTheme, isDark),

              // 3.5 Banner de Invitado (UX Improvement)
              if (!userProfile.isRegistered)
                _buildGuestSyncBanner(context, sudokuTheme, isDark),

              // 4. Banner Destacado del Reto Diario (Llama de Racha 🔥)
              _buildDailyChallengeFeatureBanner(
                  context, userProfile, sudokuTheme, isDark),

              const SizedBox(height: 20),

              // 5. Grid 2x2 de Dificultades Modernas
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: MediaQuery.of(context).size.width > 800 ? 1.35 : 1.18,
                      children: [
                        _buildModernDifficultyCard(
                          context,
                          ref,
                          title: 'Fácil',
                          icon: '🌱',
                          bestTime: storage.getBestTime('Fácil'),
                          accentColor: Colors.teal,
                          isDark: isDark,
                        ),
                        _buildModernDifficultyCard(
                          context,
                          ref,
                          title: 'Medio',
                          icon: '⚡',
                          bestTime: storage.getBestTime('Medio'),
                          accentColor: Colors.blueAccent,
                          isDark: isDark,
                        ),
                        _buildModernDifficultyCard(
                          context,
                          ref,
                          title: 'Difícil',
                          icon: '🔮',
                          bestTime: storage.getBestTime('Difícil'),
                          accentColor: Colors.purpleAccent,
                          isDark: isDark,
                        ),
                        _buildModernDifficultyCard(
                          context,
                          ref,
                          title: 'Experto',
                          icon: '👑',
                          bestTime: storage.getBestTime('Experto'),
                          accentColor: Colors.redAccent,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6. Acceso Refinado al Pie a la Tienda de Temas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const StoreScreen()),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.store_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CENTRO DE SUMINISTROS',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF2B2B36),
                                    ),
                                  ),
                                  Text(
                                    'Adquiere pociones, avatares y boosters para tu viaje.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: sudokuTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Dificultad: ${game.difficulty} • Tiempo: $min:$sec',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildDailyChallengeFeatureBanner(
    BuildContext context,
    UserProfile userProfile,
    SudokuTheme theme,
    bool isDark,
  ) {
    final streak = userProfile.dailyStreak;
    final hasStreak = streak > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF6B11FF), // Violeta Neón
                  const Color(0xFFFF1393), // Fucsia Neón
                ]
              : [
                  const Color(0xFF8E2DE2),
                  const Color(0xFF4A00E0),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B11FF).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startDailyChallengeDirectly(context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥 ', style: TextStyle(fontSize: 13)),
                            Text(
                              hasStreak
                                  ? 'Racha: $streak ${streak == 1 ? 'día' : 'días'}'
                                  : 'Reto del Día',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'RETO DIARIO',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasStreak
                            ? '¡Mantén encendida la llama de tu racha hoy!'
                            : 'Resuelve el tablero sembrado único de hoy.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startDailyChallengeDirectly(BuildContext context) {
    final today = DateTime.now();
    final dateStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final seed = today.year * 10000 + today.month * 100 + today.day;

    // Determinar dificultad por día
    String difficulty = 'Medio';
    final weekday = today.weekday;
    if (weekday == DateTime.monday || weekday == DateTime.tuesday) {
      difficulty = 'Fácil';
    } else if (weekday == DateTime.wednesday || weekday == DateTime.thursday) {
      difficulty = 'Medio';
    } else if (weekday == DateTime.friday || weekday == DateTime.saturday) {
      difficulty = 'Difícil';
    } else if (weekday == DateTime.sunday) {
      difficulty = 'Experto';
    }

    // Verificar si ya se completó el reto hoy
    final completedDates = ref.read(profileProvider).completedDailyDates;
    if (completedDates.contains(dateStr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              '¡Ya has completado el Reto Diario de hoy! Vuelve mañana para continuar tu racha. 🎉'),
          backgroundColor: Colors.purple[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Iniciar partida
    ref.read(gameProvider.notifier).startDailyChallengeGame(seed, difficulty);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  Widget _buildGuestSyncBanner(
      BuildContext context, SudokuTheme theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.accentColor.withOpacity(0.05)
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Text('☁️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Sincroniza tu progreso!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Regístrate para guardar tus monedas y nivel en la nube.',
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
              child: Text(
                'IR',
                style: TextStyle(
                    color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDifficultyCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String icon,
    required int bestTime,
    required Color accentColor,
    required bool isDark,
  }) {
    final String recordText = bestTime == 0
        ? 'Sin Récord'
        : '${(bestTime ~/ 60).toString().padLeft(2, '0')}:${(bestTime % 60).toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey[200]!,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
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
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Fila Superior: Icono de dificultad y punto indicador
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Fila Inferior: Título y Récord
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF2B2B36),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recordText,
                          style: GoogleFonts.shareTechMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: bestTime > 0
                                ? accentColor
                                : (isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
