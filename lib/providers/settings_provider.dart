import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

class GameSettings {
  final bool showRemainingNumbers;
  final bool enableErrorLimit;
  final bool enableHighlighting;
  final bool enableVibration;
  final bool showTimer;

  const GameSettings({
    this.showRemainingNumbers = true,
    this.enableErrorLimit = true,
    this.enableHighlighting = true,
    this.enableVibration = true,
    this.showTimer = true,
  });

  GameSettings copyWith({
    bool? showRemainingNumbers,
    bool? enableErrorLimit,
    bool? enableHighlighting,
    bool? enableVibration,
    bool? showTimer,
  }) {
    return GameSettings(
      showRemainingNumbers: showRemainingNumbers ?? this.showRemainingNumbers,
      enableErrorLimit: enableErrorLimit ?? this.enableErrorLimit,
      enableHighlighting: enableHighlighting ?? this.enableHighlighting,
      enableVibration: enableVibration ?? this.enableVibration,
      showTimer: showTimer ?? this.showTimer,
    );
  }
}

class SettingsNotifier extends StateNotifier<GameSettings> {
  final StorageService _storageService;

  SettingsNotifier(this._storageService) : super(const GameSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = GameSettings(
      showRemainingNumbers: _storageService.getSettingShowRemainingNumbers(),
      enableErrorLimit: _storageService.getSettingEnableErrorLimit(),
      enableHighlighting: _storageService.getSettingEnableHighlighting(),
      enableVibration: _storageService.getSettingEnableVibration(),
      showTimer: _storageService.getSettingShowTimer(),
    );
  }

  void toggleShowRemainingNumbers() {
    final updatedVal = !state.showRemainingNumbers;
    _saveAndSet(state.copyWith(showRemainingNumbers: updatedVal));
  }

  void toggleEnableErrorLimit() {
    final updatedVal = !state.enableErrorLimit;
    _saveAndSet(state.copyWith(enableErrorLimit: updatedVal));
  }

  void toggleEnableHighlighting() {
    final updatedVal = !state.enableHighlighting;
    _saveAndSet(state.copyWith(enableHighlighting: updatedVal));
  }

  void toggleEnableVibration() {
    final updatedVal = !state.enableVibration;
    _saveAndSet(state.copyWith(enableVibration: updatedVal));
  }

  void toggleShowTimer() {
    final updatedVal = !state.showTimer;
    _saveAndSet(state.copyWith(showTimer: updatedVal));
  }

  void _saveAndSet(GameSettings updated) {
    state = updated;
    _storageService.saveSettings(
      showRemainingNumbers: updated.showRemainingNumbers,
      enableErrorLimit: updated.enableErrorLimit,
      enableHighlighting: updated.enableHighlighting,
      enableVibration: updated.enableVibration,
      showTimer: updated.showTimer,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});
