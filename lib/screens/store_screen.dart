import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/registration_dialog.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = themeState.isDarkMode;

    final userProfile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
        title: Text(
          'TIENDA DE TEMAS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          // Monedas
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey[200]!,
                ),
              ),
              child: Row(
                children: [
                  const Text('🪙 ', style: TextStyle(fontSize: 14)),
                  Text(
                    '${userProfile.coins}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personaliza tu Experiencia',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Desbloquea paletas estéticas premium con tus S-Coins y personaliza el acento visual de todo el tablero.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Grid de temas
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: SudokuTheme.availableThemes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final theme = SudokuTheme.availableThemes[index];
                  final isPurchased = themeState.purchasedThemeIds.contains(theme.id);
                  final isActive = themeState.activeThemeId == theme.id;
                  final canBuy = userProfile.coins >= theme.price;

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isActive
                            ? theme.primaryColor
                            : isDark
                                ? Colors.white10
                                : Colors.grey[200]!,
                        width: isActive ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Icono y circulo de color
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.primaryColor.withOpacity(0.12),
                          child: Text(
                            theme.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        
                        // Información del tema
                        Column(
                          children: [
                            Text(
                              theme.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              theme.isPremium
                                  ? (isPurchased ? 'Desbloqueado' : 'Premium')
                                  : 'Inicial Gratuito',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.isPremium
                                    ? (isPurchased ? Colors.green : Colors.amber[700])
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        
                        // Botón de acción (Equipar / Comprar)
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!userProfile.isRegistered) {
                                RegistrationDialog.show(context);
                                return;
                              }
                              if (isPurchased) {
                                themeNotifier.changeActiveTheme(theme.id);
                              } else {
                                final success = themeNotifier.buyTheme(
                                  theme,
                                  userProfile.coins,
                                  (coinsLeft) => ref.read(profileProvider.notifier).deductCoins(theme.price),
                                );
                                if (success) {
                                  // Comprobar si al equipar el nuevo tema, tenemos 3 o más comprados
                                  // Leemos la lista actualizada directamente del provider notifier
                                  final totalPurchased = ref.read(themeProvider).purchasedThemeIds.length;
                                  if (totalPurchased >= 3) {
                                    ref.read(profileProvider.notifier).unlockAchievement('coleccionista_temas');
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive
                                  ? Colors.grey[400]
                                  : isPurchased
                                      ? theme.primaryColor
                                      : (canBuy ? Colors.amber[700] : Colors.grey[300]),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              elevation: isActive ? 0 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: FittedBox(
                              child: Text(
                                isActive
                                    ? 'Equipado'
                                    : isPurchased
                                        ? 'Equipar'
                                        : '🪙 ${theme.price}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
