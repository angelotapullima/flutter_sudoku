import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/gamification_provider.dart';
import '../widgets/settings_dialog.dart';
import 'home_screen.dart';
import 'tournament_screen.dart';
import 'daily_challenge_screen.dart';
import 'stats_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TournamentScreen(),
    DailyChallengeScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;
    final userProfile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Header unificado superior común para todas las vistas
                _buildUnifiedHeader(context, userProfile, sudokuTheme, isDark),
                
                // 2. Pantalla seleccionada activa
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
                
                // Espacio inferior de margen para que la barra de navegación flotante no tape contenidos
                const SizedBox(height: 85),
              ],
            ),

            // 3. Barra de navegación inferior flotante ultra-premium (Glassmorphic)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildGlassmorphicNavBar(sudokuTheme, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedHeader(
    BuildContext context,
    dynamic userProfile,
    dynamic sudokuTheme,
    bool isDark,
  ) {
    // Determinar rango dinámico
    String rango = 'Aprendiz';
    if (userProfile.level >= 6 && userProfile.level <= 10) {
      rango = 'Analista';
    } else if (userProfile.level >= 11) {
      rango = 'Gran Maestro';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nivel y Rango
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2B2B36),
                    ),
                  ),
                  Text(
                    rango,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: sudokuTheme.primaryColor.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // S-Coins (Monedas) y Ajustes
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🪙 ', style: TextStyle(fontSize: 15)),
                    Text(
                      '${userProfile.coins}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF2B2B36),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Indicador de Misiones
              Consumer(
                builder: (context, ref, child) {
                  final gamification = ref.watch(gamificationProvider);
                  final completedCount = gamification.missions.where((m) => m.isCompleted).length;
                  
                  return GestureDetector(
                    onTap: () => _showMissionsModal(context),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!,
                            ),
                          ),
                          child: Icon(
                            Icons.assignment_turned_in_rounded,
                            size: 20,
                            color: completedCount > 0 ? Colors.green : (isDark ? Colors.white38 : Colors.grey),
                          ),
                        ),
                        if (completedCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                              child: Text(
                                '$completedCount',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => SettingsDialog.show(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: isDark ? Colors.white70 : const Color(0xFF2B2B36),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicNavBar(dynamic sudokuTheme, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E).withOpacity(0.85) : Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_on_rounded, 'Sudoku', sudokuTheme),
              _buildNavItem(1, Icons.emoji_events_rounded, 'Liga', sudokuTheme),
              _buildNavItem(2, Icons.offline_bolt_rounded, 'Reto', sudokuTheme),
              _buildNavItem(3, Icons.person_rounded, 'Perfil', sudokuTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, dynamic sudokuTheme) {
    final isSelected = _selectedIndex == index;
    final activeColor = sudokuTheme.primaryColor;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: activeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.grey[500],
              size: isSelected ? 24 : 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMissionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final gamification = ref.watch(gamificationProvider);
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'MISIONES DIARIAS',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: gamification.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: gamification.missions.length,
                          itemBuilder: (context, index) {
                            final mission = gamification.missions[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: mission.isCompleted ? Colors.green : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mission.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          mission.description,
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: mission.requirementValue > 0 ? (mission.currentProgress / mission.requirementValue) : 0,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            mission.isCompleted ? Colors.green : Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    children: [
                                      Text('🪙 +${mission.rewardCoins}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      Text('⭐ +${mission.rewardXp}', style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
