import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/tutorial_keys_provider.dart';

class AbilityBar extends ConsumerWidget {
  final VoidCallback? onAbilityUsed;

  const AbilityBar({
    super.key,
    this.onAbilityUsed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final isDark = ref.watch(themeProvider).isDarkMode;
    final userProfile = ref.watch(profileProvider);
    final keys = ref.read(tutorialKeysProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAbilityButton(
            context,
            ref,
            key: keys.visionKey,
            icon: Icons.auto_awesome_rounded,
            label: 'VISIÓN',
            cost: 50,
            isActive: gameState.isShowingErrors,
            onTap: () {
              final success = ref.read(gameProvider.notifier).useTrueVision();
              if (success && onAbilityUsed != null) onAbilityUsed!();
            },
            theme: sudokuTheme,
            isDark: isDark,
            canAfford: userProfile.coins >= 50,
            cooldownPercent: gameState.isShowingErrors ? 1.0 : 0.0,
          ),
          _buildAbilityButton(
            context,
            ref,
            key: keys.clockKey,
            icon: Icons.hourglass_bottom_rounded,
            label: 'RELOJ',
            cost: 30,
            isActive: gameState.isTimerFrozen,
            onTap: () {
              final success = ref.read(gameProvider.notifier).useFreezeTimer();
              if (success && onAbilityUsed != null) onAbilityUsed!();
            },
            theme: sudokuTheme,
            isDark: isDark,
            canAfford: userProfile.coins >= 30,
            cooldownPercent: gameState.isTimerFrozen ? 1.0 : 0.0,
          ),
          _buildAbilityButton(
            context,
            ref,
            key: keys.divineKey,
            icon: Icons.psychology_rounded,
            label: 'DIVINO',
            cost: 100,
            isActive: false, 
            onTap: () {
              final success = ref.read(gameProvider.notifier).useDivineTouch();
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No tienes suficientes monedas para el Toque Divino')),
                );
              } else {
                if (onAbilityUsed != null) onAbilityUsed!();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Sabiduría Ancestral aplicada! ✨')),
                );
              }
            },
            theme: sudokuTheme,
            isDark: isDark,
            canAfford: userProfile.coins >= 100,
            cooldownPercent: 0.0,
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityButton(
    BuildContext context,
    WidgetRef ref, {
    Key? key,
    required IconData icon,
    required String label,
    required int cost,
    required bool isActive,
    required VoidCallback onTap,
    required dynamic theme,
    required bool isDark,
    required bool canAfford,
    required double cooldownPercent,
  }) {
    final bool disabled = !canAfford && !isActive;

    return GestureDetector(
      key: key,
      onTap: disabled ? null : onTap,
      onLongPress: () => _showAbilityInfo(context, label, isDark, theme),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Círculo de fondo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive 
                    ? Colors.amber.withOpacity(0.2) 
                    : (disabled ? Colors.grey.withOpacity(0.1) : theme.primaryColor.withOpacity(0.1)),
                  border: Border.all(
                    color: isActive ? Colors.amber : (disabled ? Colors.grey.withOpacity(0.3) : theme.primaryColor.withOpacity(0.3)),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.amber : (disabled ? Colors.grey : theme.primaryColor),
                  size: 24,
                ),
              ),
              // Indicador de Cooldown (Círculo de progreso)
              if (cooldownPercent > 0)
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: cooldownPercent,
                    strokeWidth: 3,
                    color: Colors.amber,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              // Botón de Info Pequeño
              Positioned(
                right: -2,
                top: -2,
                child: GestureDetector(
                  onTap: () => _showAbilityInfo(context, label, isDark, theme),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                    ),
                    child: Icon(Icons.help_outline_rounded, size: 12, color: theme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: isActive ? Colors.amber : (disabled ? Colors.grey : (isDark ? Colors.white70 : Colors.black54)),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🪙',
                style: TextStyle(fontSize: 8, color: disabled ? Colors.grey : Colors.amber),
              ),
              Text(
                '$cost',
                style: TextStyle(
                  fontSize: 9, 
                  fontWeight: FontWeight.bold,
                  color: disabled ? Colors.grey : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAbilityInfo(BuildContext context, String label, bool isDark, dynamic theme) {
    String title = '';
    String description = '';
    String effect = '';
    IconData icon = Icons.info_outline;

    switch (label) {
      case 'VISIÓN':
        title = 'Visión Verdadera';
        icon = Icons.auto_awesome_rounded;
        description = 'Utiliza el poder de la lógica para detectar anomalías en el grid.';
        effect = 'Resalta en rojo suave todos los errores actuales durante 15 segundos. No pierdes vidas por los errores resaltados.';
        break;
      case 'RELOJ':
        title = 'Reloj Estelar';
        icon = Icons.hourglass_bottom_rounded;
        description = 'Manipula el flujo del tiempo a tu favor.';
        effect = 'Congela el cronómetro por 45 segundos. Ideal para partidas competitivas o situaciones críticas donde necesitas pensar sin presión.';
        break;
      case 'DIVINO':
        title = 'Toque Divino';
        icon = Icons.psychology_rounded;
        description = 'Una intervención directa de la sabiduría ancestral.';
        effect = 'Resuelve instantáneamente una de las casillas más difíciles del tablero para desbloquear tu progreso.';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.primaryColor, size: 48),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                effect,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ENTENDIDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
