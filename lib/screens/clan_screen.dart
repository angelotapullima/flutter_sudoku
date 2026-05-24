import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/clan_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class ClanScreen extends ConsumerStatefulWidget {
  const ClanScreen({super.key});

  @override
  ConsumerState<ClanScreen> createState() => _ClanScreenState();
}

class _ClanScreenState extends ConsumerState<ClanScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clanState = ref.watch(clanProvider);
    final userProfile = ref.watch(profileProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;

    if (!userProfile.isRegistered) {
      return _buildLoginRequired(context, isDark, sudokuTheme);
    }

    if (clanState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
      body: clanState.inClan ? _buildMyClanView(clanState, isDark, sudokuTheme) : _buildClanSelectionView(clanState, isDark, sudokuTheme),
    );
  }

  Widget _buildLoginRequired(BuildContext context, bool isDark, dynamic theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'LOGIAS CERRADAS',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Text(
              'Debes estar registrado para fundar o unirte a una logia y participar en la guerra colectiva.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('INICIAR SESIÓN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyClanView(ClanState state, bool isDark, dynamic theme) {
    final details = state.details!;

    return Column(
      children: [
        // 1. Cabecera del Clan (Guerra de Monstruos)
        _buildClanHeader(details, isDark, theme),

        // 2. Chat y Miembros
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: theme.primaryColor,
                  tabs: const [
                    Tab(text: 'SALA DE LOGIA'),
                    Tab(text: 'MIEMBROS'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildChatView(state, isDark, theme),
                      _buildMembersList(state, isDark, theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClanHeader(ClanDetails details, bool isDark, dynamic theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161E) : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(details.tag, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(details.name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(details.description, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showLeaveClanDialog(context, theme),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                tooltip: 'Abandonar Logia',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // --- NUEVO: BOTÍN DE GUERRA INFO ---
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BOTÍN DE GUERRA SEMANAL',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.amber, letterSpacing: 1),
                      ),
                      Text(
                        'Derroten al Titán para recibir 500 🪙 y 50 💎 cada uno.',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Barra de Daño Colectivo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('⚔️ DAÑO AL MONSTRUO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text('${details.monsterDamageTotal} / 100,000 HP', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (details.monsterDamageTotal / 100000).clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatView(ClanState state, bool isDark, dynamic theme) {
    final currentUser = ref.read(profileProvider).username;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final msg = state.messages[index];
              final bool isMe = msg.username == currentUser;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 4),
                          child: Text(
                            msg.username, 
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.primaryColor)
                          ),
                        ),
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe 
                            ? theme.primaryColor 
                            : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isMe ? 20 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 20),
                          ),
                        ),
                        child: Text(
                          msg.message, 
                          style: TextStyle(
                            fontSize: 14, 
                            color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87)
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Caja de entrada de texto optimizada
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16161E) : Colors.white,
            boxShadow: [
              if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                  onSubmitted: (val) {
                    if (val.trim().isEmpty) return;
                    ref.read(clanProvider.notifier).sendChatMessage(val);
                    _messageController.clear();
                  },
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_messageController.text.trim().isEmpty) return;
                    ref.read(clanProvider.notifier).sendChatMessage(_messageController.text);
                    _messageController.clear();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send_rounded, color: theme.primaryColor, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(ClanState state, bool isDark, dynamic theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        final member = state.members[index];
        final int weeklyDamage = member['monster_damage_weekly'] ?? 0;
        final bool isMVP = index == 0 && weeklyDamage > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isMVP ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5) : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Text('${member['level']}', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                if (isMVP)
                  const Positioned(
                    top: -10,
                    left: -5,
                    child: Text('👑', style: TextStyle(fontSize: 18)),
                  ),
              ],
            ),
            title: Row(
              children: [
                Text(member['username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (member['role'] == 'leader')
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('LÍDER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ),
              ],
            ),
            subtitle: Text('Miembro desde: ${member['joined_at'].toString().substring(0, 10)}', style: const TextStyle(fontSize: 11)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '⚔️ $weeklyDamage',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: isMVP ? Colors.amber : (isDark ? Colors.white70 : Colors.black87)
                  ),
                ),
                const Text('DAÑO SEMANAL', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClanSelectionView(ClanState state, bool isDark, dynamic theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('HALL DE LOGIAS', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Únete a una comunidad y derrota al monstruo semanal.', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateClanDialog(context, theme, isDark),
                  icon: const Icon(Icons.add),
                  label: const Text('FUNDAR LOGIA'),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('LOGIAS DISPONIBLES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 12),
          // Lista de Logias con altura adaptativa
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.availableClans.length,
            itemBuilder: (context, index) {
              final clan = state.availableClans[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(clan['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(clan['description']),
                  trailing: ElevatedButton(
                    onPressed: () => ref.read(clanProvider.notifier).joinClan(clan['id']),
                    child: const Text('UNIRSE'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLeaveClanDialog(BuildContext context, dynamic theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Abandonar Logia?'),
        content: const Text('Dejarás de aportar daño al monstruo y perderás el acceso al chat de esta logia.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              final success = await ref.read(clanProvider.notifier).leaveClan();
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Has abandonado la logia.')),
                  );
                }
              }
            },
            child: const Text('ABANDONAR', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showCreateClanDialog(BuildContext context, dynamic theme, bool isDark) {
    final nameC = TextEditingController();
    final tagC = TextEditingController();
    final descC = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Fundar Logia', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC, 
                  decoration: const InputDecoration(labelText: 'Nombre de la Logia', hintText: 'Ej: Guerreros Lógicos'),
                  enabled: !isSaving,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagC, 
                  decoration: const InputDecoration(labelText: 'Tag', hintText: 'Máx 10 letras (Ej: LOGIC)'),
                  enabled: !isSaving,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descC, 
                  decoration: const InputDecoration(labelText: 'Descripción corta'),
                  enabled: !isSaving,
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context), 
                child: const Text('CANCELAR')
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (nameC.text.isEmpty || tagC.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nombre y Tag son obligatorios')),
                    );
                    return;
                  }

                  setModalState(() => isSaving = true);
                  
                  final success = await ref.read(clanProvider.notifier).fundClan(
                    nameC.text.trim(), 
                    tagC.text.trim(), 
                    descC.text.trim()
                  );

                  if (mounted) {
                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Logia fundada con éxito! 🛡️')),
                      );
                    } else {
                      setModalState(() => isSaving = false);
                      final error = ref.read(clanProvider).error ?? 'Error al crear logia';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('FUNDAR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }
}
