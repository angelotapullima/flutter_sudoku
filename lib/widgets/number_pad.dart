import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;
    final isDark = themeState.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = (constraints.maxWidth - (8 * 8)) / 9;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(9, (index) {
              final number = index + 1;
              return GestureDetector(
                onTap: () {
                  ref.read(gameProvider.notifier).inputNumber(number);
                },
                child: Container(
                  width: buttonSize,
                  height: buttonSize * 1.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF2B2B3C), const Color(0xFF1E1E2E)]
                          : [Colors.grey[100]!, Colors.white],
                    ),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey[200]!,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.whiteEfficacy : sudokuTheme.primaryColor,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// Extensión para simplificar colores
extension TextStyleDark on TextStyle {
  Color get whiteEfficacy => Colors.white.withOpacity(0.9);
}
