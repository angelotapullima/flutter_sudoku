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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botón DESHACER
          _buildActionButton(
            icon: Icons.undo_rounded,
            label: 'Deshacer',
            onTap: () => ref.read(gameProvider.notifier).undo(),
            color: colorScheme,
          ),
          
          // Botón BORRAR
          _buildActionButton(
            icon: Icons.cleaning_services_rounded,
            label: 'Borrar',
            onTap: () => ref.read(gameProvider.notifier).eraseCell(),
            color: colorScheme,
          ),
          
          // Botón MODO NOTAS (LÁPIZ)
          _buildActionButton(
            icon: Icons.edit_rounded,
            label: 'Notas',
            onTap: () => ref.read(gameProvider.notifier).toggleNotesMode(),
            color: gameState.isNotesMode
                ? (isDark ? sudokuTheme.textColorDark : sudokuTheme.textColorLight)
                : colorScheme,
            badge: gameState.isNotesMode ? 'ON' : null,
            badgeColor: isDark ? sudokuTheme.textColorDark : sudokuTheme.textColorLight,
          ),
          
          // Botón PISTA
          _buildActionButton(
            icon: Icons.lightbulb_rounded,
            label: 'Pista',
            onTap: () {
              final result = ref.read(gameProvider.notifier).useHint();
              if (result == 'noSelection') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Selecciona una casilla vacía primero'),
                      ],
                    ),
                    backgroundColor: Colors.blueGrey,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (result == 'alreadyCorrect') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Selecciona una casilla vacía para usar la pista'),
                      ],
                    ),
                    backgroundColor: Colors.blueAccent,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (result == 'noCoins') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.monetization_on_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text('🪙 Monedas insuficientes. ¡Juega para ganar S-Coins!'),
                      ],
                    ),
                    backgroundColor: Colors.redAccent,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            color: colorScheme,
            // Primeras 3 pistas gratis (se muestra la cantidad de pistas restantes con un número), luego cuesta 35 monedas
            badge: gameState.hintsUsed < 3 ? '${3 - gameState.hintsUsed}' : '🪙35',
            badgeColor: gameState.hintsUsed < 3 ? Colors.green : Colors.amber[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    String? badge,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -8,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
