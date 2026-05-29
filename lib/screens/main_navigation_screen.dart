import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../features/missions/presentation/providers/mission_notifier.dart';
import 'home_screen.dart';
import 'star_map_screen.dart';
import 'daily_challenge_screen.dart';
import 'stats_screen.dart';
import 'level_progress_screen.dart';
import 'settings_screen.dart';
import 'clan_screen.dart';
import 'how_to_play_screen.dart';
import '../providers/tutorial_keys_provider.dart';
import '../utils/enums.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
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
    final bool isCurrentTabDark = isGlobalDark || _selectedIndex == 1;
    final userProfile = ref.watch(profileProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        // Lógica de detección de Layout Trifecta
        DeviceLayoutType layoutType;
        if (width > 1100) {
          layoutType = DeviceLayoutType.desktop;
        } else if (width > height && height < 600) {
          layoutType = DeviceLayoutType.landscapeMobile;
        } else {
          layoutType = DeviceLayoutType.portraitMobile;
        }

        if (layoutType == DeviceLayoutType.desktop) {
          return Scaffold(
            backgroundColor: isCurrentTabDark
                ? const Color(0xFF0B0B12)
                : const Color(0xFFF9F9FC),
            body: Row(
              children: [
                _buildDesktopSidebar(
                    userProfile, sudokuTheme, isGlobalDark, isCurrentTabDark),
                Expanded(
                    child: IndexedStack(
                        index: _selectedIndex, children: _screens)),
              ],
            ),
          );
        }

        if (layoutType == DeviceLayoutType.landscapeMobile) {
          return Scaffold(
            backgroundColor: isCurrentTabDark
                ? const Color(0xFF0B0B12)
                : const Color(0xFFF9F9FC),
            body: Row(
              children: [
                // Mini-Sidebar para Landscape Mobile para ganar espacio vertical
                _buildMiniSidebar(sudokuTheme, isCurrentTabDark),
                Expanded(
                  child: Column(
                    children: [
                      _buildCompactLandscapeHeader(
                          context, userProfile, sudokuTheme, isCurrentTabDark),
                      Expanded(
                          child: IndexedStack(
                              index: _selectedIndex, children: _screens)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Diseño Portrait Mobile (Original Protegido)
        return Scaffold(
          backgroundColor: isCurrentTabDark
              ? const Color(0xFF0B0B12)
              : const Color(0xFFF9F9FC),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildUnifiedHeader(
                        context, userProfile, sudokuTheme, isCurrentTabDark),
                    Expanded(
                        child: IndexedStack(
                            index: _selectedIndex, children: _screens)),
                    const SizedBox(height: 85),
                  ],
                ),
                Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildGlassmorphicNavBar(
                        sudokuTheme, isCurrentTabDark)),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- NUEVO SIDEBAR MINI PARA LANDSCAPE MOBILE ---
  Widget _buildMiniSidebar(dynamic theme, bool isDark) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131A) : Colors.white,
        border: Border(
            right: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildMiniNavItem(0, Icons.grid_view_rounded, theme, isDark),
          _buildMiniNavItem(1, Icons.public_rounded, theme, isDark),
          _buildMiniNavItem(2, Icons.shield_rounded, theme, isDark),
          _buildMiniNavItem(
              3, Icons.local_fire_department_rounded, theme, isDark),
          _buildMiniNavItem(4, Icons.person_rounded, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildMiniNavItem(
      int index, IconData icon, dynamic theme, bool isDark) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => setState(() => _selectedIndex = index),
      icon: Icon(icon,
          color: isSelected
              ? theme.primaryColor
              : (isDark ? Colors.white38 : Colors.black38)),
    );
  }

  // --- HEADER COMPACTO PARA LANDSCAPE (Evita Overflows) ---
  Widget _buildCompactLandscapeHeader(
      BuildContext context, dynamic profile, dynamic theme, bool isDark) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0B12) : Colors.white,
        border: Border(
            bottom:
                BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Numbra',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, color: theme.primaryColor)),
          Row(
            children: [
              Text('Nivel ${profile.level}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Text('🪙 ${profile.coins}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber)),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const HowToPlayScreen())),
                  icon: const Icon(Icons.school_outlined, size: 18)),
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsScreen())),
                  icon: const Icon(Icons.settings_outlined, size: 18)),
            ],
          ),
        ],
      ),
    );
  }

  // --- SIDEBAR DESKTOP ORIGINAL ---
  Widget _buildDesktopSidebar(dynamic userProfile, dynamic sudokuTheme,
      bool isGlobalDark, bool forceDark) {
    final bool isDark = forceDark;
    return Container(
      width: 270,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131A) : Colors.white,
        border: Border(
            right: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                width: 1.5)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text('SUDOKU ARENA',
                style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: sudokuTheme.primaryColor)),
            Text('SUDOKU ADVENTURE RPG',
                style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Colors.grey)),
            const SizedBox(height: 36),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.02)
                    : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 22,
                          backgroundColor: sudokuTheme.primaryColor,
                          child: Text('${userProfile.level}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nivel ${userProfile.level}',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87)),
                            Text(userProfile.rankTitle,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: sudokuTheme.primaryColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Colors.white12),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text('${userProfile.coins}',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87))
                      ]),
                      Row(
                        children: [
                          IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.school_outlined, size: 18),
                              color: isDark ? Colors.white70 : Colors.black54,
                              tooltip: 'Academia Cosmos',
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HowToPlayScreen()))),
                          const SizedBox(width: 8),
                          IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon:
                                  const Icon(Icons.settings_outlined, size: 18),
                              color: isDark ? Colors.white70 : Colors.black54,
                              tooltip: 'Ajustes',
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsScreen()))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView(
                children: [
                  _buildSidebarItem(0, Icons.grid_view_rounded, 'Inicio',
                      sudokuTheme, isDark),
                  _buildSidebarItem(1, Icons.public_rounded, 'Viaje Estelar',
                      sudokuTheme, isDark),
                  _buildSidebarItem(
                      2, Icons.shield_rounded, 'Logias', sudokuTheme, isDark),
                  _buildSidebarItem(3, Icons.local_fire_department_rounded,
                      'Desafío', sudokuTheme, isDark),
                  _buildSidebarItem(
                      4, Icons.person_rounded, 'Perfil', sudokuTheme, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label,
      dynamic sudokuTheme, bool isDark) {
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
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: GoogleFonts.outfit(
                        color: itemColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14))),
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
                            blurRadius: 4)
                      ])),
          ],
        ),
      ),
    );
  }

  // --- MOBILE COMPONENTS ---
  Widget _buildGlassmorphicNavBar(dynamic sudokuTheme, bool isDark) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF16161E).withOpacity(0.95)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 25,
              offset: const Offset(0, 10))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                  0, Icons.grid_view_rounded, 'Inicio', sudokuTheme, isDark),
              _buildNavItem(
                  1, Icons.public_rounded, 'Viaje', sudokuTheme, isDark),
              _buildNavItem(
                  2, Icons.shield_rounded, 'Logias', sudokuTheme, isDark),
              _buildNavItem(3, Icons.local_fire_department_rounded, 'Reto',
                  sudokuTheme, isDark),
              _buildNavItem(
                  4, Icons.person_rounded, 'Perfil', sudokuTheme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedHeader(
      BuildContext context, dynamic profile, dynamic theme, bool isDark) {
    final keys = ref.read(tutorialKeysProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
        border: Border(
            bottom: BorderSide(
                color:
                    isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
                width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            key: keys.levelKey,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LevelProgressScreen())),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.primaryColor,
                    child: Text('${profile.level}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16))),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nivel ${profile.level}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF2B2B36))),
                    Text(profile.rankTitle,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor.withOpacity(0.9))),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                key: keys.coinsKey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16161E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black12)),
                child: Row(children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text('${profile.coins}',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color:
                              isDark ? Colors.white : const Color(0xFF2B2B36)))
                ]),
              ),
              const SizedBox(width: 8),
              _buildHeaderIcon(Icons.assignment_rounded, isDark,
                  () => _showMissionsModal(context)),
              const SizedBox(width: 8),
              _buildHeaderIcon(
                  Icons.settings_outlined,
                  isDark,
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsScreen()))),
              const SizedBox(width: 8),
              _buildHeaderIcon(
                  Icons.school_outlined,
                  isDark,
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const HowToPlayScreen()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16161E) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
                color:
                    isDark ? Colors.white.withOpacity(0.1) : Colors.black12)),
        child: Icon(icon,
            size: 18, color: isDark ? Colors.white70 : const Color(0xFF2B2B36)),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label,
      dynamic sudokuTheme, bool isDark) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected
                  ? sudokuTheme.primaryColor
                  : (isDark ? Colors.white38 : Colors.black38),
              size: 26),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? sudokuTheme.primaryColor
                      : (isDark ? Colors.white38 : Colors.black38))),
        ],
      ),
    );
  }

  void _showMissionsModal(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final missionsState = ref.watch(missionsStateProvider);
          final sudokuTheme =
              ref.read(themeProvider.notifier).currentSudokuTheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            height:
                MediaQuery.of(context).size.height * (isLandscape ? 0.9 : 0.72),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A24),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      color: sudokuTheme.primaryColor,
                      onPressed: () => ref
                          .read(missionsStateProvider.notifier)
                          .fetchDailyMissions(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: missionsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : missionsState.errorMessage != null
                          ? Center(
                              child: Text(
                                missionsState.errorMessage!,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : missionsState.missionsList.isEmpty
                              ? Center(
                                  child: Text(
                                    '¡No hay misiones disponibles hoy!',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: missionsState.missionsList.length,
                                  itemBuilder: (context, index) {
                                    final mission =
                                        missionsState.missionsList[index];
                                    final progressPct =
                                        mission.requirementValue > 0
                                            ? (mission.currentProgress /
                                                    mission.requirementValue)
                                                .clamp(0.0, 1.0)
                                            : 0.0;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.04)
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(24),
                                        border: mission.isCompleted
                                            ? Border.all(
                                                color: Colors.green
                                                    .withOpacity(0.4),
                                                width: 1.5)
                                            : Border.all(
                                                color: Colors.transparent),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: mission.isCompleted
                                                      ? Colors.green
                                                          .withOpacity(0.15)
                                                      : sudokuTheme.primaryColor
                                                          .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  mission.isCompleted
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : Icons.star_rounded,
                                                  color: mission.isCompleted
                                                      ? Colors.green
                                                      : sudokuTheme
                                                          .primaryColor,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      mission.title,
                                                      style: GoogleFonts.outfit(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: isDark
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFF1A1A24),
                                                        decoration:
                                                            mission.isCompleted
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : null,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      mission.description,
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        color: isDark
                                                            ? Colors.white70
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Progreso: ${mission.currentProgress} / ${mission.requirementValue}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white60
                                                      : Colors.black54,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  if (mission.rewardCoins >
                                                      0) ...[
                                                    const Text('🪙',
                                                        style: TextStyle(
                                                            fontSize: 13)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '+${mission.rewardCoins}',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: const Color(
                                                            0xFFFFB300),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                  ],
                                                  if (mission.rewardXp > 0) ...[
                                                    const Text('⭐',
                                                        style: TextStyle(
                                                            fontSize: 13)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '+${mission.rewardXp} XP',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.blueAccent,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: LinearProgressIndicator(
                                              value: progressPct,
                                              backgroundColor: isDark
                                                  ? Colors.white12
                                                  : Colors.grey[300],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                mission.isCompleted
                                                    ? Colors.green
                                                    : sudokuTheme.primaryColor,
                                              ),
                                              minHeight: 7,
                                            ),
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
