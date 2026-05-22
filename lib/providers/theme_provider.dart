import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

class SudokuTheme {
  final String id;
  final String name;
  final int price;
  final Color primaryColor;
  final Color accentColor;
  final Color highlightColor; // Para filas/columnas seleccionadas (retrocompatibilidad)
  final Color textColorLight;  // Color legible para números de usuario en Modo Claro
  final Color textColorDark;   // Color legible para números de usuario en Modo Oscuro
  final Color highlightColorLight; // Fondo de fila/columna seleccionada en Modo Claro
  final Color highlightColorDark;  // Fondo de fila/columna seleccionada en Modo Oscuro
  final bool isPremium;
  final String icon;

  const SudokuTheme({
    required this.id,
    required this.name,
    required this.price,
    required this.primaryColor,
    required this.accentColor,
    required this.highlightColor,
    required this.textColorLight,
    required this.textColorDark,
    required this.highlightColorLight,
    required this.highlightColorDark,
    this.isPremium = false,
    required this.icon,
  });

  static const List<SudokuTheme> availableThemes = [
    SudokuTheme(
      id: 'azul',
      name: 'Azul Océano',
      price: 0,
      primaryColor: Color(0xFF0F62FE), // Azul premium refinado
      accentColor: Color(0xFF78A9FF),
      highlightColor: Color(0x22448AFF),
      textColorLight: Color(0xFF002D9C), // Azul oscuro ultra legible en blanco
      textColorDark: Color(0xFF78A9FF),  // Ice blue radiante en negro
      highlightColorLight: Color(0x0C0F62FE), // 5% de opacidad para resalte suave
      highlightColorDark: Color(0x1B78A9FF),  // 10% de opacidad
      icon: '🌊',
    ),
    SudokuTheme(
      id: 'esmeralda',
      name: 'Esmeralda',
      price: 0,
      primaryColor: Color(0xFF0F9D58), // Verde esmeralda noble
      accentColor: Color(0xFF34D399),
      highlightColor: Color(0x221DE9B6),
      textColorLight: Color(0xFF0A5C36), // Verde bosque profundo legible en blanco
      textColorDark: Color(0xFF34D399),  // Verde menta neón suave en negro
      highlightColorLight: Color(0x0C0F9D58),
      highlightColorDark: Color(0x1B34D399),
      icon: '🌿',
    ),
    SudokuTheme(
      id: 'amatista',
      name: 'Amatista',
      price: 150,
      primaryColor: Color(0xFF8A3FFC), // Violeta real profundo
      accentColor: Color(0xFFBE95FF),
      highlightColor: Color(0x22E040FB),
      textColorLight: Color(0xFF5B108F), // Púrpura profundo ultra legible
      textColorDark: Color(0xFFBE95FF),  // Lavanda suave en negro
      highlightColorLight: Color(0x0C8A3FFC),
      highlightColorDark: Color(0x1BBE95FF),
      isPremium: true,
      icon: '🔮',
    ),
    SudokuTheme(
      id: 'coral',
      name: 'Coral Cálido',
      price: 150,
      primaryColor: Color(0xFFFA4D56), // Rojo coral premium
      accentColor: Color(0xFFFF8389),
      highlightColor: Color(0x22FFAB40),
      textColorLight: Color(0xFFBA1A1A), // Terracota profundo de alto contraste
      textColorDark: Color(0xFFFF8389),  // Coral pastel radiante
      highlightColorLight: Color(0x0CFA4D56),
      highlightColorDark: Color(0x1BFF8389),
      isPremium: true,
      icon: '🍊',
    ),
    SudokuTheme(
      id: 'neon_cyber',
      name: 'Neón Cyberpunk',
      price: 300,
      primaryColor: Color(0xFFD1277E), // Magenta cibernético
      accentColor: Color(0xFF00FFFF), // Cian neón
      highlightColor: Color(0x2200FFFF),
      textColorLight: Color(0xFF8F004B), // Cyber rose profundo muy legible
      textColorDark: Color(0xFFFF66B2),  // Rosa neón brillante en negro
      highlightColorLight: Color(0x0CD1277E),
      highlightColorDark: Color(0x1B00FFFF),
      isPremium: true,
      icon: '⚡',
    ),
    SudokuTheme(
      id: 'dorado_lujo',
      name: 'Oro Imperial',
      price: 500,
      primaryColor: Color(0xFF9F720B), // Dorado tostado noble/bronce
      accentColor: Color(0xFFD4AF37), // Oro metálico real
      highlightColor: Color(0x1EFFC107),
      textColorLight: Color(0xFF6F4E02), // Bronce imperial profundo (excelente legibilidad en blanco)
      textColorDark: Color(0xFFF9D976),  // Oro brillante cálido en negro (cero fatiga visual)
      highlightColorLight: Color(0x0E9F720B), // Resaltado dorado sumamente elegante
      highlightColorDark: Color(0x1BD4AF37),
      isPremium: true,
      icon: '👑',
    ),
  ];
}

