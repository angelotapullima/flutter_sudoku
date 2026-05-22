import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Configuraciones',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const Center(child: SettingsDialog());
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(
            opacity: anim.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xE61E1E2E) : const Color(0xE6FFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabecera del Diálogo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32), // Balanceador
                  Text(
                    'Ajustes de Juego',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2B2B36),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Colors.white24),
              const SizedBox(height: 16),

              // Lista de Switches scrollable
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSettingSwitch(
                        icon: Icons.timer_outlined,
                        title: 'Mostrar Cronómetro',
                        subtitle: 'Visualiza el tiempo transcurrido en tu partida actual.',
                        value: settings.showTimer,
                        onChanged: (val) => settingsNotifier.toggleShowTimer(),
                        activeColor: sudokuTheme.primaryColor,
                        isDark: isDark,
                      ),
                      _buildSettingSwitch(
                        icon: Icons.dangerous_outlined,
                        title: 'Límite de 3 Errores',
                        subtitle: 'Si cometes 3 errores en la partida perderás el juego.',
                        value: settings.enableErrorLimit,
                        onChanged: (val) => settingsNotifier.toggleEnableErrorLimit(),
                        activeColor: sudokuTheme.primaryColor,
                        isDark: isDark,
                      ),
                      _buildSettingSwitch(
                        icon: Icons.grid_on_rounded,
                        title: 'Resaltado Inteligente',
                        subtitle: 'Destaca fila, columna y números similares al seleccionar.',
                        value: settings.enableHighlighting,
                        onChanged: (val) => settingsNotifier.toggleEnableHighlighting(),
                        activeColor: sudokuTheme.primaryColor,
                        isDark: isDark,
                      ),
                      _buildSettingSwitch(
                        icon: Icons.filter_alt_outlined,
                        title: 'Números Restantes',
                        subtitle: 'Muestra en el teclado cuántos números faltan colocar.',
                        value: settings.showRemainingNumbers,
                        onChanged: (val) => settingsNotifier.toggleShowRemainingNumbers(),
                        activeColor: sudokuTheme.primaryColor,
                        isDark: isDark,
                      ),
                      _buildSettingSwitch(
                        icon: Icons.vibration_rounded,
                        title: 'Vibración Háptica',
                        subtitle: 'El teléfono vibrará levemente al cometer un error.',
                        value: settings.enableVibration,
                        onChanged: (val) => settingsNotifier.toggleEnableVibration(),
                        activeColor: sudokuTheme.primaryColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Botón de Confirmación
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sudokuTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Listo',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? activeColor.withOpacity(0.15) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: value ? activeColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B2B36),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.4),
            inactiveThumbColor: isDark ? Colors.grey[600] : Colors.grey[400],
            inactiveTrackColor: isDark ? Colors.white10 : Colors.black12,
          ),
        ],
      ),
    );
  }
}
