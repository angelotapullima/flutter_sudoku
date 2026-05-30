import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/clans/domain/entities/clan_details.dart';
import '../features/clans/domain/entities/clan_member.dart';
import '../features/clans/domain/entities/clan_message.dart';
import '../features/clans/presentation/providers/clan_notifier.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/pre_game_modal.dart';
import 'login_screen.dart';
import '../utils/enums.dart';

class ClanScreen extends ConsumerStatefulWidget {
  const ClanScreen({super.key});

  @override
  ConsumerState<ClanScreen> createState() => _ClanScreenState();
}

class _ClanScreenState extends ConsumerState<ClanScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Cuando el teclado se abre, esperar a la animación y hacer scroll al fondo
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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

    if (clanState.isLoading &&
        clanState.details == null &&
        clanState.availableClans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
      body: Stack(
        children: [
          clanState.inClan
              ? _buildMyClanView(clanState, isDark, sudokuTheme)
              : _buildClanSelectionView(clanState, isDark, sudokuTheme),
          if (clanState.isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context, bool isDark, dynamic theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'LOGIAS CERRADAS',
              style: GoogleFonts.outfit(
                  fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'Debes estar registrado para fundar o unirte a una logia y participar en la guerra colectiva.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('INICIAR SESIÓN',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
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
        // 1. Cabecera del Clan ultra-compacta
        _buildCompactClanHeader(details, isDark, theme),

        // 2. Tab Bar Personalizado (Inmune a Reconstrucciones de Foco)
        _buildCustomTabBar(theme, isDark),

        // 3. Contenedor de Vistas Estable
        Expanded(
          child: IndexedStack(
            index: _activeTab,
            children: [
              _buildHomeTab(state, isDark, theme),
              _buildChatView(state, isDark, theme),
              _buildMembersList(state, isDark, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactClanHeader(
      ClanDetails details, bool isDark, dynamic theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0B12) : const Color(0xFFF9F9FC),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: [
            // Tiny tag badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                details.tag,
                style: GoogleFonts.outfit(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Clan Name
            Expanded(
              child: Text(
                details.name,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Leave Button
            IconButton(
              onPressed: () => _showLeaveClanDialog(context, theme),
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              tooltip: 'Abandonar Logia',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(dynamic theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111116) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(0, 'INICIO', theme, isDark),
          _buildTabButton(1, 'MENSAJES', theme, isDark),
          _buildTabButton(2, 'MIEMBROS', theme, isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, dynamic theme, bool isDark) {
    final bool isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: isSelected
                  ? theme.primaryColor
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(ClanState state, bool isDark, dynamic theme) {
    final details = state.details!;
    final double progress =
        (details.monsterDamageTotal / details.monsterHpMax).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    // Detección responsiva de columnas de dificultad según orientación
    final int crossCount =
        MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2;
    final double aspect =
        MediaQuery.of(context).orientation == Orientation.landscape ? 3.0 : 2.2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta del Titán Activo (Limpia y minimalista)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13131A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('👾', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'TITÁN ACTIVO',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: theme.primaryColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Omega Sudoku',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Resuelvan tableros colectivamente para derrotar al monstruo de la semana.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                // HP de Titán y Barra de Daño Limpia
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vida del Titán: $percent%',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      '${(details.monsterDamageTotal / 1000).toStringAsFixed(1)}k / ${(details.monsterHpMax / 1000).toStringAsFixed(0)}k HP',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: theme.primaryColor.withOpacity(0.08),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Card del Botín de Guerra Semanal (Minimalista, suave)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOTÍN DE GUERRA SEMANAL',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber[800] ?? Colors.amber,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Derroten al Titán para recibir 500 monedas 🪙 y 50 gemas 💎 cada miembro al final de la semana.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildBattleLog(state, isDark, theme),
          const SizedBox(height: 24),
          // Sección de combate e invitación a jugar
          Text(
            '¡AL COMBATE!',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white70 : Colors.black87,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cada partida de Sudoku que resuelvas infligirá daño directo al Titán. ¡Escoge tu nivel y ataca!',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          // Grid de Dificultades / Botones de Ataque
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspect,
            children: [
              _buildAttackButton(context, GameDifficulty.apprentice, 'normal',
                  '+10 Daño', '⚡', theme, isDark),
              _buildAttackButton(context, GameDifficulty.cadet, 'normal',
                  '+18 Daño', '🛡️', theme, isDark),
              _buildAttackButton(context, GameDifficulty.explorer, 'normal',
                  '+28 Daño', '🚀', theme, isDark),
              _buildAttackButton(context, GameDifficulty.traveler, 'normal',
                  '+40 Daño', '🔥', theme, isDark),
              _buildAttackButton(context, GameDifficulty.strategist, 'normal',
                  '+55 Daño', '🌌', theme, isDark),
              _buildAttackButton(context, GameDifficulty.expert, 'normal',
                  '+75 Daño', '💥', theme, isDark),
              _buildAttackButton(context, GameDifficulty.master, 'normal',
                  '+105 Daño', '🔮', theme, isDark),
              _buildAttackButton(context, GameDifficulty.legend, 'normal',
                  '+150 Daño', '👑', theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttackButton(
    BuildContext context,
    GameDifficulty difficulty,
    String modeType,
    String damageText,
    String emoji,
    dynamic theme,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        PreGameModal.show(
          context,
          title: difficulty.label,
          modeType: modeType,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13131A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    difficulty.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              damageText,
              style: GoogleFonts.shareTechMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(ClanState state, bool isDark, dynamic theme) {
    final currentUser = ref.read(profileProvider).username;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView.builder(
              controller: _scrollController,
              reverse:
                  true, // Ancla la lista a la parte inferior (Estilo WhatsApp)
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                // Como la lista está invertida visualmente, obtenemos el mensaje desde el final hacia el principio
                final msg = state.messages[state.messages.length - 1 - index];
                final bool isMe = msg.username == currentUser;

                // Agrupación estilo WhatsApp: ¿Es el mensaje anterior (más viejo) del mismo usuario?
                bool showName = !isMe;
                if (!isMe && index + 1 < state.messages.length) {
                  final olderMsg =
                      state.messages[state.messages.length - 1 - (index + 1)];
                  if (olderMsg.username == msg.username) {
                    showName = false;
                  }
                }

                // Espaciado: ¿Es el mensaje siguiente (más nuevo) del mismo usuario?
                bool isLastInGroup = true;
                if (index > 0) {
                  final newerMsg =
                      state.messages[state.messages.length - 1 - (index - 1)];
                  if (newerMsg.username == msg.username) {
                    isLastInGroup = false;
                  }
                }

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: isLastInGroup ? 12.0 : 4.0),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (showName)
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, bottom: 4),
                            child: Text(msg.username,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor)),
                          ),
                        Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? theme.primaryColor
                                : (isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.grey[200]),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(msg.message,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: isMe
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white
                                              : Colors.black87))),
                              if (isMe) ...[
                                const SizedBox(height: 2),
                                Icon(
                                  msg.isSent
                                      ? Icons.done_all_rounded
                                      : Icons.done_rounded,
                                  size: 12,
                                  color: msg.isSent
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.4),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Caja de entrada de texto optimizada
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16161E) : Colors.white,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87),
                  onSubmitted: (val) {
                    if (val.trim().isEmpty) return;
                    ref.read(clanProvider.notifier).sendChatMessage(val);
                    _messageController.clear();
                    if (mounted && _scrollController.hasClients) {
                      _scrollController.animateTo(0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_messageController.text.trim().isEmpty) return;
                    ref
                        .read(clanProvider.notifier)
                        .sendChatMessage(_messageController.text);
                    _messageController.clear();
                    if (mounted && _scrollController.hasClients) {
                      _scrollController.animateTo(0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send_rounded,
                        color: theme.primaryColor, size: 20),
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
    final String currentUser = ref.read(profileProvider).username;
    final bool isCurrentUserLeader = state.members
        .any((m) => m.username == currentUser && m.role == 'leader');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        final member = state.members[index];
        final int weeklyDamage = member.monsterDamageWeekly;
        final bool isMVP = index == 0 && weeklyDamage > 0;

        final bool isTop1 = index == 0 && weeklyDamage > 0;
        final bool isTop2 = index == 1 && weeklyDamage > 0;
        final bool isTop3 = index == 2 && weeklyDamage > 0;

        String medalPrefix = '';
        if (isTop1) medalPrefix = '🥇 ';
        if (isTop2) medalPrefix = '🥈 ';
        if (isTop3) medalPrefix = '🥉 ';

        String hunterTitle = 'Recluta Silencioso';
        Color titleColor = isDark ? Colors.white38 : Colors.black38;
        if (weeklyDamage >= 1500) {
          hunterTitle = 'Erradicador Cósmico 🌌';
          titleColor = const Color(0xFFD08CF2);
        } else if (weeklyDamage >= 800) {
          hunterTitle = 'Gladiador Estelar ⚔️';
          titleColor = const Color(0xFFFFD700);
        } else if (weeklyDamage >= 300) {
          hunterTitle = 'Defensor de la Logia 🛡️';
          titleColor = const Color(0xFF64B5F6);
        } else if (weeklyDamage > 0) {
          hunterTitle = 'Cazador Iniciado 🚀';
          titleColor = const Color(0xFF81C784);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isMVP
                ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5)
                : null,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Text('${member.level}',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
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
                if (medalPrefix.isNotEmpty)
                  Text(medalPrefix, style: const TextStyle(fontSize: 14)),
                Text(member.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                if (member.role == 'leader')
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('LÍDER',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent)),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  hunterTitle,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Miembro desde: ${member.joinedAt.length >= 10 ? member.joinedAt.substring(0, 10) : member.joinedAt}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '⚔️ $weeklyDamage',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isMVP
                              ? Colors.amber
                              : (isDark ? Colors.white70 : Colors.black87)),
                    ),
                    const Text('DAÑO SEMANAL',
                        style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                  ],
                ),
                if (isCurrentUserLeader && member.username != currentUser) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () =>
                        _showKickConfirmDialog(context, member.username, theme),
                    icon: const Icon(
                      Icons.person_remove_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    tooltip: 'Expulsar de la Logia',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
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
          Text('HALL DE LOGIAS',
              style: GoogleFonts.outfit(
                  fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Únete a una comunidad y derrota al monstruo semanal.',
              style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showCreateClanDialog(context, theme, isDark),
                  icon: const Icon(Icons.add),
                  label: const Text('FUNDAR LOGIA'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('LOGIAS DISPONIBLES',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(clan.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(clan.description),
                  trailing: ElevatedButton(
                    onPressed: () =>
                        ref.read(clanProvider.notifier).joinClan(clan.id),
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
        content: const Text(
            'Dejarás de aportar daño al monstruo y perderás el acceso al chat de esta logia.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
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
            child: const Text('ABANDONAR',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showKickConfirmDialog(
      BuildContext context, String targetUsername, dynamic theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Expulsar Miembro?'),
        content: Text(
            '¿Estás seguro de que deseas expulsar a $targetUsername de la logia?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(clanProvider.notifier)
                  .kickMember(targetUsername);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Has expulsado a $targetUsername de la logia.')),
                  );
                }
              }
            },
            child: const Text('EXPULSAR',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Fundar Logia',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                    labelText: 'Nombre de la Logia',
                    hintText: 'Ej: Guerreros Lógicos'),
                enabled: !isSaving,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagC,
                decoration: const InputDecoration(
                    labelText: 'Tag', hintText: 'Máx 10 letras (Ej: LOGIC)'),
                enabled: !isSaving,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descC,
                decoration:
                    const InputDecoration(labelText: 'Descripción corta'),
                enabled: !isSaving,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (nameC.text.isEmpty || tagC.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Nombre y Tag son obligatorios')),
                        );
                        return;
                      }

                      setModalState(() => isSaving = true);

                      final success = await ref
                          .read(clanProvider.notifier)
                          .fundClan(nameC.text.trim(), tagC.text.trim(),
                              descC.text.trim());

                      if (mounted) {
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('¡Logia fundada con éxito! 🛡️')),
                          );
                        } else {
                          setModalState(() => isSaving = false);
                          final error = ref.read(clanProvider).error ??
                              'Error al crear logia';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.redAccent),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('FUNDAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBattleLog(ClanState state, bool isDark, dynamic theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13131A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'BITÁCORA DE COMBATE',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.recentAttacks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'El cosmos está en silencio. Ningún cazador ha atacado al Titán esta semana. ¡Sé el primero en golpear!',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentAttacks.length,
              itemBuilder: (context, index) {
                final attack = state.recentAttacks[index];
                final emoji = _getDifficultyEmoji(attack.difficulty);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attack.username,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white.withOpacity(0.87)
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              'Atacó en ${attack.difficulty}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${attack.damage} Daño',
                            style: GoogleFonts.shareTechMono(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          Text(
                            _formatRelativeTime(attack.createdAt),
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? Colors.white30 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'hace instantes';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} h';
    } else {
      return 'hace ${difference.inDays} d';
    }
  }

  String _getDifficultyEmoji(String difficulty) {
    switch (difficulty) {
      case 'Iniciado':
        return '⚡';
      case 'Cadete':
        return '🛡️';
      case 'Explorador':
        return '🚀';
      case 'Viajero':
        return '🔥';
      case 'Estratega':
        return '🌌';
      case 'Experto':
        return '💥';
      case 'Maestro':
        return '🔮';
      case 'Leyenda del Cosmos':
        return '👑';
      default:
        return '⚔️';
    }
  }
}
