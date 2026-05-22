import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';
import '../providers/storage_provider.dart';
import '../widgets/registration_dialog.dart';
import '../widgets/login_dialog.dart';
import '../services/api_service.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;

    final userProfile = ref.watch(profileProvider);
    final storage = ref.watch(storageServiceProvider);

    // Obtener rango basado en nivel
    String getUserRank(int level) {
      if (level <= 2) return 'Principiante de Lógica 🔰';
      if (level <= 5) return 'Analista de Cuadrículas 📊';
      if (level <= 9) return 'Estratega Numérico ⚡';
      if (level <= 14) return 'Maestro del Sudoku 🧠';
      return 'Leyenda Intelectual 👑';
    }

    // Emoji de avatar basado en nivel
    String getAvatarEmoji(int level) {
      if (level <= 2) return '🌱';
      if (level <= 5) return '🧠';
      if (level <= 9) return '⚡';
      if (level <= 14) return '🔮';
      return '👑';
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'PERFIL & LIGA',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 1.0,
            ),
          ),
          bottom: TabBar(
            indicatorColor: currentTheme.primaryColor,
            labelColor: isDark ? Colors.white : Colors.black87,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Mi Perfil'),
              Tab(text: 'Mis Récords'),
              Tab(text: 'Clasificación 🏆'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            // PESTAÑA 1: PERFIL & VITRINA
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Tarjeta de perfil Premium
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF1E1E2E), const Color(0xFF161622)]
                              : [Colors.white, const Color(0xFFF2F4F7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey[200]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar Premium
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: currentTheme.primaryColor.withOpacity(0.15),
                                child: Text(
                                  getAvatarEmoji(userProfile.level),
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Rango, nivel e información
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getUserRank(userProfile.level),
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: currentTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userProfile.isRegistered 
                                          ? userProfile.username 
                                          : 'Jugador Invitado',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Nivel ${userProfile.level} • Racha: ${userProfile.dailyStreak} días 🔥',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Barra de progreso de XP
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progreso de Inteligencia',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${userProfile.xp} / ${userProfile.xpNeededForNextLevel} XP',
                                    style: GoogleFonts.shareTechMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: currentTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LinearProgressIndicator(
                                    value: userProfile.progressPercentage,
                                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(currentTheme.primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          // Monedas y Logros totales
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('🪙', style: TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${userProfile.coins}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Monedas',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Container(height: 30, width: 1, color: isDark ? Colors.white10 : Colors.grey[300]),
                              Column(
                                children: [
                                  const Text('🏆', style: TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${userProfile.unlockedAchievements.length} / ${Achievement.allAchievements.length}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Medallas',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1.1 Sección de Autenticación en la Nube
                    _buildCloudSyncCard(context, ref, userProfile, currentTheme.primaryColor, isDark),
                    
                    const SizedBox(height: 24),
                    // Vitrina de Medallas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vitrina de Medallas',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Toca para ver requisitos',
                          style: TextStyle(
                            fontSize: 11,
                            color: currentTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Achievement.allAchievements.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final achievement = Achievement.allAchievements[index];
                        final isUnlocked = userProfile.unlockedAchievements.contains(achievement.id);

                        return GestureDetector(
                          onTap: () => _showAchievementDetail(context, achievement, isUnlocked, isDark),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isUnlocked
                                    ? currentTheme.primaryColor.withOpacity(0.35)
                                    : (isDark ? Colors.white10 : Colors.grey[200]!),
                                width: isUnlocked ? 1.8 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isUnlocked
                                      ? currentTheme.primaryColor.withOpacity(0.12)
                                      : (isDark ? Colors.white10 : Colors.grey[100]),
                                  child: Text(
                                    achievement.icon,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: isUnlocked ? null : Colors.grey.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  achievement.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isUnlocked ? 'Desbloqueada' : 'Bloqueada',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isUnlocked ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                    if (isUnlocked) ...[
                                      const SizedBox(width: 3),
                                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 10),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // PESTAÑA 2: RÉCORDS DE JUEGO (LOCALES)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiempos Récord',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tu desempeño lógico registrado en partidas ganadas completas.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsTable(storage, isDark, currentTheme.primaryColor),
                    const SizedBox(height: 28),
                    // Mensaje motivacional
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: currentTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: currentTheme.primaryColor.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Desafía tu Lógica!',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tu racha e inteligencia se sincronizan automáticamente con el ranking global. ¡Sigue jugando para escalar puestos!',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // PESTAÑA 3: CLASIFICACIÓN GLOBAL (LEADERBOARD BACKEND)
            const LeaderboardView(),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de Gestión de Sincronización en la Nube
  Widget _buildCloudSyncCard(
    BuildContext context,
    WidgetRef ref,
    UserProfile userProfile,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: userProfile.isRegistered
              ? Colors.green.withOpacity(0.3)
              : Colors.amber.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                userProfile.isRegistered 
                    ? Icons.cloud_done_rounded 
                    : Icons.cloud_off_rounded,
                color: userProfile.isRegistered ? Colors.green : Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                userProfile.isRegistered 
                    ? 'Sincronizado con la Nube' 
                    : 'Modo Local',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              if (userProfile.isRegistered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ONLINE',
                    style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userProfile.isRegistered
                ? 'Cuenta activa: ${userProfile.email}\nTu progreso (monedas, XP, récords, logros) está respaldado de forma segura en la nube.'
                : 'Tu progreso actual solo está guardado en este dispositivo. Regístrate o inicia sesión para competir en la Liga Global y asegurar tus datos.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (!userProfile.isRegistered)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => LoginDialog.show(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Iniciar Sesión',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => RegistrationDialog.show(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Lanzar sincronización manual
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sincronizando progreso... ☁️'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      await ref.read(profileProvider.notifier).refreshProfileFromServer();
                    },
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text('Sincronizar Ahora', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    // Diálogo de confirmación para cerrar sesión
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: isDark ? const Color(0xFF222232) : Colors.white,
                        title: const Text('¿Cerrar Sesión?', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: const Text(
                          'Tu progreso permanecerá seguro en la nube. Volverás al modo de juego local como invitado.',
                          style: TextStyle(fontSize: 13),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await ref.read(profileProvider.notifier).logout();
                            },
                            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  tooltip: 'Cerrar Sesión',
                ),
              ],
            )
        ],
      ),
    );
  }

  void _showAchievementDetail(
    BuildContext context,
    Achievement achievement,
    bool isUnlocked,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Text(achievement.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    achievement.title,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estado:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      isUnlocked ? 'Desbloqueado ✅' : 'Bloqueado 🔒',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recompensa:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      '🪙 +${achievement.rewardCoins} S-Coins  ⭐ +${achievement.rewardXp} XP',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTable(dynamic storage, bool isDark, Color accent) {
    const difficulties = ['Fácil', 'Medio', 'Difícil', 'Experto'];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[200]!,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.0),
          3: FlexColumnWidth(1.2),
        },
        border: TableBorder(
          horizontalInside: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[100]!,
            width: 1.0,
          ),
        ),
        children: [
          // Fila de encabezado
          TableRow(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252538) : Colors.grey[50],
            ),
            children: [
              _buildHeaderCell('Nivel'),
              _buildHeaderCell('Jugadas'),
              _buildHeaderCell('Ganadas'),
              _buildHeaderCell('Mejor T.'),
            ],
          ),
          // Filas de datos
          ...difficulties.map((diff) {
            final played = storage.getGamesPlayed(diff);
            final won = storage.getGamesWon(diff);
            final bestTime = storage.getBestTime(diff);

            final String bestTimeStr = bestTime == 0
                ? '-'
                : '${(bestTime ~/ 60).toString().padLeft(2, '0')}:${(bestTime % 60).toString().padLeft(2, '0')}';

            return TableRow(
              children: [
                _buildDataCell(diff, isBold: true),
                _buildDataCell('$played'),
                _buildDataCell('$won'),
                _buildDataCell(bestTimeStr, color: bestTime > 0 ? accent : null),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}

/// =========================================================================
/// VISTA DE CLASIFICACIÓN GLOBAL (LEADERBOARD VIEW INTERACTIVA)
/// =========================================================================
class LeaderboardView extends ConsumerStatefulWidget {
  const LeaderboardView({super.key});

  @override
  ConsumerState<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends ConsumerState<LeaderboardView> {
  String _activeTab = 'level'; // 'level' o 'speed'
  String _activeDifficulty = 'Fácil'; // 'Fácil', 'Medio', 'Difícil', 'Experto'
  
  List<dynamic> _leaderboardList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getLeaderboard(
      type: _activeTab,
      difficulty: _activeDifficulty,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _leaderboardList = result['leaderboard'] ?? [];
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Selector de tipo de clasificación
          Row(
            children: [
              _buildTypeSelectorButton(
                label: 'General (Nivel)',
                isActive: _activeTab == 'level',
                color: sudokuTheme.primaryColor,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _activeTab = 'level';
                  });
                  _fetchLeaderboard();
                },
              ),
              const SizedBox(width: 10),
              _buildTypeSelectorButton(
                label: 'Velocidad ⏱️',
                isActive: _activeTab == 'speed',
                color: sudokuTheme.primaryColor,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _activeTab = 'speed';
                  });
                  _fetchLeaderboard();
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: _fetchLeaderboard,
                icon: Icon(Icons.refresh_rounded, color: sudokuTheme.primaryColor),
                tooltip: 'Actualizar Tabla',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Selector de dificultad en pastillas de color si el tab es 'speed'
          if (_activeTab == 'speed') ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['Fácil', 'Medio', 'Difícil', 'Experto'].map((diff) {
                  final isSel = _activeDifficulty == diff;
                  Color diffColor = Colors.teal;
                  if (diff == 'Medio') diffColor = Colors.blueAccent;
                  if (diff == 'Difícil') diffColor = Colors.purpleAccent;
                  if (diff == 'Experto') diffColor = Colors.redAccent;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(diff, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      selected: isSel,
                      selectedColor: diffColor.withOpacity(0.2),
                      checkmarkColor: diffColor,
                      labelStyle: TextStyle(color: isSel ? diffColor : (isDark ? Colors.grey[400] : Colors.grey[700])),
                      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.grey[200],
                      side: BorderSide(color: isSel ? diffColor : Colors.transparent, width: 1.2),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _activeDifficulty = diff;
                          });
                          _fetchLeaderboard();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 3. Contenedor de la Tabla/Lista
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: sudokuTheme.primaryColor),
                  )
                : _errorMessage != null
                    ? _buildErrorPlaceholder()
                    : _leaderboardList.isEmpty
                        ? _buildEmptyPlaceholder()
                        : _buildLeaderboardList(isDark, sudokuTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelectorButton({
    required String label,
    required bool isActive,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive 
              ? color.withOpacity(0.15) 
              : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : (isDark ? Colors.white10 : Colors.grey[200]!),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isActive ? color : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📡', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          const Text(
            'Sin conexión con el ranking global',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'Verifica tu conexión de red o servidor.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchLeaderboard,
            child: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🏆', style: TextStyle(fontSize: 44)),
          SizedBox(height: 12),
          Text(
            '¡No hay marcas registradas aún!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Sé el primero en registrarte y resolver un Sudoku para liderar la tabla.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(bool isDark, Color accentColor) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _leaderboardList.length,
      itemBuilder: (context, index) {
        final player = _leaderboardList[index];
        final rank = index + 1;
        
        final username = player['username'] as String? ?? 'Desconocido';
        final level = player['level'] as int? ?? 1;

        // Formatear el récord según el tipo
        String recordStr = '';
        if (_activeTab == 'speed') {
          final bestTime = player['best_time'] as int? ?? 0;
          recordStr = '${(bestTime ~/ 60).toString().padLeft(2, '0')}:${(bestTime % 60).toString().padLeft(2, '0')} min';
        } else {
          final coins = player['coins'] as int? ?? 0;
          recordStr = '🪙 $coins';
        }

        // Estilos para los 3 primeros puestos
        Color? rankBgColor;
        Widget rankWidget;
        
        if (rank == 1) {
          rankBgColor = Colors.amber.withOpacity(0.12);
          rankWidget = const Text('👑', style: TextStyle(fontSize: 20));
        } else if (rank == 2) {
          rankBgColor = Colors.blueGrey.withOpacity(0.08);
          rankWidget = const Text('🥈', style: TextStyle(fontSize: 20));
        } else if (rank == 3) {
          rankBgColor = Colors.brown.withOpacity(0.08);
          rankWidget = const Text('🥉', style: TextStyle(fontSize: 20));
        } else {
          rankWidget = Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          );
        }

        // Emoji de avatar basado en nivel del rival
        String getAvatarEmoji(int level) {
          if (level <= 2) return '🌱';
          if (level <= 5) return '🧠';
          if (level <= 9) return '⚡';
          if (level <= 14) return '🔮';
          return '👑';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: rankBgColor ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: rank == 1
                  ? Colors.amber.withOpacity(0.35)
                  : (isDark ? Colors.white10 : Colors.grey[100]!),
              width: rank == 1 ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // 1. Posición
              Container(
                width: 32,
                alignment: Alignment.centerLeft,
                child: rankWidget,
              ),
              
              // 2. Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: accentColor.withOpacity(0.12),
                child: Text(
                  getAvatarEmoji(level),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),

              // 3. Username y Rango
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Nivel $level',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Marca récord del rival
              Text(
                recordStr,
                style: GoogleFonts.shareTechMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: rank == 1 ? Colors.amber[700] : accentColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
