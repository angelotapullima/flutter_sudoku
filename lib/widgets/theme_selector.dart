import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/login_screen.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = themeNotifier.currentSudokuTheme;
    final profile = ref.watch(profileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Botón Claro/Oscuro con micro-interacción
          IconButton(
            onPressed: () => themeNotifier.toggleDarkMode(),
            icon: Icon(
              themeState.isDarkMode
                  ? Icons.wb_sunny_rounded
                  : Icons.nights_stay_rounded,
              color:
                  themeState.isDarkMode ? Colors.amber : Colors.blueGrey[800],
              size: 24,
            ),
            tooltip: themeState.isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: SudokuTheme.availableThemes.map((theme) {
                  final isPurchased =
                      themeState.purchasedThemeIds.contains(theme.id);
                  final isActive = themeState.activeThemeId == theme.id;

                  return GestureDetector(
                    onTap: () {
                      if (!profile.isRegistered) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                        return;
                      }
                      if (isPurchased) {
                        themeNotifier.changeActiveTheme(theme.id);
                      } else {
                        // Mostrar diálogo para comprar tema
                        _showPurchaseDialog(context, ref, theme);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? currentTheme.primaryColor
                              : isPurchased
                                  ? Colors.grey.withOpacity(0.3)
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Círculo de color
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                theme.primaryColor.withOpacity(0.9),
                            child: Text(
                              theme.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          // Si es premium y NO está comprado, dibujamos un candado
                          if (theme.isPremium && !isPurchased)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(
      BuildContext context, WidgetRef ref, SudokuTheme theme) {
    // Leemos el perfil para saber si tiene monedas suficientes
    final themeNotifier = ref.read(themeProvider.notifier);
    final profileNotifier = ref.read(profileProvider.notifier);
    final userProfile = ref.read(profileProvider);
    final canBuy = userProfile.coins >= theme.price;

    showDialog(
      context: context,
      builder: (context) {
        final dark = ref.read(themeProvider).isDarkMode;
        final themeColor = theme.primaryColor;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: dark ? const Color(0xFF1E1E2E) : Colors.white,
          title: Row(
            children: [
              Text(theme.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(
                'Desbloquear Tema',
                style: TextStyle(
                  color: dark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Deseas desbloquear el tema estético premium "${theme.name}"?',
                style: TextStyle(
                    color: dark ? Colors.grey[300] : Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precio:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        '🪙 ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${theme.price} S-Coins',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tus monedas:',
                    style: TextStyle(
                      color: dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    '🪙 ${userProfile.coins} S-Coins',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: canBuy ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                    color: dark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: canBuy
                  ? () {
                      final success = themeNotifier.buyTheme(
                        theme,
                        userProfile.coins,
                        (coinsLeft) => profileNotifier.deductCoins(theme.price),
                      );
                      Navigator.of(context).pop();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '¡Tema "${theme.name}" desbloqueado y equipado! 🎉'),
                            backgroundColor: themeColor,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Comprar'),
            ),
          ],
        );
      },
    );
  }
}
