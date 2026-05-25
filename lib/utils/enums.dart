/// TIPOS DE TUTORIALES GUIADOS
enum TutorialScript {
  lawRow,
  lawCol,
  lawBox,
  masteryExclusion,
  powerVision,
  powerClock,
  powerDivine,
}

/// TIPOS DE LAYOUT SEGÚN DISPOSITIVO Y ORIENTACIÓN
enum DeviceLayoutType { 
  portraitMobile, 
  landscapeMobile, 
  desktop 
}

/// DIFICULTADES DEL JUEGO
enum GameDifficulty {
  easy,
  medium,
  hard,
  expert,
  tutorial,
}

extension GameDifficultyExtension on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.easy: return 'Fácil';
      case GameDifficulty.medium: return 'Medio';
      case GameDifficulty.hard: return 'Difícil';
      case GameDifficulty.expert: return 'Experto';
      case GameDifficulty.tutorial: return 'Tutorial';
    }
  }

  static GameDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fácil':
      case 'easy': return GameDifficulty.easy;
      case 'medio':
      case 'medium': return GameDifficulty.medium;
      case 'difícil':
      case 'hard': return GameDifficulty.hard;
      case 'experto':
      case 'expert': return GameDifficulty.expert;
      default: return GameDifficulty.tutorial;
    }
  }
}
