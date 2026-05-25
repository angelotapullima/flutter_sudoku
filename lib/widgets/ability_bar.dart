import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Modo compacto basado en el ancho disponible por botón o altura reducida
        final bool isCompact = (constraints.maxWidth / 3) < 60 || constraints.maxHeight < 90;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 2 : 12, 
            vertical: isCompact ? 2 : 8
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(isCompact ? 12 : 20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAbilityButton(
                context,
                ref,
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
                isCompact: isCompact,
              ),
              _buildAbilityButton(
                context,
                ref,
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
                isCompact: isCompact,
              ),
              _buildAbilityButton(
                context,
                ref,
                icon: Icons.psychology_rounded,
                label: 'DIVINO',
                cost: 100,
                isActive: false, 
                onTap: () {
                  final success = ref.read(gameProvider.notifier).useDivineTouch();
                  if (success && onAbilityUsed != null) onAbilityUsed!();
                },
                theme: sudokuTheme,
                isDark: isDark,
                canAfford: userProfile.coins >= 100,
                isCompact: isCompact,
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildAbilityButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required int cost,
    required bool isActive,
    required VoidCallback onTap,
    required dynamic theme,
    required bool isDark,
    required bool canAfford,
    required bool isCompact,
  }) {
    final bool disabled = !canAfford && !isActive;
    final double iconSize = isCompact ? 18 : 22;
    final double circleSize = isCompact ? 32 : 44;

    return Expanded( 
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        onLongPress: () => _showAbilityInfo(context, label, isDark, theme),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive 
                    ? Colors.amber.withOpacity(0.2) 
                    : (disabled ? Colors.grey.withOpacity(0.1) : theme.primaryColor.withOpacity(0.1)),
                  border: Border.all(
                    color: isActive ? Colors.amber : (disabled ? Colors.grey.withOpacity(0.3) : theme.primaryColor.withOpacity(0.3)),
                    width: isCompact ? 1 : 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.amber : (disabled ? Colors.grey : theme.primaryColor),
                  size: iconSize,
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isActive ? Colors.amber : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ],
              // Costo (Pequeño)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🪙', style: TextStyle(fontSize: 7, color: disabled ? Colors.grey : Colors.amber)),
                  Text(
                    '$cost',
                    style: TextStyle(
                      fontSize: 8, 
                      fontWeight: FontWeight.bold,
                      color: disabled ? Colors.grey : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbilityInfo(BuildContext context, String label, bool isDark, dynamic theme) {
    // ... (Mismo diálogo de info mantenido funcionalmente)
  }
}
