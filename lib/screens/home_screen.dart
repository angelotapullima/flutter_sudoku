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
import '../utils/enums.dart';
import 'game_screen.dart';
import 'store_screen.dart';
import 'login_screen.dart';
import 'how_to_play_screen.dart';
import 'daily_challenge_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).tryLoadSavedGame();
      _setupGamificationCallbacks();
    });
  }

  void _setupGamificationCallbacks() {
    final profileNotifier = ref.read(profileProvider.notifier);
    profileNotifier.onLevelUp = (newLevel, rewardCoins) {
      if (mounted) {
        RewardUnlockModal.show(context, ref: ref, title: 'Nivel $newLevel', description: '¡Felicidades! Has progresado intelectualmente.', coinsReward: rewardCoins, xpReward: 0, icon: '👑', type: 'level');
      }
    };
    profileNotifier.onAchievementUnlocked = (title) {
      if (mounted) {
        final achievement = Achievement.allAchievements.firstWhere((a) => a.title == title);
        RewardUnlockModal.show(context, ref: ref, title: title, description: achievement.description, coinsReward: achievement.rewardCoins, xpReward: achievement.rewardXp, icon: achievement.icon, type: 'achievement');
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final isDark = themeState.isDarkMode;
    final userProfile = ref.watch(profileProvider);
    final storage = ref.watch(storageServiceProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;

            // Detección de Layout Trifecta
            DeviceLayoutType layoutType;
            if (width > 1100) {
              layoutType = DeviceLayoutType.desktop;
            } else if (width > height && height < 600) {
              layoutType = DeviceLayoutType.landscapeMobile;
            } else {
              layoutType = DeviceLayoutType.portraitMobile;
            }

            final bool isDesktop = layoutType == DeviceLayoutType.desktop;
            final bool isLandscape = layoutType == DeviceLayoutType.landscapeMobile;
            final double horizontalPadding = isDesktop ? 40.0 : 20.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ResponsiveContentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    
                    // 1. Selector de Temas
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                        ),
                        child: const ThemeSelector(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // 2. Partida en Curso
                    if (ref.watch(gameProvider).hasStarted) 
                      _buildActiveGameCard(context, ref, sudokuTheme, isDark, horizontalPadding, isLandscape),

                    // 3. Banner de Registro
                    if (!userProfile.isRegistered)
                      _buildSyncBanner(context, sudokuTheme, isDark, horizontalPadding, isLandscape),

                    // 4. Reto Diario
                    _buildDailyChallengeBanner(context, userProfile, sudokuTheme, isDark, horizontalPadding, isLandscape),

                    const SizedBox(height: 32),

                    // 5. Selector de Dificultad
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecciona Dificultad',
                            style: GoogleFonts.outfit(
                              fontSize: isLandscape ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF2B2B36),
                            ),
                          ),
                          const SizedBox(height: 16),
                          (isDesktop || isLandscape)
                            ? Row(
                                children: [
                                  Expanded(child: _buildModernDifficultyCard(context, ref, title: 'FÁCIL', icon: '🌱', bestTime: storage.getBestTime('Fácil'), accentColor: Colors.teal, isDark: isDark, isLandscape: isLandscape)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildModernDifficultyCard(context, ref, title: 'MEDIO', icon: '⚡', bestTime: storage.getBestTime('Medio'), accentColor: Colors.blueAccent, isDark: isDark, isLandscape: isLandscape)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildModernDifficultyCard(context, ref, title: 'DIFÍCIL', icon: '🔮', bestTime: storage.getBestTime('Difícil'), accentColor: Colors.purpleAccent, isDark: isDark, isLandscape: isLandscape)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildModernDifficultyCard(context, ref, title: 'EXPERTO', icon: '👑', bestTime: storage.getBestTime('Experto'), accentColor: Colors.redAccent, isDark: isDark, isLandscape: isLandscape)),
                                ],
                              )
                            : GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.15,
                                children: [
                                  _buildModernDifficultyCard(context, ref, title: 'Fácil', icon: '🌱', bestTime: storage.getBestTime('Fácil'), accentColor: Colors.teal, isDark: isDark),
                                  _buildModernDifficultyCard(context, ref, title: 'Medio', icon: '⚡', bestTime: storage.getBestTime('Medio'), accentColor: Colors.blueAccent, isDark: isDark),
                                  _buildModernDifficultyCard(context, ref, title: 'Difícil', icon: '🔮', bestTime: storage.getBestTime('Difícil'), accentColor: Colors.purpleAccent, isDark: isDark),
                                  _buildModernDifficultyCard(context, ref, title: 'Experto', icon: '👑', bestTime: storage.getBestTime('Experto'), accentColor: Colors.redAccent, isDark: isDark),
                                ],
                              ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 6. Academia Cosmos
                    _buildAcademyCard(context, sudokuTheme, isDark, horizontalPadding, isLandscape),

                    const SizedBox(height: 16),

                    // 7. Centro de Suministros
                    _buildStoreCard(context, sudokuTheme, isDark, horizontalPadding, isLandscape),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveGameCard(BuildContext context, WidgetRef ref, dynamic sudokuTheme, bool isDark, double padding, bool isLandscape) {
    final game = ref.watch(gameProvider);
    final min = (game.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (game.elapsedSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: EdgeInsets.only(left: padding, right: padding, bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: sudokuTheme.primaryColor.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: sudokuTheme.primaryColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GameScreen())),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: isLandscape ? 10 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isLandscape ? 8 : 10),
                  decoration: BoxDecoration(color: sudokuTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow_rounded, color: sudokuTheme.primaryColor, size: isLandscape ? 20 : 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Partida en Curso', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: isLandscape ? 14 : 16, color: isDark ? Colors.white : const Color(0xFF2B2B36))),
                      Text('Dificultad: ${game.difficulty} • Tiempo: $min:$sec', style: TextStyle(fontSize: isLandscape ? 11 : 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(gameProvider.notifier).quitGame(),
                  icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                  tooltip: 'Abandonar partida',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, color: sudokuTheme.primaryColor, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncBanner(BuildContext context, dynamic theme, bool isDark, double padding, bool isLandscape) {
    return Padding(
      padding: EdgeInsets.only(left: padding, right: padding, bottom: 20.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: isLandscape ? 10 : 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_outlined, size: isLandscape ? 20 : 24, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Sincroniza tu progreso!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: isLandscape ? 13 : 15)),
                  if (!isLandscape) Text('Asegura tus datos en la nube.', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen())),
              child: Text('IR', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengeBanner(BuildContext context, UserProfile profile, dynamic theme, bool isDark, double padding, bool isLandscape) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final isCompleted = profile.completedDailyDates.contains(today);
    final void Function() onDailyChallengeTap = () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const DailyChallengeScreen()),
      );
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: isLandscape ? 100 : 140),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFF6200EA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: const Color(0xFF6200EA).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onDailyChallengeTap,
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned(right: -20, bottom: -20, child: Icon(Icons.local_fire_department_rounded, size: isLandscape ? 100 : 140, color: Colors.white.withOpacity(0.1))),
                Padding(
                  padding: EdgeInsets.all(isLandscape ? 16.0 : 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('Reto del Día', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                                ],
                              ),
                            ),
                            SizedBox(height: isLandscape ? 4 : 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'RETO DIARIO',
                                style: GoogleFonts.outfit(fontSize: isLandscape ? 22 : 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                              ),
                            ),
                            if (!isLandscape) Text(
                              'Resuelve el tablero único de hoy.',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: isLandscape ? 44 : 50, height: isLandscape ? 44 : 50,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: onDailyChallengeTap,
                          icon: Icon(isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded, color: Colors.white, size: isLandscape ? 24 : 28),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcademyCard(BuildContext context, dynamic theme, bool isDark, double padding, bool isLandscape) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HowToPlayScreen())),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: isLandscape ? 10 : 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.indigoAccent.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Text('🎓', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACADEMIA COSMOS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: isLandscape ? 13 : 15, color: isDark ? Colors.white : const Color(0xFF2B2B36))),
                      if (!isLandscape) Text('Domina las leyes de Numbra.', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: theme.primaryColor, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, dynamic theme, bool isDark, double padding, bool isLandscape) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StoreScreen())),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: isLandscape ? 10 : 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.store_rounded, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CENTRO DE SUMINISTROS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: isLandscape ? 13 : 15, color: isDark ? Colors.white : const Color(0xFF2B2B36))),
                      if (!isLandscape) Text('Adquiere pociones y boosters.', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: theme.primaryColor, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDifficultyCard(BuildContext context, WidgetRef ref, {required String title, required String icon, required int bestTime, required Color accentColor, required bool isDark, bool isLandscape = false}) {
    final min = (bestTime ~/ 60).toString().padLeft(2, '0');
    final sec = (bestTime % 60).toString().padLeft(2, '0');
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(gameProvider.notifier).startNewGame(title);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GameScreen()));
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(isLandscape ? 10.0 : 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(icon, style: TextStyle(fontSize: isLandscape ? 18 : 22)),
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                  ],
                ),
                SizedBox(height: isLandscape ? 8 : 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: isLandscape ? 13 : 15, letterSpacing: 1, color: isDark ? Colors.white : const Color(0xFF2B2B36))),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: isLandscape ? 8 : 10, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(bestTime > 0 ? '$min:$sec' : 'Sin Récord', style: GoogleFonts.outfit(fontSize: isLandscape ? 9 : 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
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
