import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';

class ControlButtons extends ConsumerWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;

    final isDark = themeState.isDarkMode;
    final colorScheme = isDark ? Colors.white70 : Colors.black87;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mejor detección de espacio: Consideramos tanto ancho como alto
        final bool isCompact = (constraints.maxWidth / 4) < 60 || constraints.maxHeight < 80;

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: isCompact ? 2 : 8.0, 
            horizontal: 2.0
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.undo_rounded,
                label: 'Deshacer',
                onTap: () => ref.read(gameProvider.notifier).undo(),
                color: colorScheme,
                isCompact: isCompact,
              ),
              _buildActionButton(
                icon: Icons.cleaning_services_rounded,
                label: 'Borrar',
                onTap: () => ref.read(gameProvider.notifier).eraseCell(),
                color: colorScheme,
                isCompact: isCompact,
              ),
              _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'Notas',
                onTap: () => ref.read(gameProvider.notifier).toggleNotesMode(),
                color: gameState.isNotesMode
                    ? (isDark ? sudokuTheme.textColorDark : sudokuTheme.textColorLight)
                    : colorScheme,
                badge: gameState.isNotesMode ? 'ON' : null,
                badgeColor: isDark ? sudokuTheme.textColorDark : sudokuTheme.textColorLight,
                isCompact: isCompact,
              ),
              _buildActionButton(
                icon: Icons.lightbulb_rounded,
                label: 'Pista',
                onTap: () {
                  ref.read(gameProvider.notifier).useHint();
                },
                color: colorScheme,
                badge: gameState.hintsUsed < 3 ? '${3 - gameState.hintsUsed}' : '🪙35',
                badgeColor: gameState.hintsUsed < 3 ? Colors.green : Colors.amber[700]!,
                isCompact: isCompact,
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool isCompact,
    String? badge,
    Color? badgeColor,
  }) {
    return Expanded( 
      child: GestureDetector(
        onTap: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: isCompact ? 20 : 26, color: color),
                  if (badge != null)
                    Positioned(
                      top: isCompact ? -4 : -6,
                      right: isCompact ? -4 : -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: badgeColor ?? Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: isCompact ? 7 : 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
