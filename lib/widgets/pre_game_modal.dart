import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/game_provider.dart';
import '../screens/game_screen.dart';

/// Modal interactivo de preparación pre-partida y equipamiento de suministros RPG.
class PreGameModal extends ConsumerWidget {
  final String
      title; // "Fácil", "Medio", "Difícil", "Experto", "Reto Diario", "Nivel X"
  final String modeType; // "normal", "daily", "campaign"
  final int? campaignLevelNumber;
  final String? puzzleData;
  final String? solutionData;
  final String? bossName;
  final Map<String, dynamic>? modifiers;
  final int? seed; // Para el reto diario

  const PreGameModal({
    super.key,
    required this.title,
    required this.modeType,
    this.campaignLevelNumber,
    this.puzzleData,
    this.solutionData,
    this.bossName,
    this.modifiers,
    this.seed,
  });

  /// Abre el bottom sheet interactivo de preparación
  static void show(
    BuildContext context, {
    required String title,
    required String modeType,
    int? campaignLevelNumber,
    String? puzzleData,
    String? solutionData,
    String? bossName,
    Map<String, dynamic>? modifiers,
    int? seed,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.7),
      constraints: BoxConstraints(
        maxWidth: 550,
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      builder: (context) => PreGameModal(
        title: title,
        modeType: modeType,
        campaignLevelNumber: campaignLevelNumber,
        puzzleData: puzzleData,
        solutionData: solutionData,
        bossName: bossName,
        modifiers: modifiers,
        seed: seed,
      ),
    );
  }

  /// Calcula recompensas estelares según el modo o la dificultad
  Map<String, int> _calculateRewards() {
    if (modeType == 'campaign') {
      final isBoss = bossName != null && bossName!.isNotEmpty;
      return {
        'coins': isBoss ? 150 : 50,
        'xp': isBoss ? 500 : 200,
      };
    }
    if (modeType == 'daily') {
      return {'coins': 80, 'xp': 600};
    }
    switch (title) {
      case 'Fácil':
        return {'coins': 10, 'xp': 100};
      case 'Medio':
        return {'coins': 25, 'xp': 250};
      case 'Difícil':
        return {'coins': 50, 'xp': 500};
      case 'Experto':
        return {'coins': 100, 'xp': 1000};
      default:
        return {'coins': 20, 'xp': 150};
    }
  }

  void _buySupplyCharge(
      BuildContext context, WidgetRef ref, String powerType, int cost) {
    final profileNotifier = ref.read(profileProvider.notifier);
    final user = ref.read(profileProvider);

    if (user.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes suficientes S-Coins 🪙')),
      );
      return;
    }

