import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';
import '../providers/storage_provider.dart';
import '../services/api_service.dart';
import '../utils/enums.dart';
import 'login_screen.dart';
import '../widgets/responsive_content_wrapper.dart';

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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;

            // Detección de Layout Trifecta
            DeviceLayoutType layoutType;
            if (width > 1100) {
              layoutType = DeviceLayoutType.desktop;
            } else if (width > height && height < 600) {
              layoutType = DeviceLayoutType.landscapeMobile;
            } else {
              layoutType = DeviceLayoutType.portraitMobile;
            }

            final bool isDesktop = layoutType == DeviceLayoutType.desktop;
            final bool isLandscape = layoutType == DeviceLayoutType.landscapeMobile;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverAppBar(
                      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
                      elevation: 0,
                      floating: true,
                      pinned: true,
                      snap: true,
                      automaticallyImplyLeading: false,
                      centerTitle: false,
                      title: Text(
                        'PERFIL & LIGA',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: isLandscape ? 16 : 18,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1.0,
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(49),
                        child: Container(
                          height: 49,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                          ),
                          child: TabBar(
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
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // PESTAÑA 1: PERFIL & VITRINA
                  _buildTabContentWrapper(
                    child: Builder(
                      builder: (context) {
                        final String userRank = getUserRank(userProfile.level);
                        final String avatarEmoji = getAvatarEmoji(userProfile.level);

                        if (isDesktop || isLandscape) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: isLandscape ? 16.0 : 24.0, horizontal: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: isLandscape ? 5 : 4,
                                  child: Column(
                                    children: [
                                      _buildProfileCard(userProfile, currentTheme, isDark, userRank, avatarEmoji, isLandscape: isLandscape),
                                      const SizedBox(height: 16),
                                      _buildCloudSyncCard(context, ref, userProfile, currentTheme.primaryColor, isDark, isLandscape: isLandscape),
                                    ],
                                  ),
                                ),
                                SizedBox(width: isLandscape ? 16 : 28),
                                Expanded(
                                  flex: isLandscape ? 7 : 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildVitrinaHeader(isDark, currentTheme, isLandscape: isLandscape),
                                      const SizedBox(height: 12),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: Achievement.allAchievements.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isLandscape ? 4 : 3,
                                          crossAxisSpacing: isLandscape ? 8 : 12,
                                          mainAxisSpacing: isLandscape ? 8 : 12,
                                          childAspectRatio: 1.0,
                                        ),
                                        itemBuilder: (context, index) {
                                          final achievement = Achievement.allAchievements[index];
                                          final isUnlocked = userProfile.unlockedAchievements.contains(achievement.id);
                                          return _buildAchievementTile(context, achievement, isUnlocked, isDark, currentTheme, isLandscape: isLandscape);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildProfileCard(userProfile, currentTheme, isDark, userRank, avatarEmoji),
                              const SizedBox(height: 20),
                              _buildCloudSyncCard(context, ref, userProfile, currentTheme.primaryColor, isDark),
                              const SizedBox(height: 24),
                              _buildVitrinaHeader(isDark, currentTheme),
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
                                  return _buildAchievementTile(context, achievement, isUnlocked, isDark, currentTheme);
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // PESTAÑA 2: RÉCORDS DE JUEGO
                  _buildTabContentWrapper(
                    child: Builder(
                      builder: (context) {
                        if (isDesktop || isLandscape) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: isLandscape ? 16.0 : 24.0, horizontal: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildRecordsHeader(isDark, isLandscape: isLandscape),
                                      const SizedBox(height: 16),
                                      _buildStatsTable(storage, isDark, currentTheme.primaryColor, isLandscape: isLandscape),
                                    ],
                                  ),
                                ),
                                SizedBox(width: isLandscape ? 16 : 28),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: isLandscape ? 0 : 38),
                                      _buildRecordsMotivationCard(currentTheme, isDark, isLandscape: isLandscape),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRecordsHeader(isDark),
                              const SizedBox(height: 16),
                              _buildStatsTable(storage, isDark, currentTheme.primaryColor),
                              const SizedBox(height: 28),
                              _buildRecordsMotivationCard(currentTheme, isDark),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // PESTAÑA 3: CLASIFICACIÓN
                  _buildTabContentWrapper(child: LeaderboardView(isLandscape: isLandscape, isDesktop: isDesktop)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabContentWrapper({required Widget child}) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: ResponsiveContentWrapper(
                maxWidth: 1000,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVitrinaHeader(bool isDark, dynamic currentTheme, {bool isLandscape = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Vitrina de Medallas',
          style: GoogleFonts.outfit(
            fontSize: isLandscape ? 15 : 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          isLandscape ? 'Requisitos' : 'Toca para requisitos',
          style: TextStyle(
            fontSize: 10,
            color: currentTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsHeader(bool isDark, {bool isLandscape = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiempos Récord',
          style: GoogleFonts.outfit(
            fontSize: isLandscape ? 15 : 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (!isLandscape) ...[
          const SizedBox(height: 6),
          Text(
            'Tu desempeño lógico registrado en partidas ganadas.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  /// Tarjeta de Gestión de Sincronización
  Widget _buildCloudSyncCard(BuildContext context, WidgetRef ref, UserProfile userProfile, Color primaryColor, bool isDark, {bool isLandscape = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLandscape ? 12 : 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(isLandscape ? 16 : 24),
        border: Border.all(
          color: userProfile.isRegistered ? Colors.green.withOpacity(0.3) : Colors.amber.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(userProfile.isRegistered ? Icons.cloud_done_rounded : Icons.cloud_off_rounded, color: userProfile.isRegistered ? Colors.green : Colors.amber, size: isLandscape ? 20 : 24),
              const SizedBox(width: 10),
              Expanded(child: Text(userProfile.isRegistered ? (isLandscape ? 'Sincronizado' : 'Sincronizado con la Nube') : 'Modo Local', style: GoogleFonts.outfit(fontSize: isLandscape ? 13 : 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87))),
              if (userProfile.isRegistered && !isLandscape)
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: const Text('ONLINE', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          if (!isLandscape) Text(userProfile.isRegistered ? 'Cuenta activa: ${userProfile.email}\nTu progreso está respaldado de forma segura.' : 'Tu progreso solo está guardado en este dispositivo. Regístrate para competir globalmente.', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.4)),
          const SizedBox(height: 12),
          if (!userProfile.isRegistered)
            SizedBox(width: double.infinity, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)])), child: ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen())), icon: const Icon(Icons.login_rounded, color: Colors.white, size: 18), label: Text(isLandscape ? 'IDENTIFICARSE' : 'INICIAR SESIÓN / REGISTRARSE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))))
          else
            Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sincronizando progreso... ☁️'), duration: Duration(seconds: 1))); await ref.read(profileProvider.notifier).refreshProfileFromServer(); }, icon: const Icon(Icons.sync_rounded, size: 14), label: const Text('Sincronizar', style: TextStyle(fontSize: 11)), style: OutlinedButton.styleFrom(foregroundColor: primaryColor, side: BorderSide(color: primaryColor.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))), const SizedBox(width: 8), IconButton(onPressed: () { showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), backgroundColor: isDark ? const Color(0xFF222232) : Colors.white, title: const Text('¿Cerrar Sesión?', style: TextStyle(fontWeight: FontWeight.bold)), content: const Text('Tu progreso permanecerá seguro en la nube. Volverás al modo de juego local como invitado.', style: TextStyle(fontSize: 13)), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold))), TextButton(onPressed: () async { Navigator.of(context).pop(); await ref.read(profileProvider.notifier).logout(); }, child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))])); }, icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20), tooltip: 'Cerrar Sesión')])
        ],
      ),
    );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement, bool isUnlocked, bool isDark) {
    showDialog(context: context, builder: (context) => BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: AlertDialog(backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), title: Row(children: [Text(achievement.icon, style: const TextStyle(fontSize: 28)), const SizedBox(width: 10), Expanded(child: Text(achievement.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)))]), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(achievement.description, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700])), const SizedBox(height: 20), const Divider(), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Estado:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), Text(isUnlocked ? 'Desbloqueado ✅' : 'Bloqueado 🔒', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.green : Colors.redAccent))]), const SizedBox(height: 6), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Recompensa:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), Text('🪙 +${achievement.rewardCoins} S-Coins  ⭐ +${achievement.rewardXp} XP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber))])]), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)))])));
  }

  Widget _buildStatsTable(dynamic storage, bool isDark, Color accent, {bool isLandscape = false}) {
    const difficulties = [
      'Iniciado',
      'Cadete',
      'Explorador',
      'Viajero',
      'Estratega',
      'Experto',
      'Maestro',
      'Leyenda del Cosmos'
    ];
    return Container(decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : Colors.white, borderRadius: BorderRadius.circular(isLandscape ? 16 : 24), border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!)), clipBehavior: Clip.antiAlias, child: Table(columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(1.0), 2: FlexColumnWidth(1.0), 3: FlexColumnWidth(1.2)}, border: TableBorder(horizontalInside: BorderSide(color: isDark ? Colors.white10 : Colors.grey[100]!, width: 1.0)), children: [TableRow(decoration: BoxDecoration(color: isDark ? const Color(0xFF252538) : Colors.grey[50]), children: [_buildHeaderCell('Nivel'), _buildHeaderCell('Jugadas'), _buildHeaderCell('Ganadas'), _buildHeaderCell('Mejor T.')]), ...difficulties.map((diff) { final played = storage.getGamesPlayed(diff); final won = storage.getGamesWon(diff); final bestTime = storage.getBestTime(diff); final String bestTimeStr = bestTime == 0 ? '-' : '${(bestTime ~/ 60).toString().padLeft(2, '0')}:${(bestTime % 60).toString().padLeft(2, '0')}'; return TableRow(children: [_buildDataCell(diff, isBold: true), _buildDataCell('$played'), _buildDataCell('$won'), _buildDataCell(bestTimeStr, color: bestTime > 0 ? accent : null)]); })]));
  }

  Widget _buildHeaderCell(String text) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)));
  }

  Widget _buildDataCell(String text, {bool isBold = false, Color? color}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)));
  }

  Widget _buildProfileCard(UserProfile userProfile, dynamic currentTheme, bool isDark, String userRank, String avatarEmoji, {bool isLandscape = false}) {
    return Container(padding: EdgeInsets.all(isLandscape ? 12 : 20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(isLandscape ? 20 : 28), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: isDark ? [const Color(0xFF1E1E2E), const Color(0xFF161622)] : [Colors.white, const Color(0xFFF2F4F7)]), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))], border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!)), child: Column(children: [Row(children: [CircleAvatar(radius: isLandscape ? 24 : 36, backgroundColor: currentTheme.primaryColor.withOpacity(0.15), child: Text(avatarEmoji, style: TextStyle(fontSize: isLandscape ? 24 : 36))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(userRank, style: GoogleFonts.outfit(fontSize: isLandscape ? 12 : 16, fontWeight: FontWeight.w800, color: currentTheme.primaryColor)), const SizedBox(height: 2), Text(userProfile.isRegistered ? userProfile.username : 'Jugador Invitado', style: TextStyle(fontSize: isLandscape ? 14 : 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87))]))]), const SizedBox(height: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Progreso', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600])), Text('${userProfile.xp} XP', style: GoogleFonts.shareTechMono(fontSize: 10, fontWeight: FontWeight.bold, color: currentTheme.primaryColor))]), const SizedBox(height: 6), SizedBox(height: 6, child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: userProfile.progressPercentage, backgroundColor: isDark ? Colors.white10 : Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(currentTheme.primaryColor))))]), const SizedBox(height: 12), const Divider(height: 1), const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildCompactStat('🪙', '${userProfile.coins}', 'Monedas', isLandscape), Container(height: 20, width: 1, color: isDark ? Colors.white10 : Colors.grey[300]), _buildCompactStat('🏆', '${userProfile.unlockedAchievements.length}', 'Medallas', isLandscape)])]));
  }

  Widget _buildCompactStat(String icon, String val, String label, bool isLandscape) {
    return Column(
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(val, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        if (!isLandscape) Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAchievementTile(BuildContext context, dynamic achievement, bool isUnlocked, bool isDark, dynamic currentTheme, {bool isLandscape = false}) {
    return GestureDetector(onTap: () => _showAchievementDetail(context, achievement, isUnlocked, isDark), child: Container(decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : Colors.white, borderRadius: BorderRadius.circular(isLandscape ? 16 : 24), border: Border.all(color: isUnlocked ? currentTheme.primaryColor.withOpacity(0.35) : (isDark ? Colors.white10 : Colors.grey[200]!), width: isUnlocked ? 1.5 : 1.0), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4)]), padding: EdgeInsets.symmetric(horizontal: isLandscape ? 8 : 14, vertical: isLandscape ? 8 : 12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: isLandscape ? 18 : 24, backgroundColor: isUnlocked ? currentTheme.primaryColor.withOpacity(0.12) : (isDark ? Colors.white10 : Colors.grey[100]), child: Text(achievement.icon, style: TextStyle(fontSize: isLandscape ? 18 : 24, color: isUnlocked ? null : Colors.grey.withOpacity(0.4)))), const SizedBox(height: 6), Text(achievement.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isLandscape ? 10 : 13, fontWeight: FontWeight.bold, color: isUnlocked ? (isDark ? Colors.white : Colors.black87) : Colors.grey))])));
  }

  Widget _buildRecordsMotivationCard(dynamic currentTheme, bool isDark, {bool isLandscape = false}) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: currentTheme.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(24), border: Border.all(color: currentTheme.primaryColor.withOpacity(0.15))), child: Row(children: [const Text('💡', style: TextStyle(fontSize: 24)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('¡Desafía tu Lógica!', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), if (!isLandscape) ...[const SizedBox(height: 4), Text('Tu racha e inteligencia se sincronizan automáticamente con el ranking global.', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.4))]]))] ));
  }
}

