import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/responsive_content_wrapper.dart';
import '../utils/enums.dart';
import 'game_screen.dart';

class HowToPlayScreen extends ConsumerStatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  ConsumerState<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends ConsumerState<HowToPlayScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startGuidedLesson(TutorialScript script) {
    // TABLERO MAESTRO ESTÁTICO PARA EL TUTORIAL
    const String tutorialPuzzle =   '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
    const String tutorialSolution = '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

    // Iniciar el juego con datos fijos (Dificultad Tutorial)
    ref.read(gameProvider.notifier).startCampaignGame(0, tutorialPuzzle, tutorialSolution, GameDifficulty.tutorial.label);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(tutorialScript: script),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
      appBar: AppBar(
        title: Text(
          'ACADEMIA COSMOS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: sudokuTheme.primaryColor,
          labelColor: sudokuTheme.primaryColor,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
          tabs: const [
            Tab(text: 'LAS TRES LEYES', icon: Icon(Icons.gavel_rounded, size: 20)),
            Tab(text: 'MAESTRÍA (TIPS)', icon: Icon(Icons.psychology_rounded, size: 20)),
            Tab(text: 'PODER RPG', icon: Icon(Icons.auto_awesome_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLawsTab(sudokuTheme, isDark),
          _buildTipsTab(sudokuTheme, isDark),
          _buildRpgTab(sudokuTheme, isDark),
        ],
      ),
    );
  }

  // --- PESTAÑA 1: LAS TRES LEYES ---
  Widget _buildLawsTab(dynamic theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveContentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroductionCard(
              'EL CÓDIGO DE NUBRA',
              'El Sudoku se rige por tres leyes absolutas. Selecciona una ley para que el Maestro te enseñe su ejecución en el campo de batalla.',
              '⚖️',
              theme,
              isDark,
            ),
            const SizedBox(height: 32),
            _buildLessonCard(
              title: '1. LA LEY DEL HORIZONTE (FILAS)',
              desc: 'Ningún número puede repetirse en la misma línea horizontal.',
              icon: Icons.unfold_more_rounded,
              onTap: () => _startGuidedLesson(TutorialScript.lawRow),
              theme: theme,
              isDark: isDark,
            ),
            _buildLessonCard(
              title: '2. EL PILAR DEL DESTINO (COLUMNAS)',
              desc: 'Ninguna esencia puede duplicarse en la misma línea vertical.',
              icon: Icons.unfold_less_rounded,
              onTap: () => _startGuidedLesson(TutorialScript.lawCol),
              theme: theme,
              isDark: isDark,
            ),
            _buildLessonCard(
              title: '3. EL SECTOR GALÁCTICO (CAJAS)',
              desc: 'Cada cuadrante de 3x3 debe contener números del 1 al 9 sin repetir.',
              icon: Icons.grid_view_rounded,
              onTap: () => _startGuidedLesson(TutorialScript.lawBox),
              theme: theme,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  // --- PESTAÑA 2: MAESTRÍA (TIPS) ---
  Widget _buildTipsTab(dynamic theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveContentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('TÉCNICAS DE ARQUITECTO'),
            const SizedBox(height: 16),
            _buildLessonCard(
              title: 'EL MÉTODO DE EXCLUSIÓN',
              desc: 'Aprende a descartar números mirando las intersecciones galácticas.',
              icon: Icons.biotech_rounded,
              onTap: () => _startGuidedLesson(TutorialScript.masteryExclusion),
              theme: theme,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  // --- PESTAÑA 3: PODER RPG ---
  Widget _buildRpgTab(dynamic theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveContentWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('SUMINISTROS TÁCTICOS'),
            const SizedBox(height: 16),
            _buildLessonCard(
              title: 'VISIÓN VERDADERA',
              desc: 'Aprende a usar el cristal para revelar la verdad del grid.',
              icon: Icons.auto_awesome_rounded,
              onTap: () => _startGuidedLesson(TutorialScript.powerVision),
              theme: theme,
              isDark: isDark,
            ),
            _buildLessonCard(
              title: 'RELOJ ESTELAR',
              desc: 'Domina la manipulación del tiempo en torneos.',
              icon: Icons.hourglass_bottom_rounded,
              onTap: () => _startGuidedLesson(TutorialScript.powerClock),
              theme: theme,
              isDark: isDark,
            ),
            _buildLessonCard(
              title: 'TOQUE DIVINO',
              desc: 'La intervención definitiva para limpiar el tablero.',
              icon: Icons.psychology_rounded,
              onTap: () => _startGuidedLesson(TutorialScript.powerDivine),
              theme: theme,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionCard(String title, String desc, String icon, dynamic theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [theme.primaryColor.withOpacity(0.15), Colors.black] : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: theme.primaryColor)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 12.5, height: 1.5, color: isDark ? Colors.grey[300] : Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2));
  }

  Widget _buildLessonCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
    required dynamic theme,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: theme.primaryColor),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(desc, style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
        ),
        trailing: Icon(Icons.play_circle_fill_rounded, color: theme.primaryColor, size: 32),
      ),
    );
  }
}
