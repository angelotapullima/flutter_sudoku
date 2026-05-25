import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tutorial_keys_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;
    final settings = ref.watch(settingsProvider);
    final keys = ref.read(tutorialKeysProvider);

    int getCorrectCount(int num) {
      if (gameState.grid.isEmpty) return 0;
      int count = 0;
      for (var r in gameState.grid) {
        for (var cell in r) {
          if (cell.value == num && !cell.isError) count++;
        }
      }
      return count;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final bool isLandscape = height < 200;

        if (isLandscape) {
          // DISEÑO ULTRA COMPACTO PARA LANDSCAPE (Grid 5x2 o similar)
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.5,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final number = index + 1;
              final countLeft = 9 - getCorrectCount(number);
              if (settings.showRemainingNumbers && countLeft <= 0) return const SizedBox.shrink();

              return GestureDetector(
                key: keys.numKeys[index],
                onTap: () => ref.read(gameProvider.notifier).inputNumber(number),
                child: Container(
                  decoration: BoxDecoration(
                    color: sudokuTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sudokuTheme.primaryColor.withOpacity(0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: sudokuTheme.primaryColor,
                    ),
                  ),
                ),
              );
            },
          );
        }

        // DISEÑO ORIGINAL (Mobile Portrait / Desktop)
        final bool isDesktop = width > 400;
        if (isDesktop) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final number = index + 1;
              final countLeft = 9 - getCorrectCount(number);
              if (settings.showRemainingNumbers && countLeft <= 0) return const SizedBox.shrink();

              return GestureDetector(
                key: keys.numKeys[index],
                onTap: () => ref.read(gameProvider.notifier).inputNumber(number),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$number', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: sudokuTheme.primaryColor)),
                      if (settings.showRemainingNumbers)
                        Text('$countLeft', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // Mobile Portrait clásico
        final double buttonSize = (width - 60) / 9;
        return Container(
          height: buttonSize * 1.5,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(9, (index) {
              final number = index + 1;
              final countLeft = 9 - getCorrectCount(number);
              if (settings.showRemainingNumbers && countLeft <= 0) return const SizedBox.shrink();

              return GestureDetector(
                key: keys.numKeys[index],
                onTap: () => ref.read(gameProvider.notifier).inputNumber(number),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: buttonSize,
                      height: buttonSize * 1.1,
                      decoration: BoxDecoration(
                        color: sudokuTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('$number', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sudokuTheme.primaryColor)),
                    ),
                    if (settings.showTimer)
                       Text('$countLeft', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              );
            }),
          ),
        );
      }
    );
  }
}