class ThemeState {
  final String activeThemeId;
  final bool isDarkMode;
  final List<String> purchasedThemeIds;

  ThemeState({
    required this.activeThemeId,
    required this.isDarkMode,
    required this.purchasedThemeIds,
  });

  ThemeState copyWith({
    String? activeThemeId,
    bool? isDarkMode,
    List<String>? purchasedThemeIds,
  }) {
    return ThemeState(
      activeThemeId: activeThemeId ?? this.activeThemeId,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      purchasedThemeIds: purchasedThemeIds ?? this.purchasedThemeIds,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final StorageService _storageService;

  ThemeNotifier(this._storageService)
      : super(ThemeState(
          activeThemeId: 'azul',
          isDarkMode: false,
          purchasedThemeIds: ['azul'],
        )) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final activeThemeId = _storageService.getActiveColorTheme();
    final isDarkMode = _storageService.getIsDarkMode();
    final purchased = _storageService.getPurchasedThemes();

    state = ThemeState(
      activeThemeId: activeThemeId,
      isDarkMode: isDarkMode,
      purchasedThemeIds: purchased.isEmpty ? ['azul'] : purchased,
    );
  }

  /// Obtiene el tema visual de Sudoku actual.
  SudokuTheme get currentSudokuTheme {
    return SudokuTheme.availableThemes.firstWhere(
      (t) => t.id == state.activeThemeId,
      orElse: () => SudokuTheme.availableThemes.first,
    );
  }

  /// Alterna entre modo claro y oscuro.
  void toggleDarkMode() {
    final nextDarkMode = !state.isDarkMode;
    state = state.copyWith(isDarkMode: nextDarkMode);
    _storageService.saveThemeSettings(
      colorTheme: state.activeThemeId,
      isDarkMode: nextDarkMode,
    );
  }

  /// Cambia el matiz de color de acento activo.
  bool changeActiveTheme(String themeId) {
    if (!state.purchasedThemeIds.contains(themeId)) {
      return false; // No se puede equipar un tema no comprado
    }
    state = state.copyWith(activeThemeId: themeId);
    _storageService.saveThemeSettings(
      colorTheme: themeId,
      isDarkMode: state.isDarkMode,
    );
    return true;
  }

  /// Desbloquea/compra un tema usando monedas del juego.
  bool buyTheme(SudokuTheme theme, int currentCoins, Function(int) onCoinsDeducted) {
    if (state.purchasedThemeIds.contains(theme.id)) {
      return false; // Ya está comprado
    }
    if (currentCoins < theme.price) {
      return false; // Monedas insuficientes
    }

    // Deducción de monedas y agregado a comprados
    onCoinsDeducted(currentCoins - theme.price);
    final updatedPurchased = [...state.purchasedThemeIds, theme.id];
    
    state = state.copyWith(
      purchasedThemeIds: updatedPurchased,
      activeThemeId: theme.id, // Lo equipamos automáticamente
    );

    _storageService.savePurchasedThemes(updatedPurchased);
    _storageService.saveThemeSettings(
      colorTheme: theme.id,
      isDarkMode: state.isDarkMode,
    );

    return true;
  }
}

// Proveedor global de Riverpod
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeNotifier(storage);
});
