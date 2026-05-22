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
  final Color highlightColor; // Para filas/columnas seleccionadas
  final bool isPremium;
  final String icon;

  const SudokuTheme({
    required this.id,
    required this.name,
    required this.price,
    required this.primaryColor,
    required this.accentColor,
    required this.highlightColor,
    this.isPremium = false,
    required this.icon,
  });

  static const List<SudokuTheme> availableThemes = [
    SudokuTheme(
      id: 'azul',
      name: 'Azul Océano',
      price: 0,
      primaryColor: Colors.blue,
      accentColor: Colors.blueAccent,
      highlightColor: Color(0x22448AFF),
      icon: '🌊',
    ),
    SudokuTheme(
      id: 'esmeralda',
      name: 'Esmeralda',
      price: 0,
      primaryColor: Colors.teal,
      accentColor: Colors.tealAccent,
      highlightColor: Color(0x221DE9B6),
      icon: '🌿',
    ),
    SudokuTheme(
      id: 'amatista',
      name: 'Amatista',
      price: 150,
      primaryColor: Colors.purple,
      accentColor: Colors.purpleAccent,
      highlightColor: Color(0x22E040FB),
      isPremium: true,
      icon: '🔮',
    ),
    SudokuTheme(
      id: 'coral',
      name: 'Coral Cálido',
      price: 150,
      primaryColor: Colors.deepOrange,
      accentColor: Colors.orangeAccent,
      highlightColor: Color(0x22FFAB40),
      isPremium: true,
      icon: '🍊',
    ),
    SudokuTheme(
      id: 'neon_cyber',
      name: 'Neón Cyberpunk',
      price: 300,
      primaryColor: Color(0xFFFF007F), // Rosa neón
      accentColor: Color(0xFF00FFFF), // Cian neón
      highlightColor: Color(0x2200FFFF),
      isPremium: true,
      icon: '⚡',
    ),
    SudokuTheme(
      id: 'dorado_lujo',
      name: 'Oro Imperial',
      price: 500,
      primaryColor: Color(0xFFFFD700), // Oro
      accentColor: Colors.amber,
      highlightColor: Color(0x22FFC107),
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
