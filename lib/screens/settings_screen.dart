import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;
    final userProfile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
      appBar: AppBar(
        title: Text('Ajustes', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN DE CUENTA
            _buildSectionTitle('Cuenta'),
            _buildAccountCard(context, ref, userProfile, sudokuTheme, isDark),
            const SizedBox(height: 32),

            // SECCIÓN DE JUEGO
            _buildSectionTitle('Preferencias de Juego'),
            _buildSettingsGroup([
              _buildSettingSwitch(
                icon: Icons.timer_outlined,
                title: 'Mostrar Cronómetro',
                subtitle: 'Visualiza el tiempo transcurrido.',
                value: settings.showTimer,
                onChanged: (val) => ref.read(settingsProvider.notifier).toggleShowTimer(),
                theme: sudokuTheme,
              ),
              _buildSettingSwitch(
                icon: Icons.numbers_rounded,
                title: 'Números Restantes',
                subtitle: 'Muestra cuántos números faltan colocar.',
                value: settings.showRemainingNumbers,
                onChanged: (val) => ref.read(settingsProvider.notifier).toggleShowRemainingNumbers(),
                theme: sudokuTheme,
              ),
              _buildSettingSwitch(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Resaltado Inteligente',
                subtitle: 'Resaltar números iguales y errores.',
                value: settings.enableHighlighting,
                onChanged: (val) => ref.read(settingsProvider.notifier).toggleEnableHighlighting(),
                theme: sudokuTheme,
              ),
              _buildSettingSwitch(
                icon: Icons.dangerous_outlined,
                title: 'Límite de Errores',
                subtitle: 'Perder tras cometer 3 errores.',
                value: settings.enableErrorLimit,
                onChanged: (val) => ref.read(settingsProvider.notifier).toggleEnableErrorLimit(),
                theme: sudokuTheme,
              ),
              _buildSettingSwitch(
                icon: Icons.vibration_rounded,
                title: 'Vibración Háptica',
                subtitle: 'Respuesta táctil al jugar.',
                value: settings.enableVibration,
                onChanged: (val) => ref.read(settingsProvider.notifier).toggleEnableVibration(),
                theme: sudokuTheme,
              ),
            ], isDark),

            const SizedBox(height: 32),

            // SECCIÓN DE APARIENCIA
            _buildSectionTitle('Personalización'),
            _buildSettingsGroup([
              _buildSettingSwitch(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                title: 'Modo Oscuro',
                subtitle: 'Cambia el brillo de la interfaz.',
                value: isDark,
                onChanged: (val) => ref.read(themeProvider.notifier).toggleDarkMode(),
                theme: sudokuTheme,
              ),
            ], isDark),

            const SizedBox(height: 40),
            // Footer
            Center(
              child: Text(
                'Numbra v1.0.0',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: Colors.grey[500],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, WidgetRef ref, UserProfile user, dynamic theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!user.isRegistered) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    user.isRegistered ? Icons.person_rounded : Icons.person_add_rounded,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.isRegistered ? user.username : 'Usuario Invitado',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.isRegistered ? user.email : 'Toca para sincronizar progreso',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (user.isRegistered)
                  IconButton(
                    onPressed: () => _showLogoutDialog(context, ref, isDark),
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  )
                else
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required dynamic theme,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: theme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      activeColor: theme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('Tu progreso en la nube se mantendrá seguro.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(profileProvider.notifier).logout();
              Navigator.pop(context);
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
