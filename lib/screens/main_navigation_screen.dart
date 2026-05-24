import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/gamification_provider.dart';
import 'home_screen.dart';
import 'star_map_screen.dart';
import 'tournament_screen.dart';
import 'daily_challenge_screen.dart';
import 'stats_screen.dart';
import 'level_progress_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'clan_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StarMapScreen(),
    ClanScreen(),
    DailyChallengeScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final bool isGlobalDark = themeState.isDarkMode;
    
    // FORZAR MODO OSCURO EN LA PESTAÑA DE VIAJE (Inmersión Total)
    final bool isCurrentTabDark = isGlobalDark || _selectedIndex == 1;
    final userProfile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: isCurrentTabDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Header unificado superior común (Adaptativo)
                _buildUnifiedHeader(context, userProfile, sudokuTheme, isCurrentTabDark),
                
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

            // 3. Barra de navegación inferior flotante ultra-premium (Adaptativa)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildGlassmorphicNavBar(sudokuTheme, isCurrentTabDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicNavBar(dynamic sudokuTheme, bool isDark) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161E).withOpacity(0.95) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, 'Inicio', sudokuTheme, isDark),
              _buildNavItem(1, Icons.public_rounded, 'Viaje', sudokuTheme, isDark),
              _buildNavItem(2, Icons.shield_rounded, 'Logias', sudokuTheme, isDark),
              _buildNavItem(3, Icons.local_fire_department_rounded, 'Reto', sudokuTheme, isDark),
              _buildNavItem(4, Icons.person_rounded, 'Perfil', sudokuTheme, isDark),
            ],
          ),
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
    final String rango = userProfile.rankTitle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
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
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LevelProgressScreen()),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
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
            ),
          ),
          
          Row(
            children: [
              // Monedas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16161E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
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
              // Misiones
              GestureDetector(
                onTap: () => _showMissionsModal(context),
                child: Consumer(
                  builder: (context, ref, child) {
                    final gamification = ref.watch(gamificationProvider);
                    final completedCount = gamification.missions.where((m) => m.isCompleted).length;

                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF16161E) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black12,
                            ),
                          ),
                          child: Icon(
                            Icons.assignment_rounded,
                            size: 18,
                            color: isDark ? Colors.white70 : const Color(0xFF2B2B36),
                          ),
                        ),
                        if (completedCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$completedCount',
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                ),
              ),
              const SizedBox(width: 8),
              // Ajustes
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16161E) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black12,
                    ),
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

  Widget _buildNavItem(int index, IconData icon, String label, dynamic sudokuTheme, bool isDark) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? sudokuTheme.primaryColor
                : (isDark ? Colors.white38 : Colors.black38),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? sudokuTheme.primaryColor
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
          ),
        ],
      ),
    );
  }

  void _showMissionsModal(BuildContext context) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final gamification = ref.watch(gamificationProvider);
          final userProfile = ref.watch(profileProvider);
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            height: MediaQuery.of(context).size.height * (isLandscape ? 0.9 : 0.7),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TABLÓN DE MISIONES',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!userProfile.isRegistered)
                      Text(
                        'Modo Invitado',
                        style: TextStyle(color: Colors.amber[700], fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: gamification.isLoading
                      ? const Center(
                          child: SizedBox(
                            height: 60,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      : gamification.missions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay misiones disponibles.\nIntenta de nuevo más tarde.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: gamification.missions.length,
                              itemBuilder: (context, index) {
                                final mission = gamification.missions[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.blueAccent.withOpacity(0.1) : Colors.blueAccent.withOpacity(0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.stars_rounded, color: Colors.blueAccent, size: 24),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(mission.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            Text(mission.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                            const SizedBox(height: 8),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: mission.currentProgress / mission.requirementValue,
                                                backgroundColor: Colors.black12,
                                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        children: [
                                          Text('🪙 ${mission.rewardCoins}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                                          Text('✨ ${mission.rewardXp}', style: const TextStyle(fontSize: 10)),
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