/// Clasificación Global
class LeaderboardView extends ConsumerStatefulWidget {
  final bool isLandscape;
  final bool isDesktop;
  const LeaderboardView({super.key, this.isLandscape = false, this.isDesktop = false});
  @override
  ConsumerState<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends ConsumerState<LeaderboardView> {
  String _activeTab = 'level'; String _activeDifficulty = 'Fácil'; List<dynamic> _leaderboardList = []; bool _isLoading = false; String? _errorMessage;
  @override
  void initState() { super.initState(); _fetchLeaderboard(); }
  Future<void> _fetchLeaderboard() async { setState(() { _isLoading = true; _errorMessage = null; }); final result = await ApiService.getLeaderboard(type: _activeTab, difficulty: _activeDifficulty); if (!mounted) return; setState(() { _isLoading = false; if (result['success']) { _leaderboardList = result['leaderboard'] ?? []; } else { _errorMessage = result['message']; } }); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = ref.read(themeProvider.notifier).currentSudokuTheme;

    if (widget.isDesktop || widget.isLandscape) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0), 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Container(
              width: widget.isLandscape ? 220 : 320, 
              padding: const EdgeInsets.all(16), 
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!)), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('LIGA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: theme.primaryColor, letterSpacing: 1.1)), IconButton(onPressed: _fetchLeaderboard, icon: Icon(Icons.refresh_rounded, color: theme.primaryColor, size: 18), tooltip: 'Actualizar Tabla', constraints: const BoxConstraints(), padding: EdgeInsets.zero)]), 
                  const SizedBox(height: 12), 
                  _buildDesktopTypeSelector(isDark, theme.primaryColor), 
                  if (_activeTab == 'speed') ...[const SizedBox(height: 16), _buildDesktopDifficultySelector(isDark)]
                ]
              )
            ), 
            const SizedBox(width: 16), 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🏆 ', style: TextStyle(fontSize: 18)),
                      Text(
                        _activeTab == 'level' ? 'Ranking Maestros' : 'Velocistas ($_activeDifficulty)',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? SizedBox(
                          height: 250,
                          child: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
                        )
                      : _errorMessage != null
                          ? SizedBox(height: 250, child: _buildErrorPlaceholder())
                          : _leaderboardList.isEmpty
                              ? SizedBox(height: 250, child: _buildEmptyPlaceholder())
                              : _buildLeaderboardList(isDark, theme.primaryColor),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeSelectorButton(
                label: 'General',
                isActive: _activeTab == 'level',
                color: theme.primaryColor,
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
                label: 'Velocidad',
                isActive: _activeTab == 'speed',
                color: theme.primaryColor,
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
                icon: Icon(Icons.refresh_rounded, color: theme.primaryColor),
                tooltip: 'Actualizar Tabla',
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_activeTab == 'speed') ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  'Iniciado',
                  'Cadete',
                  'Explorador',
                  'Viajero',
                  'Estratega',
                  'Experto',
                  'Maestro',
                  'Leyenda del Cosmos'
                ].map((diff) {
                  final isSel = _activeDifficulty == diff;
                  Color diffColor;
                  switch (diff) {
                    case 'Iniciado': diffColor = Colors.tealAccent; break;
                    case 'Cadete': diffColor = Colors.teal; break;
                    case 'Explorador': diffColor = Colors.cyan; break;
                    case 'Viajero': diffColor = Colors.blueAccent; break;
                    case 'Estratega': diffColor = Colors.indigoAccent; break;
                    case 'Experto': diffColor = Colors.purpleAccent; break;
                    case 'Maestro': diffColor = Colors.deepOrangeAccent; break;
                    case 'Leyenda del Cosmos': diffColor = Colors.redAccent; break;
                    default: diffColor = Colors.teal;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        diff,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      selected: isSel,
                      selectedColor: diffColor.withOpacity(0.2),
                      checkmarkColor: diffColor,
                      labelStyle: TextStyle(
                        color: isSel ? diffColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
                      ),
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
          _isLoading
              ? SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
                )
              : _errorMessage != null
                  ? SizedBox(height: 250, child: _buildErrorPlaceholder())
                  : _leaderboardList.isEmpty
                      ? SizedBox(height: 250, child: _buildEmptyPlaceholder())
                      : _buildLeaderboardList(isDark, theme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildTypeSelectorButton({required String label, required bool isActive, required Color color, required bool isDark, required VoidCallback onTap}) { return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: isActive ? color.withOpacity(0.15) : (isDark ? const Color(0xFF1E1E2E) : Colors.white), borderRadius: BorderRadius.circular(16), border: Border.all(color: isActive ? color : (isDark ? Colors.white10 : Colors.grey[200]!), width: 1.5)), child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isActive ? color : (isDark ? Colors.grey[400] : Colors.grey[700]))))); }
  Widget _buildErrorPlaceholder() { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('📡', style: TextStyle(fontSize: 44)), const SizedBox(height: 12), const Text('Sin conexión con el ranking global', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 6), Text(_errorMessage ?? 'Verifica tu conexión de red o servidor.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)), const SizedBox(height: 16), ElevatedButton(onPressed: _fetchLeaderboard, child: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold)))])); }
  Widget _buildEmptyPlaceholder() { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Text('🏆', style: TextStyle(fontSize: 44)), SizedBox(height: 12), Text('¡No hay marcas registradas aún!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 4), Text('Sé el primero en registrarte y resolver un Sudoku para liderar la tabla.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey))])); }
  Widget _buildLeaderboardList(bool isDark, Color accentColor) { return ListView.builder(physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: _leaderboardList.length, itemBuilder: (context, index) { final player = _leaderboardList[index]; final rank = index + 1; final username = player['username'] as String? ?? 'Desconocido'; final level = player['level'] as int? ?? 1; String recordStr = _activeTab == 'speed' ? '${(player['best_time'] as int? ?? 0) ~/ 60}:${((player['best_time'] as int? ?? 0) % 60).toString().padLeft(2, '0')} min' : '🪙 ${player['coins'] as int? ?? 0}'; Color? rankBgColor; Widget rankWidget; if (rank == 1) { rankBgColor = Colors.amber.withOpacity(0.12); rankWidget = const Text('👑', style: TextStyle(fontSize: 20)); } else if (rank == 2) { rankBgColor = Colors.blueGrey.withOpacity(0.08); rankWidget = const Text('🥈', style: TextStyle(fontSize: 20)); } else if (rank == 3) { rankBgColor = Colors.brown.withOpacity(0.08); rankWidget = const Text('🥉', style: TextStyle(fontSize: 20)); } else { rankWidget = Container(width: 26, height: 26, alignment: Alignment.center, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[200], shape: BoxShape.circle), child: Text('$rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white70 : Colors.black87))); } String getAvatar(int level) => level <= 2 ? '🌱' : (level <= 5 ? '🧠' : (level <= 9 ? '⚡' : (level <= 14 ? '🔮' : '👑'))); return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: rankBgColor ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white), borderRadius: BorderRadius.circular(18), border: Border.all(color: rank == 1 ? Colors.amber.withOpacity(0.35) : (isDark ? Colors.white10 : Colors.grey[100]!), width: rank == 1 ? 1.5 : 1.0)), child: Row(children: [Container(width: 32, alignment: Alignment.centerLeft, child: rankWidget), CircleAvatar(radius: 18, backgroundColor: accentColor.withOpacity(0.12), child: Text(getAvatar(level), style: const TextStyle(fontSize: 18))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(username, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? Colors.white : Colors.black87)), Text('Nivel $level', style: TextStyle(fontSize: 10.5, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500))])), Text(recordStr, style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold, fontSize: 13, color: rank == 1 ? Colors.amber[700] : accentColor))])); }); }
  Widget _buildDesktopTypeSelector(bool isDark, Color accentColor) { return Column(children: [_buildDesktopTypeOption(label: 'General (Nivel)', subtitle: 'XP', icon: '👑', isActive: _activeTab == 'level', accentColor: accentColor, isDark: isDark, onTap: () { setState(() { _activeTab = 'level'; }); _fetchLeaderboard(); }), const SizedBox(height: 12), _buildDesktopTypeOption(label: 'Velocidad', subtitle: 'Tiempo', icon: '⚡', isActive: _activeTab == 'speed', accentColor: accentColor, isDark: isDark, onTap: () { setState(() { _activeTab = 'speed'; }); _fetchLeaderboard(); })]); }
  Widget _buildDesktopTypeOption({required String label, required String subtitle, required String icon, required bool isActive, required Color accentColor, required bool isDark, required VoidCallback onTap}) { return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: isActive ? accentColor.withOpacity(0.12) : (isDark ? const Color(0xFF14141F) : Colors.grey[50]), borderRadius: BorderRadius.circular(16), border: Border.all(color: isActive ? accentColor : (isDark ? Colors.white10 : Colors.grey[200]!), width: 1.5)), child: Row(children: [Text(icon, style: const TextStyle(fontSize: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? accentColor : (isDark ? Colors.white : Colors.black87))), const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]))]))]))); }
  Widget _buildDesktopDifficultySelector(bool isDark) {
    return Column(
      children: [
        'Iniciado',
        'Cadete',
        'Explorador',
        'Viajero',
        'Estratega',
        'Experto',
        'Maestro',
        'Leyenda del Cosmos'
      ].map((diff) {
        final isSel = _activeDifficulty == diff;
        Color diffColor;
        switch (diff) {
          case 'Iniciado': diffColor = Colors.tealAccent; break;
          case 'Cadete': diffColor = Colors.teal; break;
          case 'Explorador': diffColor = Colors.cyan; break;
          case 'Viajero': diffColor = Colors.blueAccent; break;
          case 'Estratega': diffColor = Colors.indigoAccent; break;
          case 'Experto': diffColor = Colors.purpleAccent; break;
          case 'Maestro': diffColor = Colors.deepOrangeAccent; break;
          case 'Leyenda del Cosmos': diffColor = Colors.redAccent; break;
          default: diffColor = Colors.teal;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _activeDifficulty = diff;
              });
              _fetchLeaderboard();
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSel ? diffColor.withOpacity(0.12) : (isDark ? const Color(0xFF14141F) : Colors.grey[50]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSel ? diffColor : (isDark ? Colors.white10 : Colors.grey[200]!), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: diffColor, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(diff, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSel ? diffColor : (isDark ? Colors.grey[350] : Colors.grey[700]))),
                  const Spacer(),
                  if (isSel) Icon(Icons.check_circle_outline_rounded, color: diffColor, size: 16)
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
