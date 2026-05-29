import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../features/store/presentation/providers/store_notifier.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  Future<void> _handlePurchase({
    required String itemId,
    required int cost,
    required String type,
    required String name,
  }) async {
    await ref.read(storeNotifierProvider.notifier).purchaseItem(
          itemId: itemId,
          cost: cost,
          type: type,
          name: name,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileProvider);
    final theme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final isDark = ref.watch(themeProvider).isDarkMode;
    final storeState = ref.watch(storeNotifierProvider);

    ref.listen<StoreState>(storeNotifierProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
        ref.read(storeNotifierProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(storeNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
      appBar: AppBar(
        title: Text('CENTRO DE SUMINISTROS',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '🪙 ${user.coins}',
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                    'CONSUMIBLES TÁCTICOS', 'Pociones para tu viaje lógico'),
                const SizedBox(height: 16),
                _buildStoreItem(
                  id: 'vision_pack',
                  name: 'Cristal de Visión (x5)',
                  desc: 'Detecta errores sin perder vidas.',
                  icon: '🔮',
                  cost: 150,
                  type: 'consumable',
                  theme: theme,
                  isDark: isDark,
                  currentStock: 'En nave: ${user.visionCharges} cargas',
                ),
                _buildStoreItem(
                  id: 'time_pack',
                  name: 'Reloj Eterno (x3)',
                  desc: 'Congela el tiempo por 45s.',
                  icon: '⏳',
                  cost: 80,
                  type: 'consumable',
                  theme: theme,
                  isDark: isDark,
                  currentStock: 'En nave: ${user.timeFreezeCharges} cargas',
                ),
                _buildStoreItem(
                  id: 'divine_pack',
                  name: 'Orbe de Purificación',
                  desc: 'Limpia errores y revela 3 números.',
                  icon: '✨',
                  cost: 100,
                  type: 'consumable',
                  theme: theme,
                  isDark: isDark,
                  currentStock: 'En nave: ${user.divineTouchCharges} cargas',
                ),

                const SizedBox(height: 32),
                _buildSectionHeader('IMPULSORES', 'Sube de rango más rápido'),
                const SizedBox(height: 16),
                _buildStoreItem(
                  id: 'xp_boost_24h',
                  name: 'Doble XP (24 Horas)',
                  desc: 'Gana x2 de experiencia en todo.',
                  icon: '📜',
                  cost: 300,
                  type: 'boost',
                  theme: theme,
                  isDark: isDark,
                ),

                const SizedBox(height: 32),
                _buildSectionHeader(
                    'ESTÉTICA NEO-CYBER', 'Personaliza tu identidad'),
                const SizedBox(height: 16),
                _buildStoreItem(
                  id: 'border_neon_blue',
                  name: 'Marco de Aura Cian',
                  desc: 'Un brillo eléctrico para tu perfil.',
                  icon: '⭕',
                  cost: 500,
                  type: 'border',
                  theme: theme,
                  isDark: isDark,
                ),
                _buildStoreItem(
                  id: 'border_golden_king',
                  name: 'Marco Real Dorado',
                  desc: 'Solo para los maestros del grid.',
                  icon: '🔱',
                  cost: 1200,
                  type: 'border',
                  theme: theme,
                  isDark: isDark,
                ),
                const SizedBox(height: 100), // Espacio para el navbar
              ],
            ),
          ),
          if (storeState.isLoading)
            Positioned.fill(
              child: Container(
                color: isDark
                    ? Colors.black.withOpacity(0.6)
                    : Colors.black.withOpacity(0.35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: theme.primaryColor,
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Procesando Adquisición...',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A24),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Conectando con el Banco Estelar',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.blueAccent),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildStoreItem({
    required String id,
    required String name,
    required String desc,
    required String icon,
    required int cost,
    required String type,
    required dynamic theme,
    required bool isDark,
    String? currentStock,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child:
              Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
        ),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (currentStock != null) ...[
              const SizedBox(height: 4),
              Text(
                currentStock,
                style: GoogleFonts.outfit(
                  color: isDark
                      ? const Color(0xFF81C784)
                      : const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
            ],
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () =>
              _handlePurchase(itemId: id, cost: cost, type: type, name: name),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text('🪙 $cost',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}
