import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/gamification_provider.dart';
import 'home_screen.dart';
import 'star_map_screen.dart';
import 'daily_challenge_screen.dart';
import 'stats_screen.dart';
import 'level_progress_screen.dart';
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
    
    // Forzar modo oscuro en la pestaña de Viaje (Inmersión Total)
    final bool isCurrentTabDark = isGlobalDark || _selectedIndex == 1;
    final userProfile = ref.watch(profileProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // Definir umbral de responsividad unificado (800px)
        final bool isDesktop = width > 800;

        if (isDesktop) {
          // Diseño Desktop: Sidebar lateral izquierdo + IndexedStack de contenido a la derecha
          return Scaffold(
            backgroundColor: isCurrentTabDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
            body: Row(
              children: [
                // 1. Sidebar lateral de escritorio
                _buildDesktopSidebar(userProfile, sudokuTheme, isGlobalDark),
                
                // 2. Área de visualización principal
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          );
        }

        // Diseño Móvil: Diseño original en columna con barra de navegación flotante
        return Scaffold(
          backgroundColor: isCurrentTabDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header común
                    _buildUnifiedHeader(context, userProfile, sudokuTheme, isCurrentTabDark),
                    
                    // Contenido
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _screens,
                      ),
                    ),
                    
                    // Margen inferior
                    const SizedBox(height: 85),
                  ],
                ),

                // Barra de navegación flotante
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
      },
    );
  }

  // --- COMPONENTES EXCLUSIVOS DE ESCRITORIO (SIDEBAR) ---

  Widget _buildDesktopSidebar(dynamic userProfile, dynamic sudokuTheme, bool isDark) {
    return Container(
      width: 270,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131A).withOpacity(0.9) : Colors.white.withOpacity(0.92),
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Logotipo Estilizado de Numbra
            Text(
              'NUMBRA',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: sudokuTheme.primaryColor,
              ),
            ),
            Text(
              'SUDOKU ADVENTURE RPG',
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 36),
            
            // Tarjeta de Perfil en el Sidebar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LevelProgressScreen()),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: sudokuTheme.primaryColor,
                            child: Text(
                              '${userProfile.level}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nivel ${userProfile.level}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  userProfile.rankTitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: sudokuTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Colors.white12),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '${userProfile.coins}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Tablón de Misiones
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.assignment_rounded, size: 18),
                            color: isDark ? Colors.white70 : Colors.black54,
                            tooltip: 'Misiones diarias',
                            onPressed: () => _showMissionsModal(context),
                          ),
                          const SizedBox(width: 10),
                          // Ajustes del Juego
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.settings_outlined, size: 18),
                            color: isDark ? Colors.white70 : Colors.black54,
                            tooltip: 'Ajustes',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            
            // Navegación Vertical
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSidebarItem(0, Icons.grid_view_rounded, 'Inicio', sudokuTheme, isDark),
                  _buildSidebarItem(1, Icons.public_rounded, 'Viaje Estelar', sudokuTheme, isDark),
                  _buildSidebarItem(2, Icons.shield_rounded, 'Logia / Clanes', sudokuTheme, isDark),
                  _buildSidebarItem(3, Icons.local_fire_department_rounded, 'Desafío Diario', sudokuTheme, isDark),
                  _buildSidebarItem(4, Icons.person_rounded, 'Estadísticas & Liga', sudokuTheme, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label, dynamic sudokuTheme, bool isDark) {
    final isSelected = _selectedIndex == index;
    final itemColor = isSelected 
        ? sudokuTheme.primaryColor 
        : (isDark ? Colors.white70 : Colors.black54);

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? sudokuTheme.primaryColor.withOpacity(isDark ? 0.12 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  color: itemColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sudokuTheme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: sudokuTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES EXCLUSIVOS DE MÓVIL (NAVBAR Y HEADER) ---

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

  // --- MODAL DE MISIONES (COMÚN) ---

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