    if (profileNotifier.deductCoins(cost)) {
      if (powerType == 'vision') {
        profileNotifier.updateProfile(
            user.copyWith(visionCharges: user.visionCharges + 1));
      } else if (powerType == 'freeze') {
        profileNotifier.updateProfile(
            user.copyWith(timeFreezeCharges: user.timeFreezeCharges + 1));
      } else if (powerType == 'divine') {
        profileNotifier.updateProfile(
            user.copyWith(divineTouchCharges: user.divineTouchCharges + 1));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Suministro adquirido y cargado en tu nave! 🚀')),
      );
    }
  }

  void _startGame(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop(); // Cerrar el modal de preparación

    final gameNotifier = ref.read(gameProvider.notifier);

    if (modeType == 'campaign') {
      gameNotifier.startCampaignGame(
        campaignLevelNumber!,
        puzzleData!,
        solutionData!,
        title,
        bossName,
        modifiers ?? {},
      );
    } else if (modeType == 'daily') {
      gameNotifier.startDailyChallengeGame(seed!, title);
    } else {
      gameNotifier.startNewGame(title);
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final rewards = _calculateRewards();

    // Validar si el nivel bloquea poderes tácticos
    final bool blockPowers = modifiers?['no_powers'] == true ||
        (bossName != null && bossName!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black12,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CABECERA: Resumen de Misión
            Text(
              'PREPARATIVOS DE VUELO',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: sudokuTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              modeType == 'campaign'
                  ? 'Misión Estelar: Nivel $campaignLevelNumber'
                  : (modeType == 'daily'
                      ? 'Misión: Reto Diario'
                      : 'Misión: Partida $title'),
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1C1C28),
              ),
            ),
            const SizedBox(height: 16),

            // RECOMPENSAS ESTIMADAS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark ? Colors.white.withOpacity(0.03) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(
                        '+${rewards['coins']} S-Coins',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFFFFB300),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: isDark ? Colors.white12 : Colors.black12),
                  Column(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(
                        '+${rewards['xp']} XP',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ALERTA DE JEFES / ANOMALÍAS
            if (blockPowers) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bossName != null && bossName!.isNotEmpty
                                ? 'COMBATE CONTRA JEFES: $bossName'
                                : 'ANOMALÍA DETECTADA',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Los campos de distorsión impiden el uso de habilidades tácticas en este grid. Dependerás puramente de tu intelecto.',
                            style: TextStyle(
                                fontSize: 11.5, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // SECCIÓN: Inventario / Suministros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'SUMINISTROS TÁCTICOS EN NAVE',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Saldo: 🪙 ${user.coins}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFB300),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. Cristal de Visión (True Vision)
            _buildSupplyCard(
              context: context,
              ref: ref,
              name: 'Cristal de Visión',
              desc: 'Resalta todos tus errores en el tablero por 10s.',
              icon: '🔮',
              stock: user.visionCharges,
              buyCost: 35,
              powerType: 'vision',
              sudokuTheme: sudokuTheme,
              isDark: isDark,
              disabled: blockPowers,
            ),

            // 2. Reloj Eterno (Time Freeze)
            _buildSupplyCard(
              context: context,
              ref: ref,
              name: 'Reloj Eterno',
              desc: 'Congela el cronómetro de la partida por 45s.',
              icon: '⏳',
              stock: user.timeFreezeCharges,
              buyCost: 25,
              powerType: 'freeze',
              sudokuTheme: sudokuTheme,
              isDark: isDark,
              disabled: blockPowers,
            ),

            // 3. Orbe de Purificación (Divine Touch)
            _buildSupplyCard(
              context: context,
              ref: ref,
              name: 'Orbe de Purificación',
              desc: 'Limpia errores y revela 3 casillas vacías.',
              icon: '✨',
              stock: user.divineTouchCharges,
              buyCost: 90,
              powerType: 'divine',
              sudokuTheme: sudokuTheme,
              isDark: isDark,
              disabled: blockPowers,
            ),

            const SizedBox(height: 28),

            // BOTÓN DE ACCIÓN: DESPEGAR
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _startGame(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sudokuTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 4,
                  shadowColor: sudokuTheme.primaryColor.withOpacity(0.3),
                ),
                child: Text(
                  'INICIAR MISIÓN 🚀',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyCard({
    required BuildContext context,
    required WidgetRef ref,
    required String name,
    required String desc,
    required String icon,
    required int stock,
    required int buyCost,
    required String powerType,
    required dynamic sudokuTheme,
    required bool isDark,
    required bool disabled,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: disabled ? 0.35 : 1.0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: disabled
                    ? Colors.grey.withOpacity(0.1)
                    : sudokuTheme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Opacity(
              opacity: disabled ? 0.4 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF1A1A24),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    disabled
                        ? 'Bloqueado en este sector'
                        : (stock > 0
                            ? 'Stock: $stock cargas'
                            : '⚠️ Sin cargas en almacén'),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: disabled
                          ? Colors.grey
                          : (stock > 0 ? Colors.green : Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (!disabled)
            ElevatedButton(
              onPressed: () =>
                  _buySupplyCharge(context, ref, powerType, buyCost),
              style: ElevatedButton.styleFrom(
                backgroundColor: sudokuTheme.primaryColor.withOpacity(0.1),
                foregroundColor: sudokuTheme.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              child: Text(
                '+1 (🪙$buyCost)',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
