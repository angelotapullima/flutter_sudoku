import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class RewardUnlockModal extends ConsumerWidget {
  final String title;
  final String description;
  final int coinsReward;
  final int xpReward;
  final String icon;
  final String type; // 'achievement' o 'level'

  const RewardUnlockModal({
    super.key,
    required this.title,
    required this.description,
    required this.coinsReward,
    required this.xpReward,
    this.icon = '🎉',
    required this.type,
  });

  /// Método utilitario estático para mostrar de forma limpia el modal
  static void show(
    BuildContext context, {
    required WidgetRef ref,
    required String title,
    required String description,
    required int coinsReward,
    required int xpReward,
    String icon = '🎉',
    required String type,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: RewardUnlockModal(
              title: title,
              description: description,
              coinsReward: coinsReward,
              xpReward: xpReward,
              icon: icon,
              type: type,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xEE1E1E2E) : const Color(0xEEFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: sudokuTheme.primaryColor.withOpacity(0.3),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: sudokuTheme.primaryColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono flotante con micro-sombra
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sudokuTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 16),
          // Subtítulo del tipo
          Text(
            type == 'level' ? '¡NUEVO NIVEL ALCANZADO!' : '¡LOGRO DESBLOQUEADO!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: sudokuTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          // Título principal
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Descripción
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Recompensas obtenidas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (coinsReward > 0)
                _buildRewardBadge(
                  icon: '🪙',
                  amount: '+$coinsReward',
                  label: 'S-Coins',
                  color: Colors.amber[700]!,
                  isDark: isDark,
                ),
              if (xpReward > 0)
                _buildRewardBadge(
                  icon: '✨',
                  amount: '+$xpReward',
                  label: 'XP',
                  color: sudokuTheme.primaryColor,
                  isDark: isDark,
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Botón aceptar con gradiente del acento
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: sudokuTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: const Text(
                '¡Genial, gracias!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBadge({
    required String icon,
    required String amount,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2B3C) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
