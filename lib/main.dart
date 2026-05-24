import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/local_storage_service.dart';
import 'providers/storage_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/animated_splash_screen.dart';

void main() async {
  // Asegurar que los canales nativos de Flutter están listos antes de SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar almacenamiento local de forma asíncrona antes de arrancar
  final localStorage = LocalStorageService();
  await localStorage.init();

  runApp(
    ProviderScope(
      overrides: [
        // Inyectar de manera síncrona el almacenamiento pre-inicializado
        storageServiceProvider.overrideWithValue(localStorage),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sudokuTheme = themeNotifier.currentSudokuTheme;

    // Configuración del Tema Dinámico
    final isDark = themeState.isDarkMode;

    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      title: 'Numbra',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: sudokuTheme.primaryColor,
          brightness: isDark ? Brightness.dark : Brightness.light,
          primary: sudokuTheme.primaryColor,
          secondary: sudokuTheme.accentColor,
        ),
        scaffoldBackgroundColor:
            isDark ? const Color(0xFF12121A) : const Color(0xFFF9F9FC),
        textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
        useMaterial3: true,
        // Configurar estilos de diálogos, etc.
        dialogTheme: DialogTheme(
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const AnimatedSplashScreen(),
    );
  }
}
