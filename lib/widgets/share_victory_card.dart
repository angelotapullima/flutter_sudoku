import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class ShareVictoryCard extends StatelessWidget {
  final String time;
  final String difficulty;
  final int level;
  final SudokuTheme theme;
  final bool isDark;

  const ShareVictoryCard({
    super.key,
    required this.time,
    required this.difficulty,
    required this.level,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
          maxWidth: 350), // Un poco más estrecho para asegurar que quepa
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      ),
      child: Stack(
        children: [
          // Fondo Decorativo (Círculos difusos)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.08),
              ),
            ),
          ),

          // Contenido Principal
          Column(
            mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SUDOKU ARENA',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: theme.primaryColor,
                ),
              ),
              Text(
                'THE PREMIUM EXPERIENCE',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // Título de Victoria
              Text(
                '¡VICTORIA!',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A24),
                ),
              ),
              const SizedBox(height: 24),

              // Estadísticas Estilizadas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                      'TIEMPO', time, Icons.timer_outlined, theme, isDark),
                  _buildStat('NIVEL', '$level', Icons.auto_awesome_rounded,
                      theme, isDark),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: theme.primaryColor.withOpacity(0.2)),
                ),
                child: Text(
                  difficulty.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Footer
              Column(
                children: [
                  Icon(Icons.qr_code_2_rounded,
                      size: 30, color: Colors.grey.withOpacity(0.4)),
                  const SizedBox(height: 4),
                  const Text(
                    'DESCÁRGALO EN GOOGLE PLAY',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon,
      SudokuTheme theme, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: theme.primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white38 : Colors.black38,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.shareTechMono(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A24),
          ),
        ),
      ],
    );
  }
}
