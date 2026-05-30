import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'config/env_config.dart';
import 'config/firebase_options_dev.dart' as dev;
import 'config/firebase_options_prod.dart' as prod;
import 'services/local_storage_service.dart';
import 'services/push_notification_service.dart';
import 'providers/storage_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/animated_splash_screen.dart';
import 'widgets/responsive_app_shell.dart';

void main() async {
  // Asegurar que los canales nativos de Flutter están listos antes de SharedPreferences
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inicializar Firebase para los entornos correctos (Ignorar Desktop nativo por ahora si no es web)
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
    try {
      // Usar Prod solo si el entorno es explícitamente 'prod'. En local o dev, usar Firebase Dev.
      final options = EnvConfig.isProd
          ? prod.DefaultFirebaseOptions.currentPlatform
          : dev.DefaultFirebaseOptions.currentPlatform;

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      debugPrint(
          '🔥 Firebase inicializado en entorno: ${EnvConfig.isProd ? "PROD" : "DEV"}');

      // Inicializar FCM después de Firebase de forma no bloqueante para Android y Web
      if (kIsWeb || Platform.isAndroid) {
        PushNotificationService().init();
      }

      // Configurar Firebase Crashlytics solo si NO es Web (Crashlytics web no está soportado de la misma manera)
      if (!kIsWeb) {
        // Capturar errores del framework de Flutter
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;

        // Capturar errores asíncronos que no captura el framework
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
        debugPrint('🛡️ Firebase Crashlytics activado');
      }
    } catch (e) {
      debugPrint('⚠️ Error al inicializar Firebase: $e');
    }
  }

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
      navigatorKey: PushNotificationService.navigatorKey,
      title: 'Sudoku Arena',
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
      builder: (context, child) {
        return ResponsiveAppShell(child: child!);
      },
      home: const AnimatedSplashScreen(),
    );
  }
}
