import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../features/campaign/presentation/providers/campaign_notifier.dart';
import '../features/campaign/domain/entities/campaign_level.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';
import '../widgets/responsive_content_wrapper.dart';
import '../widgets/pre_game_modal.dart';

class StarMapScreen extends ConsumerStatefulWidget {
  const StarMapScreen({super.key});

  @override
  ConsumerState<StarMapScreen> createState() => _StarMapScreenState();
}

class _StarMapScreenState extends ConsumerState<StarMapScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaign = ref.watch(campaignNotifierProvider);
    final userProfile = ref.watch(profileProvider);
    final sudokuTheme = ref.read(themeProvider.notifier).currentSudokuTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B10), // Espacio profundo
      body: Stack(
        children: [
          // 1. Fondo de Estrellas Estático/Lento
          const _StarryBackground(),

          // 2. El Camino Estelar (Mapa)
          if (campaign.isLoading)
            const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent))
          else if (campaign.error != null)
            Center(
                child: Text('Error: ${campaign.error}',
                    style: const TextStyle(color: Colors.white)))
          else
            ResponsiveContentWrapper(
              maxWidth: 550,
              child: _buildMapPath(
                  campaign.levels, userProfile.campaignLevel, sudokuTheme),
            ),

          // 3. Barra Superior Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeaderOverlay(userProfile, sudokuTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPath(
      List<CampaignLevel> levels, int currentCampaignLevel, dynamic theme) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Empezamos desde abajo
      padding: const EdgeInsets.symmetric(vertical: 100),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final bool isUnlocked = level.levelNumber <= currentCampaignLevel;
        final bool isCurrent = level.levelNumber == currentCampaignLevel;

        // Lógica de posición serpenteante (Zig-Zag)
        double horizontalOffset = 60.0 * math.sin(index * 1.5);

        return Container(
          height: 180,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Línea conectora (Visual)
              if (index < levels.length - 1)
                Positioned(
                  bottom: -90,
                  child: CustomPaint(
                    size: const Size(200, 180),
                    painter: _PathPainter(
                      startOffset: horizontalOffset,
                      endOffset: 60.0 * math.sin((index + 1) * 1.5),
                      isUnlocked: isUnlocked &&
                          (level.levelNumber + 1 <= currentCampaignLevel),
                      color: theme.primaryColor,
                    ),
                  ),
                ),

              // El Planeta (Nodo)
              Transform.translate(
                offset: Offset(horizontalOffset, 0),
                child: _PlanetNode(
                  level: level,
                  isUnlocked: isUnlocked,
                  isCurrent: isCurrent,
                  theme: theme,
                  onTap: () {
                    if (isUnlocked) {
                      _startLevel(level);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Este sistema estelar está bloqueado.')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startLevel(CampaignLevel level) {
    PreGameModal.show(
      context,
      title: level.bossName != null && level.bossName!.isNotEmpty
          ? 'Guardián: ${level.bossName}'
          : 'Planeta ${level.levelNumber}',
      modeType: 'campaign',
      campaignLevelNumber: level.levelNumber,
      puzzleData: level.puzzleData,
      solutionData: level.solutionData,
      bossName: level.bossName,
      modifiers: level.modifiers,
    );
  }

  Widget _buildHeaderOverlay(dynamic profile, dynamic theme) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding:
          EdgeInsets.only(top: topPadding > 0 ? topPadding : 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: ResponsiveContentWrapper(
        maxWidth: 550,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONSTELACIÓN DEL ORIGEN',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Sector ${profile.campaignLevel}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Text('🪙 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '${profile.coins}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanetNode extends StatelessWidget {
  final CampaignLevel level;
  final bool isUnlocked;
  final bool isCurrent;
  final dynamic theme;
  final VoidCallback onTap;

  const _PlanetNode({
    required this.level,
    required this.isUnlocked,
    required this.isCurrent,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBoss = level.isBoss();
    final Color planetColor = isUnlocked
        ? (isBoss ? Colors.redAccent : theme.primaryColor)
        : Colors.grey.withOpacity(0.3);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Aura de brillo para el nivel actual
              if (isCurrent) _GlowingAura(color: planetColor),

              // Cuerpo del planeta
              Container(
                width: isBoss ? 80 : 60,
                height: isBoss ? 80 : 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      planetColor.withOpacity(1.0),
                      planetColor.withOpacity(0.7),
                      Colors.black.withOpacity(0.5),
                    ],
                    stops: const [0.2, 0.6, 1.0],
                  ),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: planetColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: isUnlocked
                    ? null
                    : const Icon(Icons.lock_rounded,
                        color: Colors.white24, size: 20),
              ),

              // Texto del nivel
              if (isUnlocked && !isBoss)
                Text(
                  '${level.levelNumber}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18),
                ),

              if (isBoss && isUnlocked)
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 40),
            ],
          ),
          const SizedBox(height: 8),
          if (isBoss)
            Text(
              level.bossName!.toUpperCase(),
              style: GoogleFonts.outfit(
                color: isUnlocked ? Colors.redAccent : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
        ],
      ),
    );
  }
}

class _GlowingAura extends StatefulWidget {
  final Color color;
  const _GlowingAura({required this.color});

  @override
  State<_GlowingAura> createState() => _GlowingAuraState();
}

class _GlowingAuraState extends State<_GlowingAura>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 100 + (20 * _controller.value),
          height: 100 + (20 * _controller.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.15 * (1 - _controller.value)),
          ),
        );
      },
    );
  }
}

class _StarryBackground extends StatelessWidget {
  const _StarryBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _StarsPainter(),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final s = random.nextDouble() * 1.5;
      final int alpha = (random.nextDouble() * 200).toInt() + 55;
      paint.color = Colors.white.withAlpha(alpha);
      canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _PathPainter extends CustomPainter {
  final double startOffset;
  final double endOffset;
  final bool isUnlocked;
  final Color color;

  _PathPainter({
    required this.startOffset,
    required this.endOffset,
    required this.isUnlocked,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isUnlocked ? color.withOpacity(0.4) : Colors.white10
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2 + startOffset, 0);
    path.cubicTo(
      size.width / 2 + startOffset,
      90,
      size.width / 2 + endOffset,
      90,
      size.width / 2 + endOffset,
      180,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
