import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../models/user_profile.dart';
import '../widgets/responsive_content_wrapper.dart';

class LevelProgressScreen extends ConsumerWidget {
  const LevelProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(profileProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;

    final double progress = userProfile.progressPercentage;
    final int nextLevelXp = userProfile.xpNeededForNextLevel;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      appBar: AppBar(
        title: Text('Mi Progreso', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: ResponsiveContentWrapper(
        maxWidth: 950,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 800;

            if (isDesktop) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna Izquierda: Nivel y Progreso
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildLevelHexagon(userProfile, sudokuTheme),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                  )
                                ],
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Experiencia Actual',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        '${userProfile.xp} / $nextLevelXp XP',
                                        style: TextStyle(
                                          color: sudokuTheme.primaryColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 12,
                                      backgroundColor: sudokuTheme.primaryColor.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(sudokuTheme.primaryColor),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Te faltan ${nextLevelXp - userProfile.xp} XP para el Nivel ${userProfile.level + 1}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Columna Derecha: Cómo funciona y Recompensas
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGamificationExplainer(isDark, sudokuTheme),
                            const SizedBox(height: 32),
                            _buildRewardsPreview(isDark, sudokuTheme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // MÓVIL ORIGINAL
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildLevelHexagon(userProfile, sudokuTheme),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey[200]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Experiencia Actual',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '${userProfile.xp} / $nextLevelXp XP',
                                style: TextStyle(
                                  color: sudokuTheme.primaryColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: sudokuTheme.primaryColor.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(sudokuTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Te faltan ${nextLevelXp - userProfile.xp} XP para el Nivel ${userProfile.level + 1}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildGamificationExplainer(isDark, sudokuTheme),
                    const SizedBox(height: 32),
                    _buildRewardsPreview(isDark, sudokuTheme),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelHexagon(UserProfile userProfile, SudokuTheme theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userProfile.rankEmoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              userProfile.rankTitle.toUpperCase(),
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            Text(
              '${userProfile.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGamificationExplainer(bool isDark, SudokuTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo funciona?',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          icon: Icons.extension_rounded,
          title: 'Resuelve Sudokus',
          desc: 'Gana XP al completar partidas. Cuanto mayor la dificultad, más experiencia obtendrás.',
          theme: theme,
          isDark: isDark,
        ),
        _buildStepItem(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Completa Misiones',
          desc: 'Las misiones diarias otorgan bonificaciones masivas de XP y Monedas (S-Coins).',
          theme: theme,
          isDark: isDark,
        ),
        _buildStepItem(
          icon: Icons.emoji_events_rounded,
          title: 'Logra Hazañas',
          desc: 'Desbloquea logros especiales por velocidad o precisión para catapultar tu nivel.',
          theme: theme,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String desc,
    required SudokuTheme theme,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsPreview(bool isDark, SudokuTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximas Recompensas',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildRewardCard(
          level: 'Nivel 5',
          reward: '500 S-Coins + Título "Analista"',
          icon: '💎',
          isDark: isDark,
        ),
        _buildRewardCard(
          level: 'Nivel 10',
          reward: 'Tema "Dorado Lujo" Gratis',
          icon: '🎁',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildRewardCard({required String level, required String reward, required String icon, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(reward, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
