import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';
import '../widgets/responsive_content_wrapper.dart';
import '../widgets/pre_game_modal.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  Timer? _countdownTimer;
  String _timeUntilMidnight = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final difference = midnight.difference(now);

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    setState(() {
      _timeUntilMidnight = '$hours:$minutes:$seconds';
    });
  }

  String _getDifficultyForWeekday(int weekday) {
    // Retorna la dificultad del reto diario según el día de la semana
    switch (weekday) {
      case 1: // Lunes
      case 2: // Martes
        return 'Fácil';
      case 3: // Miércoles
      case 4: // Jueves
        return 'Medio';
      case 5: // Viernes
      case 6: // Sábado
        return 'Difícil';
      case 7: // Domingo
      default:
        return 'Experto';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final userProfile = ref.watch(profileProvider);

    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);
    final hasCompletedToday =
        userProfile.completedDailyDates.contains(todayStr);

    // Calcular fechas de la semana actual (Lunes a Domingo)
    final int currentWeekday = today.weekday; // 1 = Lunes, 7 = Domingo
    final DateTime startOfWeek =
        today.subtract(Duration(days: currentWeekday - 1));
    final List<DateTime> weekDates =
        List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final List<String> weekDaysNames = [
      'Lun',
      'Mar',
      'Mié',
      'Jue',
      'Vie',
      'Sáb',
      'Dom'
    ];

    // Dificultad del reto de hoy
    final String todayDifficulty = _getDifficultyForWeekday(today.weekday);

    final bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      appBar: canPop
          ? AppBar(
              title: Text(
                'RETO DIARIO',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: isDark ? Colors.white : Colors.black87,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;

          // Detección precisa de Landscape Mobile para celular en horizontal
          final bool isLandscapeMobile = width > height && height < 500;
          final bool isDesktop = width > 800 && !isLandscapeMobile;

          if (isLandscapeMobile) {
            // --- DISEÑO EXCLUSIVO OPTIMIZADO PARA LANDSCAPE MOBILE ---
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna Izquierda: Racha y Reto del Día
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MI RACHA',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: sudokuTheme.primaryColor,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildStreakCard(userProfile.dailyStreak, isDark,
                              isLandscape: true),
                          const SizedBox(height: 16),
                          Text(
                            'RETO DEL DÍA',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: sudokuTheme.primaryColor,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildChallengeCard(hasCompletedToday,
                              todayDifficulty, today, sudokuTheme, isDark,
                              isLandscape: true),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Columna Derecha: Calendario Semanal y Reglas
                    Expanded(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CALENDARIO SEMANAL',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: sudokuTheme.primaryColor,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildWeeklyCalendar(
                              weekDates,
                              weekDaysNames,
                              todayStr,
                              userProfile.completedDailyDates,
                              sudokuTheme,
                              isDark,
                              isLandscape: true),
                          const SizedBox(height: 16),
                          Text(
                            'REGLAS Y PREMIOS',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: sudokuTheme.primaryColor,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildInfoSection(isDark, isLandscape: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (isDesktop) {
            // --- DISEÑO WEB PANORÁMICO DE ESCRITORIO ---
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ResponsiveContentWrapper(
                maxWidth:
                    1000, // Permitimos un poco más de ancho para las 2 columnas
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 28.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna Izquierda: Calendario Semanal y Tarjeta del Reto
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CALENDARIO SEMANAL',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: sudokuTheme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildWeeklyCalendar(
                                weekDates,
                                weekDaysNames,
                                todayStr,
                                userProfile.completedDailyDates,
                                sudokuTheme,
                                isDark),
                            const SizedBox(height: 32),
                            Text(
                              'RETO ESTELAR DEL DÍA',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: sudokuTheme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildChallengeCard(hasCompletedToday,
                                todayDifficulty, today, sudokuTheme, isDark),
                          ],
                        ),
                      ),

                      const SizedBox(width: 32),

                      // Columna Derecha: Racha de fuego y Reglas
                      Container(
                        width: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TU RACHA ACTUAL',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: sudokuTheme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStreakCard(userProfile.dailyStreak, isDark),
                            const SizedBox(height: 32),
                            Text(
                              'REGLAS Y RECOMPENSAS',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: sudokuTheme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoSection(isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // --- DISEÑO MÓVIL VERTICAL ORIGINAL ---
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveContentWrapper(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStreakCard(userProfile.dailyStreak, isDark),
                    const SizedBox(height: 24),
                    _buildWeeklyCalendar(weekDates, weekDaysNames, todayStr,
                        userProfile.completedDailyDates, sudokuTheme, isDark),
                    const SizedBox(height: 24),
                    _buildChallengeCard(hasCompletedToday, todayDifficulty,
                        today, sudokuTheme, isDark),
                    const SizedBox(height: 24),
                    _buildInfoSection(isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(int streak, bool isDark, {bool isLandscape = false}) {
    final bool hasStreak = streak > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLandscape ? 12 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isLandscape ? 16 : 28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasStreak
              ? [
                  const Color(0xFFFF416C),
                  const Color(0xFFFF4B2B)
                ] // Llama encendida (vibrante)
              : [Colors.grey[400]!, Colors.grey[600]!], // Racha apagada
        ),
        boxShadow: hasStreak
            ? [
                BoxShadow(
                  color: const Color(0xFFFF4B2B).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            right: isLandscape ? -5 : -10,
            bottom: isLandscape ? -10 : -20,
            child: Text(
              '🔥',
              style: TextStyle(
                fontSize: isLandscape ? 50 : 100,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 8 : 12,
                        vertical: isLandscape ? 4 : 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          hasStreak ? 'RACHA ACTIVA' : 'SIN RACHA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLandscape ? 8 : 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isLandscape ? 6 : 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$streak',
                    style: GoogleFonts.outfit(
                      fontSize: isLandscape ? 34 : 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  SizedBox(width: isLandscape ? 4 : 8),
                  Text(
                    streak == 1 ? 'día' : 'días',
                    style: GoogleFonts.outfit(
                      fontSize: isLandscape ? 12 : 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isLandscape ? 4 : 12),
              Text(
                hasStreak
                    ? (isLandscape
                        ? '¡Sigue así! Racha activa hoy.'
                        : '¡Sigue así! Tu mente se vuelve más ágil con cada día completado.')
                    : (isLandscape
                        ? 'Inicia tu racha diaria ahora.'
                        : 'Completa el Sudoku de hoy para iniciar tu racha y ganar grandes premios.'),
                style: TextStyle(
                  fontSize: isLandscape ? 10 : 13,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(
    List<DateTime> dates,
    List<String> names,
    String todayStr,
    List<String> completedDates,
    dynamic sudokuTheme,
    bool isDark, {
    bool isLandscape = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLandscape ? 12 : 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(isLandscape ? 16 : 24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso de la Semana',
            style: GoogleFonts.outfit(
              fontSize: isLandscape ? 13 : 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B2B36),
            ),
          ),
          SizedBox(height: isLandscape ? 8 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = dates[index];
              final dateStr = date.toIso8601String().substring(0, 10);
              final isCompleted = completedDates.contains(dateStr);
              final isToday = dateStr == todayStr;
              final isFuture = date.isAfter(DateTime.now());

              return Column(
                children: [
                  Text(
                    names[index],
                    style: TextStyle(
                      fontSize: isLandscape ? 9 : 11,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? sudokuTheme.primaryColor
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: isLandscape ? 4 : 8),
                  Container(
                    width: isLandscape ? 28 : 38,
                    height: isLandscape ? 28 : 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF4CAF50).withOpacity(0.15)
                          : (isToday
                              ? sudokuTheme.primaryColor.withOpacity(0.1)
                              : Colors.transparent),
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFF4CAF50)
                            : (isToday
                                ? sudokuTheme.primaryColor
                                : (isDark
                                    ? Colors.white10
                                    : Colors.grey[300]!)),
                        width: isToday ? 2.0 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check_rounded,
                              color: const Color(0xFF4CAF50),
                              size: isLandscape ? 14 : 20)
                          : (isToday
                              ? Text(
                                  '⭐',
                                  style: TextStyle(
                                    fontSize: isLandscape ? 11 : 14,
                                    color: sudokuTheme.primaryColor,
                                  ),
                                )
                              : Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isFuture
                                        ? Colors.grey[400]
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.grey[700]),
                                  ),
                                )),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    bool hasCompletedToday,
    String difficulty,
    DateTime today,
    dynamic sudokuTheme,
    bool isDark, {
    bool isLandscape = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLandscape ? 12 : 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(isLandscape ? 16 : 28),
        border: Border.all(
          color: hasCompletedToday
              ? const Color(0xFF4CAF50).withOpacity(0.4)
              : sudokuTheme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasCompletedToday
                    ? const Color(0xFF4CAF50)
                    : sudokuTheme.primaryColor)
                .withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('🧠 ',
                      style: TextStyle(fontSize: isLandscape ? 15 : 20)),
                  Text(
                    'Reto de Hoy',
                    style: GoogleFonts.outfit(
                      fontSize: isLandscape ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2B2B36),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 6 : 10,
                    vertical: isLandscape ? 2 : 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey[100]!,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Dificultad: $difficulty',
                  style: TextStyle(
                    fontSize: isLandscape ? 9 : 11,
                    fontWeight: FontWeight.bold,
                    color: sudokuTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isLandscape ? 6 : 16),
          Text(
            isLandscape
                ? 'Resuelve el Sudoku determinista único de hoy.'
                : 'Resuelve el Sudoku determinista del día y reclama las recompensas antes de que termine el tiempo.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          SizedBox(height: isLandscape ? 10 : 20),

          // Recompensas del día
          Row(
            children: [
              _buildRewardBadge('🪙 +50', Colors.amber[700]!, isDark,
                  isLandscape: isLandscape),
              SizedBox(width: isLandscape ? 8 : 12),
              _buildRewardBadge('⚡ +200 XP', sudokuTheme.primaryColor, isDark,
                  isLandscape: isLandscape),
            ],
          ),

          SizedBox(height: isLandscape ? 12 : 24),

          // Botón de acción e indicador de tiempo
          if (hasCompletedToday) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '¡Reto de Hoy Completado!',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Siguiente reto en: $_timeUntilMidnight',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    sudokuTheme.primaryColor,
                    sudokuTheme.accentColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: sudokuTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Semilla única basada en la fecha de hoy: AAAAMMDD
                    final int seed =
                        today.year * 10000 + today.month * 100 + today.day;

                    PreGameModal.show(
                      context,
                      title: difficulty,
                      modeType: 'daily',
                      seed: seed,
                    );
                  },
                  borderRadius: BorderRadius.circular(isLandscape ? 12 : 18),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: isLandscape ? 10 : 16),
                    child: Center(
                      child: Text(
                        isLandscape
                            ? 'JUGAR RETO AHORA'
                            : 'JUGAR RETO DIARIO (GRATIS)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: isLandscape ? 11 : 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Expira en: $_timeUntilMidnight',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildRewardBadge(String text, Color color, bool isDark,
      {bool isLandscape = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 8 : 14, vertical: isLandscape ? 4 : 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isLandscape ? 8 : 12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoSection(bool isDark, {bool isLandscape = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLandscape ? 10 : 20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E2E).withOpacity(0.5)
            : Colors.grey[50]!,
        borderRadius: BorderRadius.circular(isLandscape ? 16 : 24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🏆 ', style: TextStyle(fontSize: isLandscape ? 12 : 16)),
              Text(
                'Reglas de los Retos Diarios',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isLandscape ? 11 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: isLandscape ? 6 : 12),
          Text(
            '• El reto cambia a la medianoche todos los días.\n'
            '• La dificultad cambia según el día de la semana.\n'
            '• Completarlo desbloquea el check dorado.\n'
            '• Jugar todos los días mantiene tu llama de racha 🔥 activa.',
            style: TextStyle(
              fontSize: isLandscape ? 10 : 12,
              color: Colors.grey,
              height: isLandscape ? 1.3 : 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
